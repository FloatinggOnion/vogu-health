import 'package:flutter/material.dart';
import 'package:vogu_health/services/health_api_service.dart';
import 'package:vogu_health/models/api_models.dart';
import 'package:vogu_health/utils/validation_utils.dart';
import 'package:intl/intl.dart';

class DataSubmissionDialog extends StatefulWidget {
  const DataSubmissionDialog({super.key});

  @override
  State<DataSubmissionDialog> createState() => _DataSubmissionDialogState();
}

class _DataSubmissionDialogState extends State<DataSubmissionDialog> {
  final _apiService = HealthApiService();
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'sleep';
  bool _isSubmitting = false;
  String? _errorMessage;

  // Sleep form fields
  final _sleepStartTimeController = TextEditingController();
  final _sleepEndTimeController = TextEditingController();
  final _sleepQualityController = TextEditingController();
  final _sleepDeepController = TextEditingController();
  final _sleepLightController = TextEditingController();
  final _sleepRemController = TextEditingController();
  final _sleepAwakeController = TextEditingController();

  // Heart rate form fields
  final _heartRateTimestampController = TextEditingController();
  final _heartRateValueController = TextEditingController();
  final _heartRateRestingController = TextEditingController();
  final _heartRateActivityController = TextEditingController();

  // Weight form fields
  final _weightTimestampController = TextEditingController();
  final _weightValueController = TextEditingController();
  final _weightBmiController = TextEditingController();
  final _weightBodyFatController = TextEditingController();
  final _weightMuscleMassController = TextEditingController();
  final _weightWaterPercentageController = TextEditingController();
  final _weightBoneMassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final now = DateTime.now();
    final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    
    // Set default timestamps
    _sleepStartTimeController.text = formatter.format(now.subtract(const Duration(hours: 8)));
    _sleepEndTimeController.text = formatter.format(now);
    _heartRateTimestampController.text = formatter.format(now);
    _weightTimestampController.text = formatter.format(now);
  }

  @override
  void dispose() {
    _sleepStartTimeController.dispose();
    _sleepEndTimeController.dispose();
    _sleepQualityController.dispose();
    _sleepDeepController.dispose();
    _sleepLightController.dispose();
    _sleepRemController.dispose();
    _sleepAwakeController.dispose();
    _heartRateTimestampController.dispose();
    _heartRateValueController.dispose();
    _heartRateRestingController.dispose();
    _heartRateActivityController.dispose();
    _weightTimestampController.dispose();
    _weightValueController.dispose();
    _weightBmiController.dispose();
    _weightBodyFatController.dispose();
    _weightMuscleMassController.dispose();
    _weightWaterPercentageController.dispose();
    _weightBoneMassController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final DateTime dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        controller.text = ValidationUtils.formatDateTime(dateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit Health Data'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'sleep', child: Text('Sleep Data')),
                  DropdownMenuItem(value: 'heart_rate', child: Text('Heart Rate Data')),
                  DropdownMenuItem(value: 'weight', child: Text('Weight Data')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_selectedType == 'sleep')
                _buildSleepForm()
              else if (_selectedType == 'heart_rate')
                _buildHeartRateForm()
              else
                _buildWeightForm(),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
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
          onPressed: _isSubmitting ? null : _submitData,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDateTime(context, controller),
        ),
      ),
      validator: validator,
      readOnly: true,
    );
  }

  Widget _buildSleepForm() {
    return Column(
      children: [
        _buildDateTimeField(
          controller: _sleepStartTimeController,
          label: 'Start Time',
          validator: ValidationUtils.validateIso8601Date,
        ),
        const SizedBox(height: 8),
        _buildDateTimeField(
          controller: _sleepEndTimeController,
          label: 'End Time',
          validator: ValidationUtils.validateIso8601Date,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _sleepQualityController,
          decoration: const InputDecoration(
            labelText: 'Quality (0-100)',
            hintText: '85',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateNumericRange(value, 0, 100),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _sleepDeepController,
          decoration: const InputDecoration(
            labelText: 'Deep Sleep (minutes)',
            hintText: '120',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateNumericRange(value, 0, 480),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _sleepLightController,
          decoration: const InputDecoration(
            labelText: 'Light Sleep (minutes)',
            hintText: '240',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateNumericRange(value, 0, 480),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _sleepRemController,
          decoration: const InputDecoration(
            labelText: 'REM Sleep (minutes)',
            hintText: '90',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateNumericRange(value, 0, 480),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _sleepAwakeController,
          decoration: const InputDecoration(
            labelText: 'Awake Time (minutes)',
            hintText: '30',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateNumericRange(value, 0, 480),
        ),
      ],
    );
  }

  Widget _buildHeartRateForm() {
    return Column(
      children: [
        _buildDateTimeField(
          controller: _heartRateTimestampController,
          label: 'Timestamp',
          validator: ValidationUtils.validateIso8601Date,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _heartRateValueController,
          decoration: const InputDecoration(
            labelText: 'Heart Rate (bpm)',
            hintText: '75',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateNumericRange(value, 30, 220),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _heartRateRestingController,
          decoration: const InputDecoration(
            labelText: 'Resting Rate (bpm)',
            hintText: '60',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateNumericRange(value, 30, 220),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _heartRateActivityController,
          decoration: const InputDecoration(
            labelText: 'Activity Type',
            hintText: 'walking',
          ),
          validator: ValidationUtils.validateRequired,
        ),
      ],
    );
  }

  Widget _buildWeightForm() {
    return Column(
      children: [
        _buildDateTimeField(
          controller: _weightTimestampController,
          label: 'Timestamp',
          validator: ValidationUtils.validateIso8601Date,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _weightValueController,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            hintText: '70.5',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateNumericRange(value, 20, 300),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _weightBmiController,
          decoration: const InputDecoration(
            labelText: 'BMI',
            hintText: '22.5',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateNumericRange(value, 10, 50),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _weightBodyFatController,
          decoration: const InputDecoration(
            labelText: 'Body Fat (%)',
            hintText: '18.5',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateOptionalNumericRange(value, 3, 50),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _weightMuscleMassController,
          decoration: const InputDecoration(
            labelText: 'Muscle Mass (kg)',
            hintText: '40.2',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateOptionalNumericRange(value, 10, 100),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _weightWaterPercentageController,
          decoration: const InputDecoration(
            labelText: 'Water Percentage (%)',
            hintText: '55.0',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateOptionalNumericRange(value, 30, 80),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _weightBoneMassController,
          decoration: const InputDecoration(
            labelText: 'Bone Mass (kg)',
            hintText: '3.2',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateOptionalNumericRange(value, 1, 10),
        ),
      ],
    );
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      switch (_selectedType) {
        case 'sleep':
          final request = SleepDataRequest(
            startTime: _sleepStartTimeController.text,
            endTime: _sleepEndTimeController.text,
            quality: int.tryParse(_sleepQualityController.text) ?? 0,
            phases: SleepPhases(
              deep: int.tryParse(_sleepDeepController.text) ?? 0,
              light: int.tryParse(_sleepLightController.text) ?? 0,
              rem: int.tryParse(_sleepRemController.text) ?? 0,
              awake: int.tryParse(_sleepAwakeController.text) ?? 0,
            ),
            source: 'mobile_app',
          );
          await _apiService.submitSleepData(request);
          break;

        case 'heart_rate':
          final request = HeartRateDataRequest(
            timestamp: _heartRateTimestampController.text,
            value: int.tryParse(_heartRateValueController.text) ?? 0,
            restingRate: int.tryParse(_heartRateRestingController.text) ?? 0,
            activityType: _heartRateActivityController.text,
            source: 'mobile_app',
          );
          await _apiService.submitHeartRateData(request);
          break;

        case 'weight':
          final request = WeightDataRequest(
            timestamp: _weightTimestampController.text,
            value: double.tryParse(_weightValueController.text) ?? 0.0,
            bmi: double.tryParse(_weightBmiController.text) ?? 0.0,
            bodyComposition: BodyComposition(
              bodyFat: double.tryParse(_weightBodyFatController.text),
              muscleMass: double.tryParse(_weightMuscleMassController.text),
              waterPercentage: double.tryParse(_weightWaterPercentageController.text),
              boneMass: double.tryParse(_weightBoneMassController.text),
            ),
            source: 'mobile_app',
          );
          await _apiService.submitWeightData(request);
          break;
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error submitting data: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
} 