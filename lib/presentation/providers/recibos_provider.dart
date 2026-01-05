import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/recibo.dart';
import '../../domain/entities/residente.dart';
import '../../domain/entities/departamento.dart';
import '../../domain/usecases/get_recibos_usecase.dart';
import '../../domain/usecases/get_residentes_usecase.dart';
import '../../domain/usecases/get_departamentos_usecase.dart';

class RecibosProvider with ChangeNotifier {
  final GetRecibosUseCase getRecibosUseCase;
  final GetResidentesUseCase getResidentesUseCase;
  final GetDepartamentosUseCase getDepartamentosUseCase;

  RecibosProvider(
    this.getRecibosUseCase,
    this.getResidentesUseCase,
    this.getDepartamentosUseCase,
  );

  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<Recibo> _recibos = [];
  Failure? _error;
  String? _currentSchema;
  
  // Paginación
  int _currentPage = 1;
  bool _hasMorePages = true;

  // Listas para filtros
  bool _isLoadingResidentes = false;
  bool _isLoadingDepartamentos = false;
  List<Residente> _residentes = [];
  List<Departamento> _departamentos = [];
  Failure? _errorResidentes;
  Failure? _errorDepartamentos;

  // Filtros
  String? _selectedYear;
  String? _selectedMonth;
  int? _selectedTenant;
  int? _selectedHouse;
  String? _selectedStatus;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<Recibo> get recibos => _recibos;
  Failure? get error => _error;
  String? get currentSchema => _currentSchema;
  bool get hasMorePages => _hasMorePages;
  int get currentPage => _currentPage;

  // Getters de filtros
  String? get selectedYear => _selectedYear;
  String? get selectedMonth => _selectedMonth;
  int? get selectedTenant => _selectedTenant;
  int? get selectedHouse => _selectedHouse;
  String? get selectedStatus => _selectedStatus;

  // Getters de listas
  bool get isLoadingResidentes => _isLoadingResidentes;
  bool get isLoadingDepartamentos => _isLoadingDepartamentos;
  List<Residente> get residentes => _residentes;
  List<Departamento> get departamentos => _departamentos;
  Failure? get errorResidentes => _errorResidentes;
  Failure? get errorDepartamentos => _errorDepartamentos;

  Future<void> loadRecibos({
    required String token,
    required String schema,
    String? year,
    String? month,
    int? tenant,
    int? house,
    String? status,
    bool loadMore = false,
  }) async {
    // Si estamos cargando más, verificar si hay más páginas
    if (loadMore && !_hasMorePages) return;
    
    if (loadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _currentPage = 1;
      _recibos = [];
      _hasMorePages = true;
    }
    
    _error = null;
    _currentSchema = schema;
    _selectedYear = year;
    _selectedMonth = month;
    _selectedTenant = tenant;
    _selectedHouse = house;
    _selectedStatus = status;
    notifyListeners();

    final result = await getRecibosUseCase(
      token: token,
      schema: schema,
      year: year,
      month: month,
      tenant: tenant,
      house: house,
      status: status,
      page: _currentPage,
      perPage: 15,
    );

    _isLoading = false;
    _isLoadingMore = false;

    if (result is Success<List<Recibo>>) {
      final newRecibos = result.data;
      
      if (loadMore) {
        _recibos.addAll(newRecibos);
      } else {
        _recibos = newRecibos;
      }
      
      // Ordenar: recibos sin imagen de medidor primero
      _recibos.sort((a, b) {
        final aSinImagen = a.medidorImage == null || a.medidorImage!.isEmpty;
        final bSinImagen = b.medidorImage == null || b.medidorImage!.isEmpty;
        
        // Si a no tiene imagen y b sí tiene, a va primero
        if (aSinImagen && !bSinImagen) return -1;
        // Si a tiene imagen y b no tiene, b va primero
        if (!aSinImagen && bSinImagen) return 1;
        // Si ambos están en el mismo grupo (ambos tienen o ambos no tienen), mantener orden original
        return 0;
      });
      
      _error = null;
      
      // Si recibimos menos de 15 elementos, no hay más páginas
      _hasMorePages = newRecibos.length >= 15;
      
      if (_hasMorePages) {
        _currentPage++;
      }
    } else if (result is Error<List<Recibo>>) {
      _error = result.failure;
      if (!loadMore) {
        _recibos = [];
      }
    }

    notifyListeners();
  }

  Future<void> loadMoreRecibos(String token) async {
    if (_currentSchema == null || !_hasMorePages) return;

    await loadRecibos(
      token: token,
      schema: _currentSchema!,
      year: _selectedYear,
      month: _selectedMonth,
      tenant: _selectedTenant,
      house: _selectedHouse,
      status: _selectedStatus,
      loadMore: true,
    );
  }

  void setFilters({
    String? year,
    String? month,
    int? tenant,
    int? house,
    String? status,
  }) {
    _selectedYear = year;
    _selectedMonth = month;
    _selectedTenant = tenant;
    _selectedHouse = house;
    _selectedStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _selectedYear = null;
    _selectedMonth = null;
    _selectedTenant = null;
    _selectedHouse = null;
    _selectedStatus = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadResidentes(String token, String schema) async {
    _isLoadingResidentes = true;
    _errorResidentes = null;
    notifyListeners();

    try {
      final result = await getResidentesUseCase(token, schema);

      _isLoadingResidentes = false;

      if (result is Success<List<Residente>>) {
        _residentes = result.data;
        _errorResidentes = null;
      } else if (result is Error<List<Residente>>) {
        _errorResidentes = result.failure;
        _residentes = [];
      }
    } catch (e) {
      _isLoadingResidentes = false;
      _errorResidentes = NetworkFailure('Error al cargar residentes: ${e.toString()}');
      _residentes = [];
    }

    notifyListeners();
  }

  Future<void> loadDepartamentos(String token, String schema) async {
    _isLoadingDepartamentos = true;
    _errorDepartamentos = null;
    notifyListeners();

    try {
      final result = await getDepartamentosUseCase(token, schema);

      _isLoadingDepartamentos = false;

      if (result is Success<List<Departamento>>) {
        _departamentos = result.data;
        _errorDepartamentos = null;
      } else if (result is Error<List<Departamento>>) {
        _errorDepartamentos = result.failure;
        _departamentos = [];
      }
    } catch (e) {
      _isLoadingDepartamentos = false;
      _errorDepartamentos = NetworkFailure('Error al cargar departamentos: ${e.toString()}');
      _departamentos = [];
    }

    notifyListeners();
  }
}

