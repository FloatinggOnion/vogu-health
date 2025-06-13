import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vogu_health/models/health_data.dart';
import 'package:vogu_health/services/api_service.dart';

class HealthDataEntryForm extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback? onSuccess;

  const HealthDataEntryForm({
    super.key,
    required this.apiService,
    this.onSuccess,
  });

  @override
  State<HealthDataEntryForm> createState() => _HealthDataEntryFormState();
}

class _HealthDataEntryFormState extends State<HealthDataEntryForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedDataType = 'sleep';
  bool _isSubmitting = false;
  String? _errorMessage;

  // Sleep data fields
  DateTime? _sleepStartTime;
  DateTime? _sleepEndTime;
  final _sleepQualityController = TextEditingController();
  final _deepSleepController = TextEditingController();
  final _lightSleepController = TextEditingController();
  final _remSleepController = TextEditingController();
  final _awakeTimeController = TextEditingController();

  // Heart rate data fields
  DateTime? _heartRateTimestamp;
  final _heartRateController = TextEditingController();
  final _restingRateController = TextEditingController();
  final _activityTypeController = TextEditingController();

  // Weight data fields
  DateTime? _weightTimestamp;
  final _weightController = TextEditingController();
  final _bmiController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _waterPercentageController = TextEditingController();
  final _boneMassController = TextEditingController();

  @override
  void dispose() {
    _sleepQualityController.dispose();
    _deepSleepController.dispose();
    _lightSleepController.dispose();
    _remSleepController.dispose();
    _awakeTimeController.dispose();
    _heartRateController.dispose();
    _restingRateController.dispose();
    _activityTypeController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _waterPercentageController.dispose();
    _boneMassController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          final DateTime selected = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (_selectedDataType == 'sleep') {
            if (isStartTime) {
              _sleepStartTime = selected;
            } else {
              _sleepEndTime = selected;
            }
          } else if (_selectedDataType == 'heart-rate') {
            _heartRateTimestamp = selected;
          } else {
            _weightTimestamp = selected;
          }
        });
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not set';
    return DateFormat('MMM d, y HH:mm').format(dateTime);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      switch (_selectedDataType) {
        case 'sleep':
          if (_sleepStartTime == null || _sleepEndTime == null) {
            throw const FormatException('Please select both start and end times');
          }
          await widget.apiService.submitSleepData(
            SleepData(
              startTime: _sleepStartTime!,
              endTime: _sleepEndTime!,
              quality: int.parse(_sleepQualityController.text),
              phases: SleepPhases(
                deep: int.parse(_deepSleepController.text),
                light: int.parse(_lightSleepController.text),
                rem: int.parse(_remSleepController.text),
                awake: int.parse(_awakeTimeController.text),
              ),
            ),
          );
          break;

        case 'heart-rate':
          if (_heartRateTimestamp == null) {
            throw const FormatException('Please select a timestamp');
          }
          await widget.apiService.submitHeartRateData(
            HeartRateData(
              timestamp: _heartRateTimestamp!,
              value: int.parse(_heartRateController.text),
              restingRate: _restingRateController.text.isNotEmpty
                  ? int.parse(_restingRateController.text)
                  : null,
              activityType: _activityTypeController.text.isNotEmpty
                  ? _activityTypeController.text
                  : null,
            ),
          );
          break;

        case 'weight':
          if (_weightTimestamp == null) {
            throw const FormatException('Please select a timestamp');
          }
          await widget.apiService.submitWeightData(
            WeightData(
              timestamp: _weightTimestamp!,
              value: double.parse(_weightController.text),
              bmi: _bmiController.text.isNotEmpty
                  ? double.parse(_bmiController.text)
                  : null,
              bodyComposition: BodyComposition(
                bodyFat: double.parse(_bodyFatController.text),
                muscleMass: double.parse(_muscleMassController.text),
                waterPercentage: double.parse(_waterPercentageController.text),
                boneMass: _boneMassController.text.isNotEmpty
                    ? double.parse(_boneMassController.text)
                    : null,
              ),
            ),
          );
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess?.call();
        _formKey.currentState!.reset();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildSleepForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Start Time'),
          subtitle: Text(_formatDateTime(_sleepStartTime)),
          trailing: const Icon(Icons.access_time),
          onTap: () => _selectDateTime(context, true),
        ),
        ListTile(
          title: const Text('End Time'),
          subtitle: Text(_formatDateTime(_sleepEndTime)),
          trailing: const Icon(Icons.access_time),
          onTap: () => _selectDateTime(context, false),
        ),
        TextFormField(
          controller: _sleepQualityController,
          decoration: const InputDecoration(
            labelText: 'Sleep Quality (0-100)',
            helperText: 'Rate your sleep quality from 0 to 100',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter sleep quality';
            }
            final quality = int.tryParse(value);
            if (quality == null || quality < 0 || quality > 100) {
              return 'Please enter a value between 0 and 100';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        const Text('Sleep Phases (in minutes)'),
        TextFormField(
          controller: _deepSleepController,
          decoration: const InputDecoration(
            labelText: 'Deep Sleep',
            helperText: 'Duration of deep sleep in minutes',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter deep sleep duration';
            }
            final minutes = int.tryParse(value);
            if (minutes == null || minutes < 0) {
              return 'Please enter a valid duration';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _lightSleepController,
          decoration: const InputDecoration(
            labelText: 'Light Sleep',
            helperText: 'Duration of light sleep in minutes',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter light sleep duration';
            }
            final minutes = int.tryParse(value);
            if (minutes == null || minutes < 0) {
              return 'Please enter a valid duration';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _remSleepController,
          decoration: const InputDecoration(
            labelText: 'REM Sleep',
            helperText: 'Duration of REM sleep in minutes',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter REM sleep duration';
            }
            final minutes = int.tryParse(value);
            if (minutes == null || minutes < 0) {
              return 'Please enter a valid duration';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _awakeTimeController,
          decoration: const InputDecoration(
            labelText: 'Awake Time',
            helperText: 'Duration of awake time in minutes',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter awake time duration';
            }
            final minutes = int.tryParse(value);
            if (minutes == null || minutes < 0) {
              return 'Please enter a valid duration';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildHeartRateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Timestamp'),
          subtitle: Text(_formatDateTime(_heartRateTimestamp)),
          trailing: const Icon(Icons.access_time),
          onTap: () => _selectDateTime(context, true),
        ),
        TextFormField(
          controller: _heartRateController,
          decoration: const InputDecoration(
            labelText: 'Heart Rate (BPM)',
            helperText: 'Enter heart rate between 30 and 220 BPM',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter heart rate';
            }
            final rate = int.tryParse(value);
            if (rate == null || rate < 30 || rate > 220) {
              return 'Please enter a value between 30 and 220';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _restingRateController,
          decoration: const InputDecoration(
            labelText: 'Resting Heart Rate (BPM)',
            helperText: 'Optional: Enter resting heart rate between 30 and 100 BPM',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            final rate = int.tryParse(value);
            if (rate == null || rate < 30 || rate > 100) {
              return 'Please enter a value between 30 and 100';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _activityTypeController,
          decoration: const InputDecoration(
            labelText: 'Activity Type',
            helperText: 'Optional: Enter the type of activity',
          ),
        ),
      ],
    );
  }

  Widget _buildWeightForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Timestamp'),
          subtitle: Text(_formatDateTime(_weightTimestamp)),
          trailing: const Icon(Icons.access_time),
          onTap: () => _selectDateTime(context, true),
        ),
        TextFormField(
          controller: _weightController,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            helperText: 'Enter weight in kilograms',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter weight';
            }
            final weight = double.tryParse(value);
            if (weight == null || weight <= 0) {
              return 'Please enter a valid weight';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _bmiController,
          decoration: const InputDecoration(
            labelText: 'BMI',
            helperText: 'Optional: Enter BMI value',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            final bmi = double.tryParse(value);
            if (bmi == null || bmi <= 0) {
              return 'Please enter a valid BMI';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        const Text('Body Composition'),
        TextFormField(
          controller: _bodyFatController,
          decoration: const InputDecoration(
            labelText: 'Body Fat (%)',
            helperText: 'Enter body fat percentage (0-100)',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter body fat percentage';
            }
            final percentage = double.tryParse(value);
            if (percentage == null || percentage < 0 || percentage > 100) {
              return 'Please enter a value between 0 and 100';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _muscleMassController,
          decoration: const InputDecoration(
            labelText: 'Muscle Mass (%)',
            helperText: 'Enter muscle mass percentage (0-100)',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter muscle mass percentage';
            }
            final percentage = double.tryParse(value);
            if (percentage == null || percentage < 0 || percentage > 100) {
              return 'Please enter a value between 0 and 100';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _waterPercentageController,
          decoration: const InputDecoration(
            labelText: 'Water Percentage (%)',
            helperText: 'Enter water percentage (0-100)',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter water percentage';
            }
            final percentage = double.tryParse(value);
            if (percentage == null || percentage < 0 || percentage > 100) {
              return 'Please enter a value between 0 and 100';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _boneMassController,
          decoration: const InputDecoration(
            labelText: 'Bone Mass (kg)',
            helperText: 'Optional: Enter bone mass in kilograms',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            final mass = double.tryParse(value);
            if (mass == null || mass <= 0) {
              return 'Please enter a valid bone mass';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'sleep',
                label: Text('Sleep'),
                icon: Icon(Icons.bedtime),
              ),
              ButtonSegment(
                value: 'heart-rate',
                label: Text('Heart Rate'),
                icon: Icon(Icons.favorite),
              ),
              ButtonSegment(
                value: 'weight',
                label: Text('Weight'),
                icon: Icon(Icons.monitor_weight),
              ),
            ],
            selected: {_selectedDataType},
            onSelectionChanged: (Set<String> selection) {
              setState(() {
                _selectedDataType = selection.first;
                _errorMessage = null;
              });
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  switch (_selectedDataType) {
                    'sleep' => _buildSleepForm(),
                    'heart-rate' => _buildHeartRateForm(),
                    'weight' => _buildWeightForm(),
                    _ => throw UnimplementedError(),
                  },
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSubmitting ? 'Submitting...' : 'Submit'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 