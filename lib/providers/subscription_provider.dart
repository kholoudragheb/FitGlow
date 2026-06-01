import 'package:flutter/foundation.dart';
import '../models/subscription_status_model.dart';
import '../services/subscription_service.dart';

/// Global state that any widget can read via:
///   `context.watch<SubscriptionProvider>().status`
///   `context.read<SubscriptionProvider>().refresh()`
class SubscriptionProvider extends ChangeNotifier {
  final _service = SubscriptionService();

  SubscriptionStatusModel _status = SubscriptionStatusModel.none();
  bool _isLoading = false;
  String? _error;

  // ── Public getters ──────────────────────────────────────────────────────────

  SubscriptionStatusModel get status => _status;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isActive => _status.isActive;
  bool get isCanceled => _status.isCanceled;

  // ── API call ────────────────────────────────────────────────────────────────

  /// Fetch the latest subscription status from the backend and notify listeners.
  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getSubscriptionStatus();
      _status = result;
      debugPrint('[SubscriptionProvider] Status refreshed → ${_status.subscriptionStatus}');
    } catch (e) {
      _error = e.toString();
      debugPrint('[SubscriptionProvider] Error refreshing status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optimistically mark as canceled without waiting for an API round-trip.
  /// Call after a successful cancelSubscription() API response.
  void markCanceled() {
    _status = SubscriptionStatusModel(
      subscriptionStatus: 'canceled',
      subscribedCoachId: _status.subscribedCoachId,
      subscriptionId: _status.subscriptionId,
    );
    notifyListeners();
  }

  /// Optimistically mark as active.
  /// Call after a successful confirmSubscription() API response.
  void markActive({String? coachId, String? subscriptionId}) {
    _status = SubscriptionStatusModel(
      subscriptionStatus: 'active',
      subscribedCoachId: coachId ?? _status.subscribedCoachId,
      subscriptionId: subscriptionId ?? _status.subscriptionId,
    );
    notifyListeners();
  }
}
