/// Home Screen - Main Dashboard
///
/// Shows under construction display while dashboard features are in development
library;

import 'package:flutter/material.dart';
import '../widgets/organisms/organisms.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(pageTitle: 'Dashboard'),
      body: UnderConstructionDisplay(
        title: 'Dashboard Coming Soon!',
        message:
            'We\'re building an amazing dashboard with analytics, insights, and quick actions. '
            'Stay tuned for exciting updates!',
        icon: Icons.dashboard,
      ),
    );
  }
}
