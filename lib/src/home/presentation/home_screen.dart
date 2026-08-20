import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/workout/workout.dart';
import '../../goals/domain/weekly_goal_progress.dart';
import '../../history/application/history_providers.dart';
import '../../history/presentation/workout_formatters.dart';
import '../application/home_goal_controller.dart';
import '../application/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.onStartTracking});

  final VoidCallback? onStartTracking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(weeklyGoalProgressProvider);

    Future<void> editWeeklyGoal({
      required DateTime weekStartDate,
      double? initialTargetMeters,
    }) async {
      final targetKm = await _showWeeklyGoalDialog(
        context: context,
        initialTargetMeters: initialTargetMeters,
      );

      if (targetKm == null || !context.mounted) {
        return;
      }

      await ref
          .read(homeGoalControllerProvider)
          .setGoalForWeek(weekStartDate: weekStartDate, targetKm: targetKm);

      if (!context.mounted) {
        return;
      }
      ref.invalidate(weeklyGoalProgressProvider);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Inizio')),
      body: progress.when(
        data: (value) {
          return _HomeContent(
            progress: value,
            onStartTracking: onStartTracking,
            onEditWeeklyGoal: editWeeklyGoal,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return const Center(
            child: Text('Impossibile caricare l\'obiettivo settimanale.'),
          );
        },
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({
    required this.progress,
    required this.onStartTracking,
    required this.onEditWeeklyGoal,
  });

  final WeeklyGoalProgress progress;
  final VoidCallback? onStartTracking;
  final Future<void> Function({
    required DateTime weekStartDate,
    double? initialTargetMeters,
  })
  onEditWeeklyGoal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutHistoryProvider);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _StartTrackingCard(onStartTracking: onStartTracking),
          const SizedBox(height: 24),
          Text('Obiettivo settimanale', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          if (!progress.hasGoal)
            _EmptyGoalState(
              onSetGoal: () =>
                  onEditWeeklyGoal(weekStartDate: progress.weekStartDate),
            )
          else
            _GoalProgressCard(
              progress: progress,
              onEditGoal: () => onEditWeeklyGoal(
                weekStartDate: progress.weekStartDate,
                initialTargetMeters: progress.targetDistanceMeters,
              ),
            ),
          const SizedBox(height: 24),
          Text('Attività recente', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          workouts.when(
            data: (items) => _RecentActivityCard(workouts: items),
            loading: () => const _RecentActivityLoadingCard(),
            error: (error, stackTrace) => const _RecentActivityErrorCard(),
          ),
        ],
      ),
    );
  }
}

class _StartTrackingCard extends StatelessWidget {
  const _StartTrackingCard({required this.onStartTracking});

  final VoidCallback? onStartTracking;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.directions_run,
              color: colorScheme.onPrimaryContainer,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Pronto per la prossima attività?',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Apri la schermata attività per registrare distanza, durata e percorso.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('home-start-tracking-button'),
              onPressed: onStartTracking,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Avvia attività'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGoalState extends StatelessWidget {
  const _EmptyGoalState({required this.onSetGoal});

  final Future<void> Function() onSetGoal;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.flag_outlined, size: 40),
            const SizedBox(height: 12),
            Text(
              'Nessun obiettivo settimanale impostato',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Imposta un obiettivo di distanza per questa settimana.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Imposta obiettivo'),
              onPressed: onSetGoal,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({required this.progress, required this.onEditGoal});

  final WeeklyGoalProgress progress;
  final Future<void> Function() onEditGoal;

  @override
  Widget build(BuildContext context) {
    final percent = (progress.progressRatio * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${formatWorkoutDistance(progress.targetDistanceMeters)} obiettivo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('$percent%'),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress.progressRatio),
            const SizedBox(height: 16),
            Text(
              '${formatWorkoutDistance(progress.completedDistanceMeters)} percorsi',
            ),
            const SizedBox(height: 8),
            if (progress.isCompleted)
              const Text('Obiettivo settimanale raggiunto')
            else
              Text(
                '${formatWorkoutDistance(progress.remainingDistanceMeters)} rimanenti',
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Modifica obiettivo'),
                onPressed: onEditGoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.workouts});

  final List<Workout> workouts;

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return const _EmptyRecentActivityCard();
    }

    return _LatestWorkoutCard(workout: workouts.first);
  }
}

class _LatestWorkoutCard extends StatelessWidget {
  const _LatestWorkoutCard({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Ultima attività', style: textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(formatWorkoutDateTime(workout.startedAt)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _WorkoutSummaryItem(
                  icon: Icons.straighten,
                  label: 'Distanza',
                  value: formatWorkoutDistance(workout.distanceMeters),
                ),
                _WorkoutSummaryItem(
                  icon: Icons.timer_outlined,
                  label: 'Durata',
                  value: formatWorkoutDuration(workout.duration),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutSummaryItem extends StatelessWidget {
  const _WorkoutSummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(value, style: textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class _EmptyRecentActivityCard extends StatelessWidget {
  const _EmptyRecentActivityCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.directions_run_outlined, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nessuna attività registrata',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Avvia la tua prima attività.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityLoadingCard extends StatelessWidget {
  const _RecentActivityLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _RecentActivityErrorCard extends StatelessWidget {
  const _RecentActivityErrorCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Impossibile caricare l\'attività recente.'),
      ),
    );
  }
}

Future<double?> _showWeeklyGoalDialog({
  required BuildContext context,
  double? initialTargetMeters,
}) {
  return showDialog<double>(
    context: context,
    builder: (_) {
      return _WeeklyGoalDialog(initialTargetMeters: initialTargetMeters);
    },
  );
}

class _WeeklyGoalDialog extends StatefulWidget {
  const _WeeklyGoalDialog({this.initialTargetMeters});

  final double? initialTargetMeters;

  @override
  State<_WeeklyGoalDialog> createState() => _WeeklyGoalDialogState();
}

class _WeeklyGoalDialogState extends State<_WeeklyGoalDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  bool get _isEditing => widget.initialTargetMeters != null;

  @override
  void initState() {
    super.initState();
    final initialTargetMeters = widget.initialTargetMeters;
    _controller = TextEditingController(
      text: initialTargetMeters == null
          ? ''
          : _formatGoalInput(initialTargetMeters / 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final errorText = _validateGoalKm(_controller.text);
    if (errorText != null) {
      setState(() {
        _errorText = errorText;
      });
      return;
    }

    final targetKm = _parseGoalKm(_controller.text);
    if (targetKm == null) {
      setState(() {
        _errorText = 'Inserisci una distanza valida.';
      });
      return;
    }

    Navigator.of(context).pop(targetKm);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing
            ? 'Modifica obiettivo settimanale'
            : 'Imposta obiettivo settimanale',
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: 'Distanza obiettivo',
          suffixText: 'km',
          errorText: _errorText,
        ),
        onChanged: (_) {
          if (_errorText != null) {
            setState(() {
              _errorText = null;
            });
          }
        },
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        TextButton(onPressed: _save, child: const Text('Salva')),
      ],
    );
  }
}

String? _validateGoalKm(String? value) {
  final input = value?.trim() ?? '';
  if (input.isEmpty) {
    return 'Inserisci una distanza in km.';
  }

  final targetKm = _parseGoalKm(input);
  if (targetKm == null || !targetKm.isFinite) {
    return 'Inserisci una distanza valida.';
  }
  if (targetKm <= 0) {
    return 'Inserisci una distanza maggiore di 0.';
  }

  return null;
}

double? _parseGoalKm(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.'));
}

String _formatGoalInput(double kilometers) {
  final fixed = kilometers.toStringAsFixed(2);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}
