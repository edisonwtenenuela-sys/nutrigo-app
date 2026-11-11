import 'dart:async';
import 'package:emprendedor/data/models/entrepreneur/index.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';
import 'package:emprendedor/data/repositories/entrepreneur/index.dart';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/data/services/report_exporter_service.dart';

class StatsController extends ChangeNotifier {
  final Logger _logger = Logger('StatsController');
  final StatsRepository _statsRepository = StatsRepository();
  final ProductRepository _productRepository = ProductRepository();
  final PromotionRepository _promotionRepository = PromotionRepository();
  final ReportExporterService _reportExporterService = ReportExporterService();

  StatisticsOverview? _statisticsOverview;
  StatisticsOverview? get statisticsOverview => _statisticsOverview;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTimeRange? _selectedDateRange;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  SalesInterval _selectedSalesInterval = SalesInterval.daily;
  SalesInterval get selectedSalesInterval => _selectedSalesInterval;

  Map<int, int> _peakSalesHours = {};
  Map<int, int> get peakSalesHours => _peakSalesHours;

  List<ProductModel> _topProducts = [];
  List<ProductModel> get topProducts => _topProducts;

  List<PromotionModel> _promotions = [];
  List<PromotionModel> get promotions => _promotions;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  StreamSubscription<List<PromotionModel>>? _promotionsSubscription;
  int _statsUpdateToken = 0;

  String? _userId;
  String? get userId => _userId;
  bool get _hasValidUserId => _userId != null && _userId!.trim().isNotEmpty;

  Future<void> setUserId(String? userId) async {
    if (_userId == userId) return;

    await _cancelOrdersSubscription();
    await _cancelPromotionsSubscription();
    _userId = userId;

    if (!_hasValidUserId) {
      await reset();
      return;
    }

    final today = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: today.subtract(const Duration(days: 30)),
      end: today,
    );

