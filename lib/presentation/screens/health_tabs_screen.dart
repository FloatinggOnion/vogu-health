import 'package:flutter/material.dart';
import 'package:vogu_health/presentation/screens/health_dashboard_screen.dart';
import 'package:vogu_health/presentation/screens/health_trends_screen.dart';
import 'package:vogu_health/presentation/screens/health_insights_screen.dart';

class HealthTabsScreen extends StatefulWidget {
  const HealthTabsScreen({super.key});

  @override
  State<HealthTabsScreen> createState() => _HealthTabsScreenState();
}

class _HealthTabsScreenState extends State<HealthTabsScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HealthDashboardScreen(),
    HealthTrendsScreen(),
    HealthInsightsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoguHealth'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Trends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
} 