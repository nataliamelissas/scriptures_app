import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/study_project.dart';
import '../providers/providers.dart';
import 'archived_projects_screen.dart';
import 'books_screen.dart';
import 'reader_screen.dart';
import 'volumes_screen.dart';

/// Home screen: lists the user's study projects.
/// This is the entry point — you pick which "copy" of the scriptures to open.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(studyProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.inventory_2_outlined),
          tooltip: 'Archive',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ArchivedProjectsScreen(),
              ),
            );
          },
        ),
        title: const Text('My Study Projects'),
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (projects) => projects.isEmpty
            ? _EmptyState(onTap: () => _showCreateDialog(context, ref))
            : _ProjectList(projects: projects),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Study'),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Study Project'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. "Family Study 2026"',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'What is this study about?',
                  alignLabelWithHint: true,
                ),
                minLines: 2,
                maxLines: 2,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final project = await ref.read(studyProjectsProvider.notifier).create(
            nameController.text.trim(),
            description: descController.text.trim().isEmpty
                ? null
                : descController.text.trim(),
          );

      if (context.mounted) {
        ref.read(selectedProjectProvider.notifier).state = project;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VolumesScreen(
              project: project,
              isInitialSetup: true,
            ),
          ),
        );
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 72, color: theme.colorScheme.primary.withAlpha(120)),
            const SizedBox(height: 24),
            Text(
              'Start Your First Study',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create a study project to begin reading scripture with your own notes, highlights, and bookmarks.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add),
              label: const Text('Create Study Project'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectList extends ConsumerWidget {
  final List<StudyProject> projects;
  const _ProjectList({required this.projects});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: projects.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _openProject(context, ref, project),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.name, style: theme.textTheme.titleMedium),
                        if (project.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            project.description!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          project.lastPosition != null
                              ? 'Reading: ${project.lastPosition!.bookTitle} ${project.lastPosition!.chapter}'
                              : 'Not started',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'settings':
                          _openSettings(context, ref, project);
                        case 'archive':
                          ref
                              .read(studyProjectsProvider.notifier)
                              .setArchived(project.id, true);
                        case 'delete':
                          _confirmDelete(context, ref, project);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'settings',
                        child: Text('Settings'),
                      ),
                      PopupMenuItem(
                        value: 'archive',
                        child: Text('Archive'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Open a project tile: resume reading where the user left off, or — if
  /// they never started — open the books list for the project's default
  /// volume. We never route through the Standard Works picker here; that
  /// lives behind the per-project Settings menu.
  void _openProject(BuildContext context, WidgetRef ref, StudyProject project) {
    ref.read(selectedProjectProvider.notifier).state = project;
    final pos = project.lastPosition;
    if (pos != null) {
      Navigator.push(
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
      return;
    }
    final volume = project.defaultVolume;
    if (volume != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BooksScreen(project: project, volume: volume),
        ),
      );
      return;
    }
    // Fallback: no position and no default volume — send them through the
    // volume picker as if completing setup.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VolumesScreen(
          project: project,
          isInitialSetup: true,
        ),
      ),
    );
  }

  void _openSettings(BuildContext context, WidgetRef ref, StudyProject project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VolumesScreen(project: project),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    StudyProject project,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Study Project?'),
        content: Text(
          'This will permanently delete "${project.name}" and all its notes, highlights, and bookmarks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(studyProjectsProvider.notifier).delete(project.id);
    }
  }
}
