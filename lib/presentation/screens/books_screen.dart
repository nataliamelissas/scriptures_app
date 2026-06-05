import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../providers/providers.dart';
import 'chapters_screen.dart';

/// Lists all books within a standard work.
class BooksScreen extends ConsumerWidget {
  final StudyProject project;
  final StandardWork volume;

  const BooksScreen({
    super.key,
    required this.project,
    required this.volume,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider(volume));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(volume.displayName)),
      body: booksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load books.\n$e', textAlign: TextAlign.center),
          ),
        ),
        data: (books) => ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          itemCount: books.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final book = books[index];
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              title: Text(book.title, style: theme.textTheme.titleMedium),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show the chapter picker; the user taps a chapter from there.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChaptersScreen(
                      project: project,
                      volume: volume,
                      bookApiId: book.apiId,
                      bookTitle: book.title,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
