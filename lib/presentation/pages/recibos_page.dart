import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recibos_provider.dart';
import '../providers/auth_provider.dart';
import '../../domain/entities/recibo.dart';
import 'medidor_image_page.dart';

class RecibosPage extends StatefulWidget {
  final String schema;

  const RecibosPage({
    super.key,
    required this.schema,
  });

  @override
  State<RecibosPage> createState() => _RecibosPageState();
}

class _RecibosPageState extends State<RecibosPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Limpiar filtros al entrar a una nueva residencia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recibosProvider = context.read<RecibosProvider>();
      
      // Si el schema cambió, limpiar los filtros
      if (recibosProvider.currentSchema != widget.schema) {
        recibosProvider.clearFilters();
      }
      
      _loadRecibos();
    });
    
    // Agregar listener para scroll infinito
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      // Cuando llegamos al 90% del scroll, cargamos más
      final authProvider = context.read<AuthProvider>();
      final recibosProvider = context.read<RecibosProvider>();
      
      final token = authProvider.currentUser?.token;
      if (token != null && !recibosProvider.isLoadingMore && recibosProvider.hasMorePages) {
        recibosProvider.loadMoreRecibos(token);
      }
    }
  }

  void _loadRecibos() {
    final authProvider = context.read<AuthProvider>();
    final recibosProvider = context.read<RecibosProvider>();
    
    final token = authProvider.currentUser?.token;
    if (token != null) {
      recibosProvider.loadRecibos(
        token: token,
        schema: widget.schema,
        year: recibosProvider.selectedYear,
        month: recibosProvider.selectedMonth,
        tenant: recibosProvider.selectedTenant,
        house: recibosProvider.selectedHouse,
        status: recibosProvider.selectedStatus,
      );
    }
  }

  void _showFilters(BuildContext context) {
    final recibosProvider = context.read<RecibosProvider>();
    final authProvider = context.read<AuthProvider>();
    
    // Cargar residentes y departamentos cuando se abre el modal
    final token = authProvider.currentUser?.token;
    if (token != null && widget.schema.isNotEmpty) {
      recibosProvider.loadResidentes(token, widget.schema);
      recibosProvider.loadDepartamentos(token, widget.schema);
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FiltersBottomSheet(
        provider: recibosProvider,
        schema: widget.schema,
        onApply: () {
          _loadRecibos();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recibos'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context),
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Consumer<RecibosProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar recibos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      provider.error!.message.replaceFirst('Error al obtener los recibos: ', ''),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadRecibos,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.recibos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay recibos disponibles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadRecibos();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.recibos.length + (provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Si es el último elemento y estamos cargando más, mostrar indicador
                if (index == provider.recibos.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final recibo = provider.recibos[index];
                return _ReciboCard(
                  recibo: recibo,
                  schema: widget.schema,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ReciboCard extends StatelessWidget {
  final Recibo recibo;
  final String schema;

  const _ReciboCard({
    required this.recibo,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    final hasMedidorImage = recibo.medidorImage != null && 
                           recibo.medidorImage!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recibo.departamento?.houseNumero ?? 'N/A',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recibo.residente?.nombre ?? 'Sin residente',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: '${recibo.month} ${recibo.year}',
                ),
                const SizedBox(width: 8),
                _StatusChip(status: recibo.status),
              ],
            ),
            if (!hasMedidorImage) ...[
              const SizedBox(height: 12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MedidorImagePage(
                        reciboId: recibo.id,
                        schema: schema,
                        departamentoNumero: recibo.departamento?.houseNumero,
                        residenteNombre: recibo.residente?.nombre,
                        mes: recibo.month,
                        year: recibo.year,
                      ),
                    ),
                  ).then((updated) {
                    // Si se actualizó, recargar los recibos
                    if (updated == true && context.mounted) {
                      final recibosProvider = context.read<RecibosProvider>();
                      final authProvider = context.read<AuthProvider>();
                      final token = authProvider.currentUser?.token;
                      if (token != null) {
                        recibosProvider.loadRecibos(
                          token: token,
                          schema: schema,
                          year: recibosProvider.selectedYear,
                          month: recibosProvider.selectedMonth,
                          tenant: recibosProvider.selectedTenant,
                          house: recibosProvider.selectedHouse,
                          status: recibosProvider.selectedStatus,
                        );
                      }
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Falta imagen medidor',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.orange[700],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pagado':
        return Colors.green;
      case 'pending':
      case 'pendiente':
        return Colors.orange;
      case 'vencido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'pagado':
        return 'Pagado';
      case 'pending':
      case 'pendiente':
        return 'Pendiente';
      case 'vencido':
        return 'Vencido';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _getStatusLabel(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _FiltersBottomSheet extends StatefulWidget {
  final RecibosProvider provider;
  final String schema;
  final VoidCallback onApply;

  const _FiltersBottomSheet({
    required this.provider,
    required this.schema,
    required this.onApply,
  });

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  late TextEditingController _yearController;
  String? _selectedMonth;
  int? _selectedTenant;
  int? _selectedHouse;
  String? _selectedStatus;

  // Mapeo de meses
  final Map<String, String> _meses = {
    'Enero': 'enero',
    'Febrero': 'febrero',
    'Marzo': 'marzo',
    'Abril': 'abril',
    'Mayo': 'mayo',
    'Junio': 'junio',
    'Julio': 'julio',
    'Agosto': 'agosto',
    'Setiembre': 'setiembre',
    'Octubre': 'octubre',
    'Noviembre': 'noviembre',
    'Diciembre': 'diciembre',
  };

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController(text: widget.provider.selectedYear);
    // Convertir el mes guardado (minúscula) a formato de display
    if (widget.provider.selectedMonth != null) {
      final monthLower = widget.provider.selectedMonth!.toLowerCase();
      _selectedMonth = _meses.entries
          .firstWhere(
            (e) => e.value == monthLower,
            orElse: () => MapEntry(widget.provider.selectedMonth!, monthLower),
          )
          .key;
    }
    _selectedTenant = widget.provider.selectedTenant;
    _selectedHouse = widget.provider.selectedHouse;
    _selectedStatus = widget.provider.selectedStatus;
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    // Convertir el mes seleccionado a minúscula para el endpoint
    String? monthValue = _selectedMonth != null ? _meses[_selectedMonth] : null;
    
    widget.provider.setFilters(
      year: _yearController.text.isEmpty ? null : _yearController.text,
      month: monthValue,
      tenant: _selectedTenant,
      house: _selectedHouse,
      status: _selectedStatus,
    );
    widget.onApply();
  }

  void _clearFilters() {
    _yearController.clear();
    setState(() {
      _selectedMonth = null;
      _selectedTenant = null;
      _selectedHouse = null;
      _selectedStatus = null;
    });
    widget.provider.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtros',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _yearController,
                        decoration: const InputDecoration(
                          labelText: 'Año',
                          hintText: 'Ej: 2024',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedMonth,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Mes',
                          prefixIcon: Icon(Icons.calendar_month),
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Seleccionar mes'),
                        items: _meses.keys.map((String mes) {
                          return DropdownMenuItem<String>(
                            value: mes,
                            child: Text(
                              mes,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMonth = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer<RecibosProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoadingResidentes) {
                            return const SizedBox(
                              height: 56,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          
                          if (provider.errorResidentes != null) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    labelText: 'Residente',
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(),
                                    hintText: 'Error al cargar residentes',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  provider.errorResidentes!.message,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          }
                          
                          if (provider.residentes.isEmpty) {
                            return const TextField(
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Residente',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                                hintText: 'No hay residentes disponibles',
                              ),
                            );
                          }
                          
                          // Validar que el residente seleccionado exista en la lista actual
                          final residenteExists = _selectedTenant == null || 
                              provider.residentes.any((r) => r.id == _selectedTenant);
                          
                          if (!residenteExists) {
                            // Si el residente no existe en la lista, limpiar la selección
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                _selectedTenant = null;
                              });
                            });
                          }
                          
                          return DropdownButtonFormField<int>(
                            value: residenteExists ? _selectedTenant : null,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Residente',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Seleccionar residente'),
                            items: provider.residentes.map<DropdownMenuItem<int>>((residente) {
                              return DropdownMenuItem<int>(
                                value: residente.id,
                                child: Text(
                                  residente.fullname,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                            selectedItemBuilder: (BuildContext context) {
                              return provider.residentes.map<Widget>((residente) {
                                return Text(
                                  residente.fullname,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                );
                              }).toList();
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedTenant = value;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer<RecibosProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoadingDepartamentos) {
                            return const SizedBox(
                              height: 56,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          
                          if (provider.departamentos.isEmpty) {
                            return const TextField(
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Departamento',
                                prefixIcon: Icon(Icons.home),
                                border: OutlineInputBorder(),
                                hintText: 'No hay departamentos disponibles',
                              ),
                            );
                          }
                          
                          // Validar que el departamento seleccionado exista en la lista actual
                          final departamentoExists = _selectedHouse == null || 
                              provider.departamentos.any((d) => d.id == _selectedHouse);
                          
                          if (!departamentoExists) {
                            // Si el departamento no existe en la lista, limpiar la selección
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                _selectedHouse = null;
                              });
                            });
                          }
                          
                          return DropdownButtonFormField<int>(
                            value: departamentoExists ? _selectedHouse : null,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Departamento',
                              prefixIcon: Icon(Icons.home),
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Seleccionar departamento'),
                            items: provider.departamentos.map<DropdownMenuItem<int>>((departamento) {
                              return DropdownMenuItem<int>(
                                value: departamento.id,
                                child: Text(
                                  '${departamento.houseNumber} - ${departamento.features ?? ''}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                            selectedItemBuilder: (BuildContext context) {
                              return provider.departamentos.map<Widget>((departamento) {
                                return Text(
                                  '${departamento.houseNumber} - ${departamento.features ?? ''}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                );
                              }).toList();
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedHouse = value;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          prefixIcon: Icon(Icons.filter_alt),
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Seleccionar estado'),
                        items: const [
                          DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                          DropdownMenuItem(value: 'pagado', child: Text('Pagado')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _clearFilters,
                              child: const Text('Limpiar'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              child: const Text('Aplicar Filtros'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