    await fetchStatistics();
    await _watchRelevantOrders();
    _fetchPromotions();
  }

  Future<void> reset() async {
    await _cancelOrdersSubscription();
    await _cancelPromotionsSubscription();

    _statisticsOverview = StatisticsOverview.empty();
    _selectedDateRange = null;
    _selectedSalesInterval = SalesInterval.daily;
    _peakSalesHours = {};
    _topProducts = [];
    _promotions = [];
    _errorMessage = null;
    _isLoading = false;
    _userId = null;
    notifyListeners();
  }

  List<SalesDataPoint> get currentSalesData {
    final overview = _statisticsOverview;
    if (overview == null) return [];

    switch (_selectedSalesInterval) {
      case SalesInterval.daily:
        return overview.dailySales;
      case SalesInterval.weekly:
        return overview.weeklySales;
      case SalesInterval.monthly:
        return overview.monthlySales;
    }
  }

  Future<void> fetchStatistics() async {
    if (!_hasValidUserId) {
      _setError('El ID de usuario no está disponible.');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _statisticsOverview = await _statsRepository.calculateStatisticsOverview(
        userId: _userId!,
        filterStartDate: _selectedDateRange?.start,
        filterEndDate: _selectedDateRange?.end,
      );

      await _calculatePeakSalesHours();
      await _fetchTopProducts();
    } catch (e, st) {
      _logger.warning(
        'No se pudieron calcular estadísticas, se mostrará vista vacía.',
        e,
        st,
      );

      _statisticsOverview = StatisticsOverview.empty();
      _peakSalesHours = {};
      _topProducts = [];
      _errorMessage = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setSelectedDateRange(DateTimeRange? range) async {
    if (range == null || range == _selectedDateRange) return;
    _selectedDateRange = range;
    notifyListeners();
    await fetchStatistics();
    await _watchRelevantOrders();
  }

  void setSelectedSalesInterval(SalesInterval interval) {
    if (interval == _selectedSalesInterval) return;
    _selectedSalesInterval = interval;
    notifyListeners();
  }

  Future<bool> exportReport(String format) async {
    final overview = _statisticsOverview;
    if (_isOverviewEmpty(overview)) {
      _setError('No hay datos disponibles para exportar.');
      return false;
    }

    _setLoading(true);
    _clearError();

    final normalizedFormat = format.toLowerCase();
    final fileTypeDescription = normalizedFormat == 'excel' ? 'Excel' : 'PDF';

    try {
      if (normalizedFormat == 'excel') {
        await _reportExporterService.exportToExcel(
          overview!,
          'reporte_estadísticas_tienda',
        );
      } else if (normalizedFormat == 'pdf') {
        await _reportExporterService.exportToPdf(
          overview!,
          'reporte_estadísticas_tienda',
        );
      } else {
        throw Exception('Formato de exportación no soportado: $format');
      }
      return true;
    } catch (e, st) {
      _logger.severe(
        'Error durante la exportación del reporte $fileTypeDescription',
        e,
        st,
      );
      _setError('Error al exportar reporte $fileTypeDescription.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _clearError();
  }

  Future<void> _calculatePeakSalesHours() async {
    if (!_hasValidUserId) {
      _peakSalesHours = {};
      return;
    }

    try {
      final orders = await _statsRepository.getRelevantOrders(
        userId: _userId!,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );

      _peakSalesHours = _statsRepository.calculatePeakSalesHours(orders);
    } catch (e, st) {
      _logger.severe('Error al calcular horarios de mayor venta', e, st);
      _peakSalesHours = {};
    }
  }

  Future<void> _fetchTopProducts() async {
    if (!_hasValidUserId ||
        _statisticsOverview == null ||
        _statisticsOverview!.topProducts.isEmpty) {
      _topProducts = [];
      return;
    }

    try {
      final topProductIds = _statisticsOverview!.topProducts
          .map((product) => product.productId)
          .where((id) => id.trim().isNotEmpty)
          .toList();

      if (topProductIds.isEmpty) {
        _topProducts = [];
        return;
      }

      _topProducts = await _productRepository.getProductsByIds(
        topProductIds,
        _userId!,
      );
    } catch (e, st) {
      _logger.severe('Error al obtener productos más vendidos', e, st);
      _topProducts = [];
    }
  }

  Future<void> _watchRelevantOrders() async {
    if (!_hasValidUserId) return;

    await _cancelOrdersSubscription();
    _ordersSubscription = _statsRepository
        .watchRelevantOrders(
          userId: _userId!,
          startDate: _selectedDateRange?.start,
          endDate: _selectedDateRange?.end,
        )
        .listen(
          (orders) {
            _applyLiveStatistics(orders);
          },
          onError: (e, st) {
            _logger.severe(
              'Error al escuchar estadísticas en tiempo real',
              e,
              st,
            );
          },
        );
  }

  Future<void> _applyLiveStatistics(List<OrderModel> orders) async {
    final updateToken = ++_statsUpdateToken;

    _statisticsOverview = _statsRepository.buildStatisticsOverview(orders);
    _peakSalesHours = _statsRepository.calculatePeakSalesHours(orders);
    await _fetchTopProducts();

    if (updateToken != _statsUpdateToken) return;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void _fetchPromotions() {
    if (!_hasValidUserId) return;

    _promotions = [];
    _cancelPromotionsSubscription();

    _promotionsSubscription = _promotionRepository
        .getPromotions(_userId!)
        .listen(
          (promotions) {
            _promotions = promotions;
            notifyListeners();
          },
          onError: (e, st) {
            _logger.severe('Error al cargar promociones', e, st);
          },
        );
  }

  bool _isOverviewEmpty(StatisticsOverview? overview) {
    return overview == null ||
        (overview.dailySales.isEmpty &&
            overview.topProducts.isEmpty &&
            overview.frequentCustomers.isEmpty);
  }

  Future<void> _cancelOrdersSubscription() async {
    await _ordersSubscription?.cancel();
    _ordersSubscription = null;
  }

  Future<void> _cancelPromotionsSubscription() async {
    await _promotionsSubscription?.cancel();
    _promotionsSubscription = null;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    if (_errorMessage == message) return;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _promotionsSubscription?.cancel();
    super.dispose();
  }
}








