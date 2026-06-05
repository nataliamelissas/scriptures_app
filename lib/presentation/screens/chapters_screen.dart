import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../providers/providers.dart';
import 'reader_screen.dart';

// Grid metrics. Pills target ~half the "New Study" button width so phones show
// roughly four per row while tablets/desktop fit as many as the width allows.
const double _kTargetPillWidth = 80;
const double _kGridSpacing = 12;
const double _kPillRadius = 14;

/// Pills per row for [availableWidth]. Targets a pill ~half the "New Study"
/// button width (~80px) so phones get ~4, tablets/desktop get as many as fit.
int chapterGridColumns(
  double availableWidth, {
  double targetPillWidth = _kTargetPillWidth,
  double spacing = _kGridSpacing,
}) {
  final cols = ((availableWidth + spacing) / (targetPillWidth + spacing)).floor();
  return cols < 1 ? 1 : cols;
}

/// Grid of chapter (or section) "pills" for a book. Picking one opens the
/// reader at that chapter, replacing the old jump-straight-to-chapter-1 flow.
class ChaptersScreen extends ConsumerWidget {
  final StudyProject project;
  final StandardWork volume;
  final String bookApiId;
  final String bookTitle;

  const ChaptersScreen({
    super.key,
    required this.project,
    required this.volume,
    required this.bookApiId,
    required this.bookTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(
      bookChaptersProvider((volume: volume, bookApiId: bookApiId)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(bookTitle)),
      body: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load chapters.\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (overview) => _ChapterGrid(
          project: project,
          volume: volume,
          bookApiId: bookApiId,
          bookTitle: bookTitle,
          overview: overview,
        ),
      ),
    );
  }
}

class _ChapterGrid extends StatelessWidget {
  final StudyProject project;
  final StandardWork volume;
  final String bookApiId;
  final String bookTitle;
  final BookChapters overview;

  const _ChapterGrid({
    required this.project,
    required this.volume,
    required this.bookApiId,
    required this.bookTitle,
    required this.overview,
  });

  void _openChapter(BuildContext context, int chapter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          project: project,
          volume: volume,
          bookApiId: bookApiId,
          bookTitle: bookTitle,
          initialChapter: chapter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (overview.chapterCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No ${overview.delineation.toLowerCase()}s found for $bookTitle.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            '${overview.delineation}s',
            style: theme.textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = chapterGridColumns(constraints.maxWidth);
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: _kGridSpacing,
                  mainAxisSpacing: _kGridSpacing,
                  childAspectRatio: 1, // square-ish pills
                ),
                itemCount: overview.chapterCount,
                itemBuilder: (context, index) {
                  final chapter = index + 1;
                  return _ChapterPill(
                    number: chapter,
                    onTap: () => _openChapter(context, chapter),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChapterPill extends StatelessWidget {
  final int number;
  final VoidCallback onTap;

  const _ChapterPill({required this.number, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(_kPillRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_kPillRadius),
        onTap: onTap,
        child: Center(
          child: Text(
            '$number',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
