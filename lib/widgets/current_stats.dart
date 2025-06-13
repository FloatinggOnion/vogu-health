import 'package:flutter/material.dart';
import 'package:vogu_health/models/health_data.dart';
import 'package:vogu_health/screens/home_screen.dart';

class CurrentStats extends StatelessWidget {
  const CurrentStats({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = context.findAncestorStateOfType<HomeScreenState>()?.widget.apiService;

    if (apiService == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Error: API service not found'),
        ),
      );
    }

    return FutureBuilder<HealthMetrics>(
      future: apiService.getDailyMetrics(DateTime.now()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error loading current stats',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final metrics = snapshot.data;
        if (metrics == null || metrics.heartRate.isEmpty && metrics.sleep.isEmpty && metrics.weight.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No data available for today'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Stats',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    if (metrics.heartRate.isNotEmpty)
                      _buildStatCard(
                        context,
                        icon: Icons.favorite,
                        title: 'Heart Rate',
                        value: '${metrics.heartRate.last.value} BPM',
                        subtitle: metrics.heartRate.last.restingRate != null
                            ? 'Resting: ${metrics.heartRate.last.restingRate} BPM'
                            : null,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    if (metrics.sleep.isNotEmpty)
                      _buildStatCard(
                        context,
                        icon: Icons.bedtime,
                        title: 'Sleep',
                        value: _formatDuration(
                          metrics.sleep.last.endTime.difference(metrics.sleep.last.startTime),
                        ),
                        subtitle: 'Quality: ${metrics.sleep.last.quality}%',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    if (metrics.weight.isNotEmpty)
                      _buildStatCard(
                        context,
                        icon: Icons.monitor_weight,
                        title: 'Weight',
                        value: '${metrics.weight.last.value.toStringAsFixed(1)} kg',
                        subtitle: metrics.weight.last.bmi != null
                            ? 'BMI: ${metrics.weight.last.bmi!.toStringAsFixed(1)}'
                            : null,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                  ],
                ),
                if (metrics.sleep.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Sleep Phases',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildPhaseChip(
                        context,
                        label: 'Deep',
                        value: metrics.sleep.last.phases.deep,
                        color: Colors.blue,
                      ),
                      _buildPhaseChip(
                        context,
                        label: 'Light',
                        value: metrics.sleep.last.phases.light,
                        color: Colors.green,
                      ),
                      _buildPhaseChip(
                        context,
                        label: 'REM',
                        value: metrics.sleep.last.phases.rem,
                        color: Colors.purple,
                      ),
                      _buildPhaseChip(
                        context,
                        label: 'Awake',
                        value: metrics.sleep.last.phases.awake,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
                if (metrics.weight.isNotEmpty && metrics.weight.last.bodyComposition != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Body Composition',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildCompositionChip(
                        context,
                        label: 'Body Fat',
                        value: metrics.weight.last.bodyComposition!.bodyFat,
                        color: Colors.red,
                      ),
                      _buildCompositionChip(
                        context,
                        label: 'Muscle',
                        value: metrics.weight.last.bodyComposition!.muscleMass,
                        color: Colors.green,
                      ),
                      _buildCompositionChip(
                        context,
                        label: 'Water',
                        value: metrics.weight.last.bodyComposition!.waterPercentage,
                        color: Colors.blue,
                      ),
                      if (metrics.weight.last.bodyComposition!.boneMass != null)
                        _buildCompositionChip(
                          context,
                          label: 'Bone',
                          value: metrics.weight.last.bodyComposition!.boneMass!,
                          color: Colors.brown,
                          unit: 'kg',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseChip(
    BuildContext context, {
    required String label,
    required int value,
    required Color color,
  }) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Text(
          label[0],
          style: TextStyle(color: color),
        ),
      ),
      label: Text('$label: ${_formatDuration(Duration(minutes: value))}'),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  Widget _buildCompositionChip(
    BuildContext context, {
    required String label,
    required double value,
    required Color color,
    String unit = '%',
  }) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Text(
          label[0],
          style: TextStyle(color: color),
        ),
      ),
      label: Text('$label: ${value.toStringAsFixed(1)}$unit'),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes m' : ''}';
    }
    return '$minutes m';
  }
} 