import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../core/theme/app_theme.dart';
import '../../history/presentation/history_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../tracking/presentation/tracking_screen.dart';

class FitQuestApp extends StatelessWidget {
  const FitQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitQuest Flutter',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: const Locale('it'),
      supportedLocales: const [Locale('it')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const FitQuestShell(),
    );
  }
}

class FitQuestShell extends StatefulWidget {
  const FitQuestShell({super.key});

  @override
  State<FitQuestShell> createState() => _FitQuestShellState();
}

class _FitQuestShellState extends State<FitQuestShell> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screenFor(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: const [
          NavigationDestination(
            key: Key('nav-home'),
            icon: Icon(Icons.home),
            label: 'Inizio',
          ),
          NavigationDestination(
            key: Key('nav-tracking'),
            icon: Icon(Icons.directions_run),
            label: 'Attività',
          ),
          NavigationDestination(
            key: Key('nav-history'),
            icon: Icon(Icons.history),
            label: 'Cronologia',
          ),
        ],
      ),
    );
  }

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _screenFor(int index) {
    return switch (index) {
      0 => HomeScreen(onStartTracking: () => _selectDestination(1)),
      1 => const TrackingScreen(showHistoryButton: false),
      _ => const HistoryScreen(),
    };
  }
}
