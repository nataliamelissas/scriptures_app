import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../../core/theme.dart';
import '../providers/providers.dart';

/// Bottom sheet shown on long-press (no drag) or quick-tap on a highlight.
/// Options: highlight color, add note, bookmark, add tag (stub), share.
class VerseActionSheet extends ConsumerStatefulWidget {
  final ScriptureVerse verse;
  final String projectId;
  final StandardWork volume;
  final String bookApiId;
  final int chapter;
  final String bookTitle;
  final VoidCallback onDone;

  const VerseActionSheet({
    super.key,
    required this.verse,
    required this.projectId,
    required this.volume,
    required this.bookApiId,
    required this.chapter,
    required this.bookTitle,
    required this.onDone,
  });

  @override
  ConsumerState<VerseActionSheet> createState() => _VerseActionSheetState();
}

class _VerseActionSheetState extends ConsumerState<VerseActionSheet> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addHighlight(Color color) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.create(StudyNote(
      id: '',
      projectId: widget.projectId,
      volume: widget.volume,
      bookApiId: widget.bookApiId,
      chapter: widget.chapter,
      verseNumber: widget.verse.number,
      type: NoteType.highlight,
      highlightColorValue: color.toARGB32(),
      createdAt: DateTime.now(),
    ));
    widget.onDone();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _addBookmark() async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.create(StudyNote(
      id: '',
      projectId: widget.projectId,
      volume: widget.volume,
      bookApiId: widget.bookApiId,
      chapter: widget.chapter,
      verseNumber: widget.verse.number,
      type: NoteType.bookmark,
      createdAt: DateTime.now(),
    ));
    widget.onDone();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty) return;
    final repo = ref.read(noteRepositoryProvider);
    await repo.create(StudyNote(
      id: '',
      projectId: widget.projectId,
      volume: widget.volume,
      bookApiId: widget.bookApiId,
      chapter: widget.chapter,
      verseNumber: widget.verse.number,
      type: NoteType.note,
      content: _noteController.text.trim(),
      createdAt: DateTime.now(),
    ));
    widget.onDone();
    if (mounted) Navigator.pop(context);
  }

  void _share() {
    final reference =
        '${widget.bookTitle} ${widget.chapter}:${widget.verse.number}';
    // iPad/macOS require a popover anchor or share asserts. We use the
    // sheet's own render box as the anchor — visually sensible since the
    // share originated from there.
    final box = context.findRenderObject() as RenderBox?;
    final origin = (box != null && box.attached)
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    SharePlus.instance.share(ShareParams(
      text: '${widget.verse.text}\n\n— $reference',
      subject: reference,
      sharePositionOrigin: origin,
    ));
    Navigator.pop(context);
  }

  void _addTagComingSoon() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tags — coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Verse preview
              Text(
                '${widget.bookTitle} ${widget.chapter}:${widget.verse.number}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                widget.verse.text,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),

              // ── Highlight colors ────────────────────────────────────────
              Text('Highlight', style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),
              Row(
                children: HighlightColors.all.map((color) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => _addHighlight(color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Quick actions ───────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: _addBookmark,
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Bookmark'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _addTagComingSoon,
                icon: const Icon(Icons.label_outline),
                label: const Text('Add tag'),
              ),
              const SizedBox(height: 20),

              // ── Note ────────────────────────────────────────────────────
              Text('Add a note', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts...',
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _addNote,
                  child: const Text('Save Note'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
