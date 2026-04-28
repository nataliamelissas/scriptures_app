import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import 'books_screen.dart';

/// Displays the 5 standard works as a grid.
class VolumesScreen extends ConsumerWidget {
  final StudyProject project;
  const VolumesScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Standard Works', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Choose a volume to study',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.3,
                children: StandardWork.values.map((volume) {
                  return _VolumeCard(
                    volume: volume,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BooksScreen(
                            project: project,
                            volume: volume,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VolumeCard extends StatelessWidget {
  final StandardWork volume;
  final VoidCallback onTap;
  const _VolumeCard({required this.volume, required this.onTap});

  IconData get _icon => switch (volume) {
        StandardWork.oldTestament => Icons.history_edu_rounded,
        StandardWork.newTestament => Icons.auto_stories_rounded,
        StandardWork.bookOfMormon => Icons.menu_book_rounded,
        StandardWork.doctrineAndCovenants => Icons.gavel_rounded,
        StandardWork.pearlOfGreatPrice => Icons.diamond_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(_icon, size: 30, color: theme.colorScheme.primary),
              Text(
                volume.displayName,
                style: theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
