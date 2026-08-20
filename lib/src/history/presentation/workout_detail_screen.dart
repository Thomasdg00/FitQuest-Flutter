import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/workout/workout_repository_provider.dart';
import '../../domain/workout/route_point.dart';
import '../../domain/workout/workout.dart';
import '../../map/presentation/tracking_map.dart';
import '../application/history_providers.dart';
import 'workout_formatters.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({required this.workout, super.key});

  final Workout workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutId = workout.id;
    final routePoints = workoutId == null
        ? null
        : ref.watch(workoutRoutePointsProvider(workoutId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio attività'),
        actions: [
          if (workoutId != null)
            IconButton(
              key: const Key('delete-workout-button'),
              tooltip: 'Elimina attività',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref, workoutId),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SummarySection(workout: workout),
          const SizedBox(height: 24),
          Text(
            'Percorso salvato',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (routePoints == null)
            const _EmptyRouteState(
              message: 'Nessun percorso salvato per questa attività.',
            )
          else
            routePoints.when(
              data: (points) => _RoutePointSection(points: points),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                return const Text('Impossibile caricare il percorso salvato.');
              },
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int workoutId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminare attività?'),
          content: const Text(
            'Questa operazione eliminerà anche il percorso salvato.',
          ),
          actions: [
            TextButton(
              key: const Key('cancel-delete-workout-button'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              key: const Key('confirm-delete-workout-button'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await ref.read(workoutRepositoryProvider).deleteWorkout(workoutId);
      ref.invalidate(workoutHistoryProvider);
      ref.invalidate(workoutRoutePointsProvider(workoutId));

      if (!context.mounted) {
        return;
      }

      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Attività eliminata.')),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(
        const SnackBar(content: Text("Impossibile eliminare l'attività.")),
      );
    }
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatWorkoutDateTime(workout.startedAt),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _SummaryRow(
          label: 'Durata',
          value: formatWorkoutDuration(workout.duration),
        ),
        _SummaryRow(
          label: 'Distanza',
          value: formatWorkoutDistance(workout.distanceMeters),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _RoutePointSection extends StatelessWidget {
  const _RoutePointSection({required this.points});

  final List<RoutePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const _EmptyRouteState(
        message: 'Nessun percorso salvato per questa attività.',
      );
    }

    return CompletedRouteMap(routePoints: points);
  }
}

class _EmptyRouteState extends StatelessWidget {
  const _EmptyRouteState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(message);
  }
}
