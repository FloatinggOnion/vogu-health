import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogu_health/services/api_service.dart';
import 'package:vogu_health/models/health_data.dart';

class CurrentStats extends StatelessWidget {
  const CurrentStats({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = context.watch<ApiService>();

    return FutureBuilder<HealthMetrics>(
      future: apiService.getDailyMetrics(DateTime.now()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final metrics = snapshot.data;
        if (metrics == null || metrics.heartRate.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final latestHeartRate = metrics.heartRate.first;
        final latestSleep = metrics.sleep.isNotEmpty ? metrics.sleep.first : null;
        final latestWeight = metrics.weight.isNotEmpty ? metrics.weight.first : null;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Stats',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                context,
                'Heart Rate',
                '${latestHeartRate.heartRate} bpm',
                Icons.favorite,
                subtitle: 'Resting: ${latestHeartRate.restingHeartRate} bpm',
              ),
              const SizedBox(height: 8),
              if (latestSleep != null) ...[
                _buildStatCard(
                  context,
                  'Sleep',
                  '${(latestSleep.totalSleepTime / 60).toStringAsFixed(1)} hours',
                  Icons.bedtime,
                  subtitle: 'Quality: ${latestSleep.sleepQuality}%',
                ),
                const SizedBox(height: 8),
              ],
              if (latestWeight != null)
                _buildStatCard(
                  context,
                  'Weight',
                  '${latestWeight.weight} kg',
                  Icons.monitor_weight,
                  subtitle: 'BMI: ${latestWeight.bmi.toStringAsFixed(1)}',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 