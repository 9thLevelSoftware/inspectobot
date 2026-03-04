import 'package:flutter/material.dart';
import 'package:inspectobot/app/routes.dart';

import 'new_inspection_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InspectoBot')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Florida Insurance Inspection Workflow',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('Start a new inspection to capture required items.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NewInspectionPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Inspection'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.inspectorIdentity);
              },
              icon: const Icon(Icons.badge_outlined),
              label: const Text('Inspector Identity'),
            ),
          ],
        ),
      ),
    );
  }
}

