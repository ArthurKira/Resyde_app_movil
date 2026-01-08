import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asistencia_provider.dart';
import '../providers/auth_provider.dart';
import '../../domain/entities/estado_asistencia.dart';
import '../../domain/entities/registro_asistencia.dart';
import '../../domain/entities/horario_turno.dart';
import '../../core/utils/result.dart';

class AsistenciaPage extends StatefulWidget {
  const AsistenciaPage({super.key});

  @override
  State<AsistenciaPage> createState() => _AsistenciaPageState();
}

class _AsistenciaPageState extends State<AsistenciaPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEstado();
    });
  }

  void _loadEstado() {
    final authProvider = context.read<AuthProvider>();
    final asistenciaProvider = context.read<AsistenciaProvider>();
    
    final token = authProvider.currentUser?.token;
    if (token != null) {
      asistenciaProvider.loadEstadoAsistencia(token);
      asistenciaProvider.loadHistorialAsistencia(token, limite: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadEstado();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Card de estado actual
              Consumer<AsistenciaProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingEstado) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (provider.error != null && provider.estadoAsistencia == null) {
                    return _buildErrorCard(provider.error!.message, () => _loadEstado());
                  }

                  final estado = provider.estadoAsistencia;
                  if (estado == null) {
                    return const SizedBox.shrink();
                  }

                  return _buildEstadoCard(context, estado, provider);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Historial
              Consumer<AsistenciaProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingHistorial) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (provider.errorHistorial != null && provider.historialAsistencia == null) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'Error al cargar historial',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                final authProvider = context.read<AuthProvider>();
                                final token = authProvider.currentUser?.token;
                                if (token != null) {
                                  provider.loadHistorialAsistencia(token, limite: 30);
                                }
                              },
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final historial = provider.historialAsistencia;
                  if (historial == null || historial.historial.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No hay registros de asistencia',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ),
                    );
                  }

                  return _buildHistorialSection(context, historial.historial);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, VoidCallback onRetry) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 48),
            const SizedBox(height: 8),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoCard(
    BuildContext context,
    EstadoAsistencia estado,
    AsistenciaProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado del Día',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estado.fecha,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Mensaje de estado del backend
            if (estado.mensaje != null && estado.mensaje!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: estado.puedeMarcarSalida
                      ? Colors.blue[50]
                      : _getColorEstado(estado).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: estado.puedeMarcarSalida
                        ? Colors.blue[200]!
                        : _getColorEstado(estado).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      estado.puedeMarcarSalida
                          ? Icons.pending_actions
                          : _getIconEstado(estado),
                      color: estado.puedeMarcarSalida
                          ? Colors.blue[700]
                          : _getColorEstado(estado),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        estado.mensaje!,
                        style: TextStyle(
                          color: estado.puedeMarcarSalida
                              ? Colors.blue[900]
                              : _getColorEstado(estado),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Información de registro actual
            if (estado.registro != null) ...[
              _buildRegistroInfo(context, estado.registro!),
              const SizedBox(height: 16),
              
              // Advertencia para turnos largos (más de 40 horas)
              if (estado.registro!.horaSalida == null)
                _buildAdvertenciaTurnoLargo(context, estado.registro!),
              
              const SizedBox(height: 8),
            ],
            
            // Si no hay registro activo pero hay horario de hoy, mostrarlo
            if (estado.registro == null && estado.horarioHoy != null && estado.puedeMarcarEntrada) ...[
              _buildHorarioDisponible(context, estado.horarioHoy!),
              const SizedBox(height: 16),
            ],
            
            // Botones de acción - PRIORIDAD: primero salida, luego entrada
            // Si hay un turno pendiente de cerrar, mostrar solo ese
            if (estado.puedeMarcarSalida && estado.registro != null && estado.registro!.horaSalida == null) ...[
              _buildActionButton(
                context,
                'Marcar Salida',
                Icons.logout,
                Colors.orange,
                provider.isMarcandoSalida || provider.isObteniendoUbicacion,
                provider.isTomandoFoto,
                () => _marcarSalida(context, provider),
              ),
              // Mostrar que hay un nuevo turno disponible después de cerrar este
              if (estado.puedeMarcarEntrada) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Después de marcar salida, podrás iniciar tu siguiente turno',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else if (estado.puedeMarcarEntrada) ...[
              // Solo entrada si no hay turno pendiente
              _buildActionButton(
                context,
                'Marcar Entrada',
                Icons.login,
                Colors.green,
                provider.isMarcandoEntrada || provider.isObteniendoUbicacion,
                provider.isTomandoFoto,
                () => _marcarEntrada(context, provider),
              ),
            ] else if (!estado.tieneHorario) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No tienes horario asignado para hoy',
                        style: TextStyle(color: Colors.amber[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (estado.enVacaciones || estado.enLicencia) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.beach_access, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        estado.enVacaciones
                            ? 'Estás en vacaciones'
                            : 'Estás en licencia',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRegistroInfo(BuildContext context, RegistroAsistencia registro) {
    final provider = context.read<AsistenciaProvider>();
    final estado = provider.estadoAsistencia;
    final horarioRegistro = estado?.horarioRegistro;
    final esTurnoNocturno = horarioRegistro?.esTurnoNocturno ?? _esTurnoNocturno(registro);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esTurnoNocturno ? Colors.indigo[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esTurnoNocturno ? Colors.indigo[200]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del card
          Row(
            children: [
              if (esTurnoNocturno) ...[
                Icon(Icons.nightlight_round, color: Colors.indigo[700], size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  esTurnoNocturno ? 'Turno Nocturno Activo' : 'Registro del Día',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: esTurnoNocturno ? Colors.indigo[900] : null,
                      ),
                ),
              ),
            ],
          ),
          
          // Horario programado (si existe)
          if (horarioRegistro != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Horario Programado',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Entrada: ${_formatearFechaHora(horarioRegistro.fechaEntrada, horarioRegistro.horaEntrada)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Salida: ${_formatearFechaHora(horarioRegistro.fechaSalida, horarioRegistro.horaSalida)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  // Mostrar cargo si existe
                  if (horarioRegistro.personalResidencia != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 14, color: Colors.blue[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Cargo: ${horarioRegistro.personalResidencia!.cargo}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Mostrar residencia si existe
                  if (horarioRegistro.residencia != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_city, size: 14, color: Colors.purple[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Residencia: ${horarioRegistro.residencia!.nombre}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Registro real
          Text(
            'Tu Registro',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.login,
            'Entrada',
            '${_formatearFecha(registro.fechaEntrada)} ${registro.horaEntrada}',
            Colors.green,
          ),
          if (registro.horaSalida != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.logout,
              'Salida',
              '${_formatearFecha(registro.fechaSalida ?? registro.fechaEntrada)} ${registro.horaSalida}',
              Colors.orange,
            ),
          ],
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.info_outline,
            'Estado',
            registro.estado,
            _getColorEstado2(registro.estado),
          ),
        ],
      ),
    );
  }

  String _formatearFechaHora(String fecha, String hora) {
    try {
      final fechaParsed = DateTime.parse(fecha);
      final diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      final diaSemana = diasSemana[fechaParsed.weekday - 1];
      final dia = fechaParsed.day.toString().padLeft(2, '0');
      return '$diaSemana $dia a las $hora';
    } catch (e) {
      return '$fecha $hora';
    }
  }

  String _formatearFecha(String fecha) {
    try {
      final fechaParsed = DateTime.parse(fecha);
      final diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      final diaSemana = diasSemana[fechaParsed.weekday - 1];
      final dia = fechaParsed.day.toString().padLeft(2, '0');
      final mes = fechaParsed.month.toString().padLeft(2, '0');
      return '$diaSemana $dia/$mes';
    } catch (e) {
      return fecha;
    }
  }

  Color _getColorEstado2(String estado) {
    switch (estado.toLowerCase()) {
      case 'presente':
        return Colors.green;
      case 'tardanza':
        return Colors.orange;
      case 'falta':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool _esTurnoNocturno(RegistroAsistencia registro) {
    try {
      // Si tiene salida, no es un turno activo
      if (registro.horaSalida != null) return false;
      
      final fechaEntrada = DateTime.parse(registro.fechaEntrada);
      final fechaHoy = DateTime.now();
      
      // Si la entrada fue en un día diferente al actual, es turno nocturno
      return fechaEntrada.year != fechaHoy.year ||
             fechaEntrada.month != fechaHoy.month ||
             fechaEntrada.day != fechaHoy.day;
    } catch (e) {
      return false;
    }
  }

  Widget _buildAdvertenciaTurnoLargo(BuildContext context, RegistroAsistencia registro) {
    try {
      final fechaEntrada = DateTime.parse('${registro.fechaEntrada} ${registro.horaEntrada}');
      final ahora = DateTime.now();
      final diferencia = ahora.difference(fechaEntrada);
      
      // Mostrar advertencia si han pasado más de 40 horas
      if (diferencia.inHours >= 40) {
        final horasRestantes = 48 - diferencia.inHours;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber[300]!, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  horasRestantes > 0
                      ? '⚠️ Tu entrada fue hace ${diferencia.inHours} horas. Marca tu salida pronto (límite: 48h, quedan ${horasRestantes}h)'
                      : '⚠️ Han pasado más de 48 horas desde tu entrada. Contacta a tu supervisor.',
                  style: TextStyle(
                    color: Colors.amber[900],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Si hay error al parsear fechas, no mostrar advertencia
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildHorarioDisponible(BuildContext context, HorarioTurno horario) {
    final esTurnoNocturno = horario.esTurnoNocturno;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esTurnoNocturno ? Colors.indigo[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esTurnoNocturno ? Colors.indigo[200]! : Colors.green[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                esTurnoNocturno ? Icons.nightlight_round : Icons.wb_sunny_outlined,
                color: esTurnoNocturno ? Colors.indigo[700] : Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  esTurnoNocturno ? 'Turno Nocturno Disponible' : 'Turno Disponible',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: esTurnoNocturno ? Colors.indigo[900] : Colors.green[900],
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Horario Programado',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.login, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Entrada: ${_formatearFechaHora(horario.fechaEntrada, horario.horaEntrada)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.logout, size: 16, color: Colors.orange[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Salida: ${_formatearFechaHora(horario.fechaSalida, horario.horaSalida)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
                if (horario.diasSemana.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Días: ${_traducirDiasSemana(horario.diasSemana)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
                // Mostrar cargo si existe
                if (horario.personalResidencia != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.badge, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cargo: ${horario.personalResidencia!.cargo}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // Mostrar residencia si existe
                if (horario.residencia != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_city, size: 16, color: Colors.purple[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Residencia: ${horario.residencia!.nombre}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _traducirDiasSemana(List<String> dias) {
    final traduccion = {
      'Monday': 'Lun',
      'Tuesday': 'Mar',
      'Wednesday': 'Mié',
      'Thursday': 'Jue',
      'Friday': 'Vie',
      'Saturday': 'Sáb',
      'Sunday': 'Dom',
    };
    
    return dias.map((dia) => traduccion[dia] ?? dia).join(', ');
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    bool isLoading,
    bool isTomandoFoto,
    VoidCallback onPressed,
  ) {
    final isDisabled = isLoading || isTomandoFoto;
    String buttonLabel = label;
    if (isTomandoFoto) {
      buttonLabel = 'Tomando foto...';
    } else if (isLoading) {
      buttonLabel = 'Procesando...';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isDisabled ? null : onPressed,
        icon: isDisabled
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Icon(icon),
        label: Text(buttonLabel),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Color _getColorEstado(EstadoAsistencia estado) {
    if (estado.enVacaciones || estado.enLicencia) return Colors.blue;
    if (!estado.tieneHorario) return Colors.amber;
    if (estado.puedeMarcarEntrada) return Colors.green;
    if (estado.puedeMarcarSalida) return Colors.orange;
    return Colors.grey;
  }

  IconData _getIconEstado(EstadoAsistencia estado) {
    if (estado.enVacaciones || estado.enLicencia) return Icons.beach_access;
    if (!estado.tieneHorario) return Icons.info_outline;
    if (estado.puedeMarcarEntrada) return Icons.login;
    if (estado.puedeMarcarSalida) return Icons.logout;
    return Icons.check_circle;
  }

  Future<void> _marcarEntrada(BuildContext context, AsistenciaProvider provider) async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.currentUser?.token;
    if (token == null) return;

    final result = await provider.marcarEntrada(token);

    if (context.mounted) {
      if (result is Success<RegistroAsistencia>) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrada marcada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result is Error<RegistroAsistencia>) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.failure.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _marcarSalida(BuildContext context, AsistenciaProvider provider) async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.currentUser?.token;
    if (token == null) return;

    final result = await provider.marcarSalida(token);

    if (context.mounted) {
      if (result is Success<RegistroAsistencia>) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salida marcada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result is Error<RegistroAsistencia>) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.failure.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildHistorialSection(BuildContext context, List<RegistroAsistencia> historial) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Historial de Asistencia',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historial.length,
          itemBuilder: (context, index) {
            final registro = historial[index];
            return _buildHistorialItem(context, registro);
          },
        ),
      ],
    );
  }

  Widget _buildHistorialItem(BuildContext context, RegistroAsistencia registro) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  registro.fechaEntrada,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: registro.estado == 'Presente'
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    registro.estado,
                    style: TextStyle(
                      color: registro.estado == 'Presente'
                          ? Colors.green[700]
                          : Colors.orange[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.login, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Entrada: ${registro.horaEntrada}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (registro.horaSalida != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.logout, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Salida: ${registro.horaSalida}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

