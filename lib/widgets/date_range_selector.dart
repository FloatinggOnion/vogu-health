import 'package:flutter/material.dart';

class DateRangeSelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime, DateTime) onRangeChanged;
  final String? errorMessage;

  const DateRangeSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onRangeChanged,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPresetButton(
                  context,
                  '7 Days',
                  () {
                    final end = DateTime.now();
                    final start = end.subtract(const Duration(days: 7));
                    onRangeChanged(start, end);
                  },
                ),
                _buildPresetButton(
                  context,
                  '30 Days',
                  () {
                    final end = DateTime.now();
                    final start = end.subtract(const Duration(days: 30));
                    onRangeChanged(start, end);
                  },
                ),
                _buildPresetButton(
                  context,
                  '90 Days',
                  () {
                    final end = DateTime.now();
                    final start = end.subtract(const Duration(days: 90));
                    onRangeChanged(start, end);
                  },
                ),
                _buildCustomButton(context),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '${_formatDate(startDate)} - ${_formatDate(endDate)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return TextButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _buildCustomButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
          initialDateRange: DateTimeRange(
            start: startDate,
            end: endDate,
          ),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                  surface: Theme.of(context).colorScheme.surface,
                  onSurface: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          onRangeChanged(picked.start, picked.end);
        }
      },
      icon: const Icon(Icons.calendar_today),
      label: const Text('Custom'),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 