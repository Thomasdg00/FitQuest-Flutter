import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/workout/workout_repository_provider.dart';
import '../../history/application/history_providers.dart';
import '../data/geolocator_location_tracker.dart';
import '../domain/location_fix.dart';
import '../domain/location_tracker.dart';
import 'finalized_tracking_session.dart';
import 'tracking_controller.dart';
import 'tracking_save_result.dart';
import 'tracking_state.dart';

final locationTrackerProvider = Provider<LocationTracker>((ref) {
  return const GeolocatorLocationTracker();
});

final trackingClockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final trackingLocationMessageProvider = StateProvider<String?>((ref) => null);

final trackingControllerProvider =
    NotifierProvider<TrackingControllerNotifier, TrackingState>(
      TrackingControllerNotifier.new,
    );

class TrackingStartResult {
  const TrackingStartResult({required this.availability, this.message});

  final LocationTrackingAvailability availability;
  final String? message;
}

class TrackingControllerNotifier extends Notifier<TrackingState> {
  late TrackingController _controller;
  StreamSubscription<LocationFix>? _locationSubscription;

  @override
  TrackingState build() {
    _controller = TrackingController(clock: ref.read(trackingClockProvider));
    ref.onDispose(() {
      final subscription = _locationSubscription;
      _locationSubscription = null;
      if (subscription != null) {
        unawaited(subscription.cancel());
      }
    });
    return _controller.state;
  }

  Future<TrackingStartResult> start() async {
    if (!_controller.state.isStopped) {
      return const TrackingStartResult(
        availability: LocationTrackingAvailability.available,
      );
    }

    _clearLocationMessage();
    _controller.start();
    _sync();

    return _startLocationTracking();
  }

  void pause() {
    _controller.pause();
    _sync();
  }

  void resume() {
    _controller.resume();
    _sync();
  }

  Future<FinalizedTrackingSession?> stop() async {
    final session = _controller.stop();
    _clearLocationMessage();
    _sync();
    _cancelLocationSubscriptionInBackground();
    return session;
  }

  Future<TrackingSaveResult> stopAndSave() async {
    final session = _controller.stop();
    _clearLocationMessage();
    _sync();
    _cancelLocationSubscriptionInBackground();
    if (session == null) {
      return TrackingSaveResult.notSaved('Nessuna attività attiva da salvare.');
    }

    if (session.routePoints.isEmpty && session.distanceMeters == 0) {
      return TrackingSaveResult.notSaved('Attività vuota non salvata.');
    }

    try {
      final workoutId = await session.save(ref.read(workoutRepositoryProvider));
      ref.invalidate(workoutHistoryProvider);
      return TrackingSaveResult.saved(
        workoutId: workoutId,
        routePointCount: session.routePoints.length,
      );
    } catch (_) {
      return TrackingSaveResult.failed();
    }
  }

  Duration elapsedAt(DateTime timestamp) {
    return _controller.elapsedAt(timestamp);
  }

  Future<TrackingStartResult> _startLocationTracking() async {
    await _cancelLocationSubscription();

    final tracker = ref.read(locationTrackerProvider);
    final availability = await _ensureLocationAvailable(tracker);
    if (availability != LocationTrackingAvailability.available) {
      return _storeAvailabilityMessage(availability);
    }

    if (!_controller.state.isRunning) {
      return const TrackingStartResult(
        availability: LocationTrackingAvailability.available,
      );
    }

    try {
      _locationSubscription = tracker.positionStream.listen(
        _recordLocationFix,
        onError: _handleLocationStreamError,
      );
    } catch (_) {
      const message =
          'Aggiornamenti posizione interrotti. Controlla il GPS e riprova.';
      _setLocationMessage(message);
      return const TrackingStartResult(
        availability: LocationTrackingAvailability.unavailable,
        message: message,
      );
    }

    _clearLocationMessage();
    return const TrackingStartResult(
      availability: LocationTrackingAvailability.available,
    );
  }

  Future<LocationTrackingAvailability> _ensureLocationAvailable(
    LocationTracker tracker,
  ) async {
    final currentAvailability = await _checkLocationAvailability(tracker);
    if (currentAvailability != LocationTrackingAvailability.permissionDenied) {
      return currentAvailability;
    }

    return _requestLocationPermission(tracker);
  }

  Future<LocationTrackingAvailability> _checkLocationAvailability(
    LocationTracker tracker,
  ) async {
    try {
      return await tracker.checkAvailability();
    } catch (_) {
      return LocationTrackingAvailability.unavailable;
    }
  }

  Future<LocationTrackingAvailability> _requestLocationPermission(
    LocationTracker tracker,
  ) async {
    try {
      return await tracker.requestPermission();
    } catch (_) {
      return LocationTrackingAvailability.unavailable;
    }
  }

  void _recordLocationFix(LocationFix fix) {
    if (!_controller.state.isRunning) {
      return;
    }

    final accepted = _controller.recordPoint(
      latitude: fix.latitude,
      longitude: fix.longitude,
      at: fix.timestamp.toUtc(),
    );

    if (accepted) {
      _sync();
    }
  }

  void _handleLocationStreamError(Object error, StackTrace stackTrace) {
    _setLocationMessage(
      'Aggiornamenti posizione interrotti. Controlla il GPS e riprova.',
    );
    final subscription = _locationSubscription;
    _locationSubscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
  }

  TrackingStartResult _storeAvailabilityMessage(
    LocationTrackingAvailability availability,
  ) {
    final message = _messageForAvailability(availability);
    _setLocationMessage(message);
    return TrackingStartResult(availability: availability, message: message);
  }

  String _messageForAvailability(LocationTrackingAvailability availability) {
    return switch (availability) {
      LocationTrackingAvailability.available => '',
      LocationTrackingAvailability.serviceDisabled =>
        'Servizio di posizione disattivato. Attiva il GPS per tracciare il percorso.',
      LocationTrackingAvailability.permissionDenied =>
        'Permesso di posizione negato. Concedi il permesso per tracciare il percorso.',
      LocationTrackingAvailability.permissionDeniedForever =>
        'Permesso di posizione negato in modo permanente. Attivalo dalle impostazioni Android per tracciare il percorso.',
      LocationTrackingAvailability.unavailable =>
        'Posizione non disponibile. Controlla il GPS e riprova.',
    };
  }

  void _setLocationMessage(String message) {
    ref.read(trackingLocationMessageProvider.notifier).state = message;
  }

  void _clearLocationMessage() {
    ref.read(trackingLocationMessageProvider.notifier).state = null;
  }

  Future<void> _cancelLocationSubscription() async {
    final subscription = _locationSubscription;
    _locationSubscription = null;
    if (subscription != null) {
      await subscription.cancel();
    }
  }

  void _cancelLocationSubscriptionInBackground() {
    final subscription = _locationSubscription;
    _locationSubscription = null;
    if (subscription != null) {
      unawaited(_cancelIgnoringErrors(subscription));
    }
  }

  Future<void> _cancelIgnoringErrors(
    StreamSubscription<LocationFix> subscription,
  ) async {
    try {
      await subscription.cancel();
    } catch (_) {
      // Stop must never fail or remain running because stream cancellation failed.
    }
  }

  void _sync() {
    state = _controller.state;
  }
}
