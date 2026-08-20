import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/workout/workout.dart';
import '../application/history_providers.dart';
import 'workout_detail_screen.dart';
import 'workout_formatters.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cronologia')),
      body: workouts.when(
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyHistoryState();
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _WorkoutListItem(workout: items[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return const Center(
            child: Text('Impossibile caricare la cronologia.'),
          );
        },
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 48),
            SizedBox(height: 16),
            Text('Nessuna attività registrata'),
            SizedBox(height: 8),
            Text(
              'Le attività salvate appariranno qui dopo la registrazione.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutListItem extends StatelessWidget {
  const _WorkoutListItem({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(formatWorkoutDateTime(workout.startedAt)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              Text(formatWorkoutDuration(workout.duration)),
              Text(formatWorkoutDistance(workout.distanceMeters)),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => WorkoutDetailScreen(workout: workout),
          ),
        );
      },
    );
  }
}
