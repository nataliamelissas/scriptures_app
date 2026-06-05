import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scriptures_app/domain/entities/scripture.dart';
import 'package:scriptures_app/domain/entities/study_project.dart';
import 'package:scriptures_app/presentation/providers/providers.dart';
import 'package:scriptures_app/presentation/screens/chapters_screen.dart';

/// Verifies the chapter picker renders one pill per chapter and labels the grid
/// with the book's delineation ("Chapters" vs "Sections"), driven by an
/// overridden [bookChaptersProvider] so no network/DB is touched.
void main() {
  final project = StudyProject(
    id: 'p1',
    name: 'Test',
    createdAt: DateTime(2026),
    lastOpenedAt: DateTime(2026),
  );

  Widget harness(BookChapters overview) {
    return ProviderScope(
      overrides: [
        bookChaptersProvider.overrideWith((ref, args) async => overview),
      ],
      child: MaterialApp(
        home: ChaptersScreen(
          project: project,
          volume: StandardWork.bookOfMormon,
          bookApiId: '1nephi',
          bookTitle: '1 Nephi',
        ),
      ),
    );
  }

  testWidgets('renders one pill per chapter with a "Chapters" header',
      (tester) async {
    await tester.pumpWidget(harness(const BookChapters(
      bookApiId: '1nephi',
      bookTitle: '1 Nephi',
      chapterCount: 5,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Chapters'), findsOneWidget);
    for (final n in ['1', '2', '3', '4', '5']) {
      expect(find.text(n), findsOneWidget);
    }
    expect(find.text('6'), findsNothing);
  });

  testWidgets('single-chapter book still shows one pill', (tester) async {
    await tester.pumpWidget(harness(const BookChapters(
      bookApiId: 'enos',
      bookTitle: 'Enos',
      chapterCount: 1,
    )));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('D&C delineation labels the grid "Sections"', (tester) async {
    await tester.pumpWidget(harness(const BookChapters(
      bookApiId: 'doctrineandcovenants',
      bookTitle: 'Doctrine and Covenants',
      chapterCount: 3,
      delineation: 'Section',
    )));
    await tester.pumpAndSettle();

    expect(find.text('Sections'), findsOneWidget);
  });
}
