import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../history/presentation/history_screen.dart';
import '../../history/presentation/workout_formatters.dart';
import '../../map/presentation/tracking_map.dart';
import '../application/tracking_providers.dart';
import '../application/tracking_save_result.dart';
import '../application/tracking_state.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key, this.showHistoryButton = true});

  final bool showHistoryButton;

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  Timer? _elapsedTimer;

  @override
  void dispose() {
    _cancelElapsedTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingControllerProvider);
    _syncElapsedTimer(trackingState);

    final locationMessage = ref.watch(trackingLocationMessageProvider);
    final controller = ref.read(trackingControllerProvider.notifier);
    final now = ref.read(trackingClockProvider)().toUtc();
    final elapsed = controller.elapsedAt(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attività'),
        actions: [
          if (widget.showHistoryButton)
            IconButton(
              tooltip: 'Apri cronologia',
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: TrackingMap(
              routePoints: trackingState.routePoints,
              showUserLocation: false,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _TrackingControlSheet(
              state: trackingState,
              elapsed: elapsed,
              locationMessage: locationMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _syncElapsedTimer(TrackingState trackingState) {
    if (trackingState.isRunning) {
      _elapsedTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) {
          return;
        }

        if (!ref.read(trackingControllerProvider).isRunning) {
          _cancelElapsedTimer();
          return;
        }

        setState(() {});
      });
      return;
    }

    _cancelElapsedTimer();
  }

  void _cancelElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }
}

class _TrackingControlSheet extends StatelessWidget {
  const _TrackingControlSheet({
    required this.state,
    required this.elapsed,
    required this.locationMessage,
  });

  final TrackingState state;
  final Duration elapsed;
  final String? locationMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sheetMaxHeight = MediaQuery.sizeOf(context).height * 0.52;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      elevation: 8,
      shadowColor: colorScheme.shadow,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: sheetMaxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const SizedBox(width: 40, height: 4),
                  ),
                ),
                const SizedBox(height: 16),
                _TrackingStatusHeader(status: state.status),
                const SizedBox(height: 18),
                _TrackingMetricsRow(
                  elapsed: elapsed,
                  distanceMeters: state.distanceMeters,
                ),
                if (locationMessage != null) ...[
                  const SizedBox(height: 14),
                  _LocationMessageBanner(message: locationMessage!),
                ],
                const SizedBox(height: 18),
                _TrackingActions(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackingStatusHeader extends StatelessWidget {
  const _TrackingStatusHeader({required this.status});

  final TrackingStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sessione corrente', style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Stato',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        _StatusPill(label: _statusLabel(status)),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          label,
          key: const Key('tracking-status-text'),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _TrackingMetricsRow extends StatelessWidget {
  const _TrackingMetricsRow({
    required this.elapsed,
    required this.distanceMeters,
  });

  final Duration elapsed;
  final double distanceMeters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        final spacing = compact ? 12.0 : 16.0;
        final itemWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: 12,
          children: [
            SizedBox(
              width: itemWidth,
              child: _MetricItem(
                label: 'Tempo',
                value: _formatDuration(elapsed),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricItem(
                label: 'Distanza',
                value: formatWorkoutDistance(distanceMeters),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: textTheme.titleLarge),
        ),
      ],
    );
  }
}

class _TrackingActions extends ConsumerWidget {
  const _TrackingActions({required this.state});

  final TrackingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(trackingControllerProvider.notifier);

    if (state.isStopped) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          key: const Key('tracking-start-button'),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Avvia attività'),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final result = await controller.start();
            if (!messenger.mounted || result.message == null) {
              return;
            }

            _showTrackingFeedback(messenger, result.message!);
          },
        ),
      );
    }

    if (state.isPaused) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: const Key('tracking-resume-button'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Riprendi'),
                  onPressed: controller.resume,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _StopButton(controller: controller)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            key: const Key('tracking-pause-button'),
            icon: const Icon(Icons.pause),
            label: const Text('Pausa'),
            onPressed: controller.pause,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _StopButton(controller: controller)),
      ],
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({required this.controller});

  final TrackingControllerNotifier controller;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('tracking-stop-button'),
      icon: const Icon(Icons.stop),
      label: const Text('Termina'),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final result = await controller.stopAndSave();
        if (!messenger.mounted) {
          return;
        }

        _showTrackingFeedback(messenger, _saveMessage(result));
      },
    );
  }
}

class _LocationMessageBanner extends StatelessWidget {
  const _LocationMessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

void _showTrackingFeedback(ScaffoldMessengerState messenger, String message) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, key: const Key('tracking-feedback-message')),
      ),
    );
}

String _statusLabel(TrackingStatus status) {
  return switch (status) {
    TrackingStatus.stopped => 'Ferma',
    TrackingStatus.running => 'In corso',
    TrackingStatus.paused => 'In pausa',
  };
}

String _formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final hours = totalSeconds ~/ Duration.secondsPerHour;
  final minutes = (totalSeconds % Duration.secondsPerHour) ~/ 60;
  final seconds = totalSeconds % 60;

  String twoDigits(int value) => value.toString().padLeft(2, '0');

  return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
}

String _saveMessage(TrackingSaveResult result) {
  return switch (result.status) {
    TrackingSaveStatus.saved => 'Attività salvata.',
    TrackingSaveStatus.notSaved => result.message ?? 'Attività non salvata.',
    TrackingSaveStatus.failed =>
      result.message ?? 'Impossibile salvare l\'attività.',
  };
}
