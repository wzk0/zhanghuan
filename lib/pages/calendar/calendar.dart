import 'package:flutter/material.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCalendarCard(
            context,
            '2025-2026-2校历',
            'assets/images/calendar/2025-2026-2.png',
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(
    BuildContext context,
    String title,
    String assetPath,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          InkWell(
            onTap: () {
              _showFullScreenImage(context, assetPath);
            },
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined, size: 48),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String assetPath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(child: InteractiveViewer(child: Image.asset(assetPath))),
        ),
      ),
    );
  }
}
