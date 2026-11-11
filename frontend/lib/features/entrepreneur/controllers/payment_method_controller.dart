import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/utils/friendly_error_message.dart';
import 'package:emprendedor/data/models/entrepreneur/payments/payment_method_model.dart';
import 'package:emprendedor/data/repositories/entrepreneur/payments/payment_method_repository.dart';

class PaymentMethodController extends ChangeNotifier {
  final Logger _logger = Logger('PaymentMethodController');
  final PaymentMethodRepository _repository = PaymentMethodRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<PaymentMethodModel> _paymentMethods = [];
  List<PaymentMethodModel> get paymentMethods => _paymentMethods;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<List<PaymentMethodModel>>? _subscription;
  String? _userId;

  String? get userId => _userId;

  Future<void> setUserId(String? userId) async {
    if (_userId == userId) return;

    await _subscription?.cancel();
    _subscription = null;

    _userId = userId;
    _paymentMethods = [];
    _errorMessage = null;

    if (_userId == null || _userId!.trim().isEmpty) {
      _setLoading(false);
      notifyListeners();
      return;
    }

    await fetchPaymentMethods();
  }

  Future<void> reset() async {
    await _subscription?.cancel();
    _subscription = null;

    _paymentMethods = [];
    _errorMessage = null;
    _isLoading = false;
    _userId = null;

    notifyListeners();
  }

  Future<void> fetchPaymentMethods() async {
    final uid = _userId ?? _auth.currentUser?.uid;

    if (uid == null || uid.trim().isEmpty) {
      _setError('Usuario no autenticado.');
      return;
    }

    _userId = uid;

    _setLoading(true);
    _clearError();

    await _subscription?.cancel();
    _subscription = null;

    try {
      _subscription = _repository
          .getPaymentMethods(uid)
          .listen(
            (data) {
              _paymentMethods = data;
              _setLoading(false);
              notifyListeners();
            },
            onError: (error, stackTrace) {
              _logger.severe('Error métodos de pago', error, stackTrace);
              _paymentMethods = [];
              _setError('Error al cargar métodos de pago.');
              _setLoading(false);
            },
          );
    } catch (e, st) {
      _logger.severe('Excepcion métodos de pago', e, st);
      _setError('Error al iniciar carga.');
      _setLoading(false);
    }
  }

  Future<bool> addPaymentMethod(PaymentMethodModel paymentMethod) async {
    final uid = _userId ?? _auth.currentUser?.uid;

    if (uid == null || uid.trim().isEmpty) {
      _setError('Usuario no autenticado.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository.addPaymentMethod(
        uid,
        paymentMethod.copyWith(userId: uid),
      );
      return true;
    } catch (e, st) {
      _logger.severe('Error agregando método', e, st);
      _setError('No se pudo agregar el método. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePaymentMethod(PaymentMethodModel paymentMethod) async {
    final uid = _userId ?? _auth.currentUser?.uid;

    if (uid == null || uid.trim().isEmpty) {
      _setError('Usuario no autenticado.');
      return false;
    }

    if (paymentMethod.id == null || paymentMethod.id!.trim().isEmpty) {
      _setError('No se pudo identificar el método de pago.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository.updatePaymentMethod(
        uid,
        paymentMethod.copyWith(userId: uid),
      );
      return true;
    } catch (e, st) {
      _logger.severe('Error actualizando método', e, st);
      _setError('No se pudo actualizar el método. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePaymentMethod(String docId) async {
    final uid = _userId ?? _auth.currentUser?.uid;

    if (uid == null || uid.trim().isEmpty) {
      _setError('Usuario no autenticado.');
      return false;
    }

    if (docId.trim().isEmpty) {
      _setError('No se pudo identificar el método de pago.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository.deletePaymentMethod(uid, docId);
      return true;
    } catch (e, st) {
      _logger.severe('Error eliminando método', e, st);
      _setError('No se pudo eliminar el método. ${friendlyErrorMessage(e)}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _clearError();
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
    _subscription?.cancel();
    super.dispose();
  }
}
