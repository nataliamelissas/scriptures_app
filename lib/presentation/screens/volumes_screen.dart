import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../providers/providers.dart';
import 'books_screen.dart';
import 'reader_screen.dart';
import 'study_plan_created_screen.dart';

/// Volume selector. Two modes:
///
/// * [isInitialSetup] = true — project-creation flow. Shows all five
///   standard works and the chosen one is added to the new project, then
///   routes to the "Start reading?" confirmation.
/// * [isInitialSetup] = false — multi-volume opener. Shows only the
///   volumes already added to the project, each with its own reading
///   progress. Tapping resumes that volume's reader (or opens books if
///   the volume has no saved position yet). Adding new volumes happens
///   from the project's Settings screen, not here.
class VolumesScreen extends ConsumerWidget {
  final StudyProject project;
  final bool isInitialSetup;
  const VolumesScreen({
    super.key,
    required this.project,
    this.isInitialSetup = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final volumesToShow =
        isInitialSetup ? StandardWork.values : project.volumes;
    final subtitle = isInitialSetup
        ? 'Choose a volume to study'
        : 'Choose which volume to continue';

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
            Text(subtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: volumesToShow.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final volume = volumesToShow[i];
                  return _VolumeCard(
                    volume: volume,
                    position:
                        isInitialSetup ? null : project.positions[volume],
                    onTap: () => _onVolumeTap(context, ref, volume),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onVolumeTap(
    BuildContext context,
    WidgetRef ref,
    StandardWork volume,
  ) async {
    if (isInitialSetup) {
      final updated = await ref
          .read(studyProjectsProvider.notifier)
          .addVolume(project, volume);
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudyPlanCreatedScreen(
            project: updated,
            volume: volume,
          ),
        ),
      );
      return;
    }

    // Multi-volume opener: resume that volume's saved position if any.
    final pos = project.positions[volume];
    if (pos != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReaderScreen(
            project: project,
            volume: pos.volume,
            bookApiId: pos.bookApiId,
            bookTitle: pos.bookTitle,
            initialChapter: pos.chapter,
            initialVerse: pos.verseNumber,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BooksScreen(project: project, volume: volume),
        ),
      );
    }
  }
}

class _VolumeCard extends StatelessWidget {
  final StandardWork volume;
  final ReadingPosition? position;
  final VoidCallback onTap;
  const _VolumeCard({
    required this.volume,
    required this.onTap,
    this.position,
  });

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
    final pos = position;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(_icon, size: 22, color: theme.colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      volume.displayName,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (pos != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Reading: ${pos.bookTitle} ${pos.chapter}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
