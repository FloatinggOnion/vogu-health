import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogu_health/providers/health_api_provider.dart';
import 'package:vogu_health/models/api_models.dart';
import 'package:intl/intl.dart';

class HealthDataDashboard extends StatefulWidget {
  const HealthDataDashboard({Key? key}) : super(key: key);

  @override
  _HealthDataDashboardState createState() => _HealthDataDashboardState();
}

class _HealthDataDashboardState extends State<HealthDataDashboard> {
  @override
  void initState() {
    super.initState();
    // Initialize the provider when the widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthApiProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Data Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HealthApiProvider>().refreshAllData();
            },
          ),
        ],
      ),
      body: Consumer<HealthApiProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorWidget(provider);
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshAllData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConnectionStatus(provider),
                  const SizedBox(height: 16),
                  _buildQuickActions(provider),
                  const SizedBox(height: 24),
                  _buildInsightsSection(provider),
                  const SizedBox(height: 24),
                  _buildDailySummarySection(provider),
                  const SizedBox(height: 24),
                  _buildHealthDataSection(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatus(HealthApiProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              provider.isConnected ? Icons.check_circle : Icons.error,
              color: provider.isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              provider.isConnected ? 'Connected to API' : 'API Connection Failed',
              style: TextStyle(
                color: provider.isConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (!provider.isConnected)
              ElevatedButton(
                onPressed: () => provider.testConnection(),
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(HealthApiProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSubmitSleepDialog(provider),
                    icon: const Icon(Icons.bedtime),
                    label: const Text('Add Sleep'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSubmitHeartRateDialog(provider),
                    icon: const Icon(Icons.favorite),
                    label: const Text('Add Heart Rate'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSubmitWeightDialog(provider),
                    icon: const Icon(Icons.monitor_weight),
                    label: const Text('Add Weight'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => provider.loadTodayComplete(),
                    icon: const Icon(Icons.today),
                    label: const Text('Today\'s Data'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(HealthApiProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'AI Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => provider.loadRecentInsights(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.recentInsights != null) ...[
              _buildInsightCard(provider.recentInsights!),
            ] else ...[
              const Center(
                child: Text('No insights available. Tap "Refresh" to load.'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(HealthInsights insights) {
    Color statusColor;
    switch (insights.status) {
      case 'good':
        statusColor = Colors.green;
        break;
      case 'fair':
        statusColor = Colors.orange;
        break;
      case 'poor':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.psychology, color: statusColor),
            const SizedBox(width: 8),
            Text(
              'Status: ${insights.status.toUpperCase()}',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(insights.summary),
        if (insights.highlights.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Highlights:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...insights.highlights.map((highlight) => 
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(highlight)),
                ],
              ),
            ),
          ),
        ],
        if (insights.recommendations.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Recommendations:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...insights.recommendations.map((recommendation) => 
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(child: Text(recommendation)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          'Next Steps: ${insights.nextSteps}',
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildDailySummarySection(HealthApiProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Today\'s Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => provider.loadTodaySummary(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.dailySummary != null) ...[
              _buildDailySummaryCard(provider.dailySummary!),
            ] else ...[
              const Center(
                child: Text('No daily summary available. Tap "Refresh" to load.'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummaryCard(DailyHealthData summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Sleep',
                provider.dailySummary!.sleep.length.toString(),
                Icons.bedtime,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Heart Rate',
                provider.dailySummary!.heartRate.length.toString(),
                Icons.favorite,
                Colors.red,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Weight',
                provider.dailySummary!.weight.length.toString(),
                Icons.monitor_weight,
                Colors.green,
              ),
            ),
          ],
        ),
        if (provider.dailySummary!.sleep.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Latest Sleep:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildSleepDataTile(provider.dailySummary!.sleep.first),
        ],
        if (provider.dailySummary!.heartRate.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Latest Heart Rate:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildHeartRateDataTile(provider.dailySummary!.heartRate.first),
        ],
        if (provider.dailySummary!.weight.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Latest Weight:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildWeightDataTile(provider.dailySummary!.weight.first),
        ],
      ],
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHealthDataSection(HealthApiProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Health Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => provider.loadAllHealthData(days: 7),
                    child: const Text('Load 7 Days'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => provider.loadAllHealthData(days: 30),
                    child: const Text('Load 30 Days'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.sleepData.isNotEmpty) ...[
              const Text(
                'Sleep Data (${provider.sleepData.length} records):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...provider.sleepData.take(3).map(_buildSleepDataTile),
              if (provider.sleepData.length > 3)
                TextButton(
                  onPressed: () => _showAllDataDialog('Sleep Data', provider.sleepData),
                  child: const Text('View All Sleep Data'),
                ),
            ],
            const SizedBox(height: 16),
            if (provider.heartRateData.isNotEmpty) ...[
              const Text(
                'Heart Rate Data (${provider.heartRateData.length} records):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...provider.heartRateData.take(3).map(_buildHeartRateDataTile),
              if (provider.heartRateData.length > 3)
                TextButton(
                  onPressed: () => _showAllDataDialog('Heart Rate Data', provider.heartRateData),
                  child: const Text('View All Heart Rate Data'),
                ),
            ],
            const SizedBox(height: 16),
            if (provider.weightData.isNotEmpty) ...[
              const Text(
                'Weight Data (${provider.weightData.length} records):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...provider.weightData.take(3).map(_buildWeightDataTile),
              if (provider.weightData.length > 3)
                TextButton(
                  onPressed: () => _showAllDataDialog('Weight Data', provider.weightData),
                  child: const Text('View All Weight Data'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSleepDataTile(SleepDataResponse sleep) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.bedtime, color: Colors.blue),
        title: Text('Quality: ${sleep.quality}%'),
        subtitle: Text(
          '${DateFormat('MMM dd, HH:mm').format(DateTime.parse(sleep.startTime))} - '
          '${DateFormat('HH:mm').format(DateTime.parse(sleep.endTime))}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Deep: ${sleep.deepSleep}min'),
            Text('Light: ${sleep.lightSleep}min'),
            Text('REM: ${sleep.remSleep}min'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateDataTile(HeartRateDataResponse heartRate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.favorite, color: Colors.red),
        title: Text('${heartRate.value} BPM'),
        subtitle: Text(
          DateFormat('MMM dd, HH:mm').format(DateTime.parse(heartRate.timestamp)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (heartRate.restingRate != null)
              Text('Resting: ${heartRate.restingRate} BPM'),
            if (heartRate.activityType != null)
              Text(heartRate.activityType!),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightDataTile(WeightDataResponse weight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.monitor_weight, color: Colors.green),
        title: Text('${weight.value} kg'),
        subtitle: Text(
          DateFormat('MMM dd, HH:mm').format(DateTime.parse(weight.timestamp)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (weight.bmi != null) Text('BMI: ${weight.bmi}'),
            if (weight.bodyFat != null) Text('Fat: ${weight.bodyFat}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(HealthApiProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.testConnection(),
            child: const Text('Retry Connection'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // DIALOG METHODS
  // ============================================================================

  void _showSubmitSleepDialog(HealthApiProvider provider) {
    showDialog(
      context: context,
      builder: (context) => SleepDataDialog(provider: provider),
    );
  }

  void _showSubmitHeartRateDialog(HealthApiProvider provider) {
    showDialog(
      context: context,
      builder: (context) => HeartRateDataDialog(provider: provider),
    );
  }

  void _showSubmitWeightDialog(HealthApiProvider provider) {
    showDialog(
      context: context,
      builder: (context) => WeightDataDialog(provider: provider),
    );
  }

  void _showAllDataDialog(String title, List<dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              if (item is SleepDataResponse) {
                return _buildSleepDataTile(item);
              } else if (item is HeartRateDataResponse) {
                return _buildHeartRateDataTile(item);
              } else if (item is WeightDataResponse) {
                return _buildWeightDataTile(item);
              }
              return ListTile(title: Text(item.toString()));
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DIALOG WIDGETS
// ============================================================================

class SleepDataDialog extends StatefulWidget {
  final HealthApiProvider provider;

  const SleepDataDialog({Key? key, required this.provider}) : super(key: key);

  @override
  _SleepDataDialogState createState() => _SleepDataDialogState();
}

class _SleepDataDialogState extends State<SleepDataDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime _startTime = DateTime.now().subtract(const Duration(hours: 8));
  DateTime _endTime = DateTime.now();
  int _quality = 80;
  int _deepSleep = 120;
  int _lightSleep = 240;
  int _remSleep = 90;
  int _awakeTime = 30;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Sleep Data'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(DateFormat('MMM dd, HH:mm').format(_startTime)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_startTime),
                  );
                  if (time != null) {
                    setState(() {
                      _startTime = DateTime(
                        _startTime.year,
                        _startTime.month,
                        _startTime.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(DateFormat('MMM dd, HH:mm').format(_endTime)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_endTime),
                  );
                  if (time != null) {
                    setState(() {
                      _endTime = DateTime(
                        _endTime.year,
                        _endTime.month,
                        _endTime.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
              ),
              Slider(
                value: _quality.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                label: '$_quality%',
                onChanged: (value) {
                  setState(() {
                    _quality = value.round();
                  });
                },
              ),
              Text('Sleep Quality: $_quality%'),
              const SizedBox(height: 16),
              const Text('Sleep Phases (minutes):'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _deepSleep.toString(),
                      decoration: const InputDecoration(labelText: 'Deep'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _deepSleep = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: _lightSleep.toString(),
                      decoration: const InputDecoration(labelText: 'Light'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _lightSleep = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _remSleep.toString(),
                      decoration: const InputDecoration(labelText: 'REM'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _remSleep = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: _awakeTime.toString(),
                      decoration: const InputDecoration(labelText: 'Awake'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _awakeTime = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final phases = SleepPhases(
              deep: _deepSleep,
              light: _lightSleep,
              rem: _remSleep,
              awake: _awakeTime,
            );

            final success = await widget.provider.submitSleepData(
              startTime: _startTime,
              endTime: _endTime,
              quality: _quality,
              phases: phases,
            );

            if (success && mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sleep data submitted successfully!')),
              );
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class HeartRateDataDialog extends StatefulWidget {
  final HealthApiProvider provider;

  const HeartRateDataDialog({Key? key, required this.provider}) : super(key: key);

  @override
  _HeartRateDataDialogState createState() => _HeartRateDataDialogState();
}

class _HeartRateDataDialogState extends State<HeartRateDataDialog> {
  final _formKey = GlobalKey<FormState>();
  int _heartRate = 75;
  int? _restingRate;
  String? _activityType;

  final List<String> _activityTypes = [
    'resting',
    'walking',
    'running',
    'cycling',
    'swimming',
    'gym',
    'other',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Heart Rate Data'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: _heartRate.toDouble(),
              min: 40,
              max: 200,
              divisions: 32,
              label: '$_heartRate BPM',
              onChanged: (value) {
                setState(() {
                  _heartRate = value.round();
                });
              },
            ),
            Text('Heart Rate: $_heartRate BPM'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Resting Rate (optional)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _restingRate = int.tryParse(value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Activity Type (optional)'),
              value: _activityType,
              items: _activityTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _activityType = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await widget.provider.submitHeartRateData(
              timestamp: DateTime.now(),
              value: _heartRate,
              restingRate: _restingRate,
              activityType: _activityType,
            );

            if (success && mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Heart rate data submitted successfully!')),
              );
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class WeightDataDialog extends StatefulWidget {
  final HealthApiProvider provider;

  const WeightDataDialog({Key? key, required this.provider}) : super(key: key);

  @override
  _WeightDataDialogState createState() => _WeightDataDialogState();
}

class _WeightDataDialogState extends State<WeightDataDialog> {
  final _formKey = GlobalKey<FormState>();
  double _weight = 70.0;
  double? _bmi;
  double? _bodyFat;
  double? _muscleMass;
  double? _waterPercentage;
  double? _boneMass;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Weight Data'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                initialValue: _weight.toString(),
                onChanged: (value) {
                  _weight = double.tryParse(value) ?? 70.0;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'BMI (optional)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _bmi = double.tryParse(value);
                },
              ),
              const SizedBox(height: 16),
              const Text('Body Composition (optional):'),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Body Fat (%)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _bodyFat = double.tryParse(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Muscle Mass (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _muscleMass = double.tryParse(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Water Percentage (%)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _waterPercentage = double.tryParse(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Bone Mass (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _boneMass = double.tryParse(value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            BodyComposition? bodyComposition;
            if (_bodyFat != null || _muscleMass != null || _waterPercentage != null || _boneMass != null) {
              bodyComposition = BodyComposition(
                bodyFat: _bodyFat,
                muscleMass: _muscleMass,
                waterPercentage: _waterPercentage,
                boneMass: _boneMass,
              );
            }

            final success = await widget.provider.submitWeightData(
              timestamp: DateTime.now(),
              value: _weight,
              bmi: _bmi,
              bodyComposition: bodyComposition,
            );

            if (success && mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Weight data submitted successfully!')),
              );
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
} 