import 'dart:async';

import 'package:fuodz/requests/provider_location.request.dart';
import 'package:geolocator/geolocator.dart';

/// Shares the provider's live GPS with the backend **only while an active Assist
/// operation is in progress**. Jobs register with [startForOrder] (on accept /
/// en-route / arrived / start) and deregister with [stopForOrder] (on complete /
/// cancel); when no active job remains the position stream is torn down, so an
/// idle or offline provider is never tracked. Foreground sharing — it runs while
/// the app is active during the job, not in the background.
class ProviderLocationService {
  ProviderLocationService._();
  static final ProviderLocationService instance = ProviderLocationService._();

  final Set<int> _activeOrderIds = {};
  StreamSubscription<Position>? _sub;
  bool _starting = false;

  bool get isSharing => _sub != null;

  /// Begin (or keep) sharing for an active Assist job.
  Future<void> startForOrder(int orderId) async {
    _activeOrderIds.add(orderId);
    if (_sub != null || _starting) return; // already streaming
    _starting = true;
    try {
      if (!await _ensurePermission()) {
        return; // permission denied -> share nothing, no error surfaced
      }
      // Push one immediate fix so the provider appears on the map promptly.
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await _send(pos);
      } catch (_) {}

      _sub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 25, // metres — avoids excessive writes/battery
        ),
      ).listen(_send, onError: (_) {});
    } finally {
      _starting = false;
    }
  }

  /// Stop sharing for a finished/cancelled job; tears down the stream when none remain.
  Future<void> stopForOrder(int orderId) async {
    _activeOrderIds.remove(orderId);
    if (_activeOrderIds.isEmpty) {
      await _teardown();
    }
  }

  /// Hard stop — e.g. on logout or when the provider goes offline.
  Future<void> stopAll() async {
    _activeOrderIds.clear();
    await _teardown();
  }

  Future<void> _teardown() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> _send(Position pos) async {
    try {
      await ProviderLocationRequest().syncLocation(
        lat: pos.latitude,
        lng: pos.longitude,
        rotation: pos.heading,
      );
    } catch (_) {
      // best-effort: a failed sync must never disrupt the job flow
    }
  }

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always || perm == LocationPermission.whileInUse;
  }
}
