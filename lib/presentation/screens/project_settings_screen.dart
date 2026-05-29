import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../providers/providers.dart';
import '../widgets/tag_editor.dart';
import 'add_volume_screen.dart';

/// Edit a study plan's metadata: name, description, tags, and which
/// standard works belong to it. Name/description/tags batch into a
/// single Save; volume add/remove commits immediately because each is
/// its own user action.
class ProjectSettingsScreen extends ConsumerStatefulWidget {
  final StudyProject project;
  const ProjectSettingsScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectSettingsScreen> createState() =>
      _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState
    extends ConsumerState<ProjectSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late List<String> _tags;

  /// Current entity reference — kept fresh when we add/remove volumes
  /// since those calls return updated state.
  late StudyProject _project;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _nameController = TextEditingController(text: _project.name);
    _descController =
        TextEditingController(text: _project.description ?? '');
    _tags = List.of(_project.tags);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final currentDesc = _project.description ?? '';
    return name != _project.name ||
        desc != currentDesc ||
        !_listEquals(_tags, _project.tags);
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty.')),
      );
      return;
    }
    setState(() => _saving = true);
    final desc = _descController.text.trim();
    await ref.read(studyProjectsProvider.notifier).updateProject(
          _project,
          name: name,
          description: desc.isEmpty ? null : desc,
          tags: _tags,
        );
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _openAddVolume() async {
    final updated = await Navigator.push<StudyProject>(
      context,
      MaterialPageRoute(
        builder: (_) => AddVolumeScreen(project: _project),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _project = updated);
    }
  }

  Future<void> _confirmRemoveVolume(StandardWork volume) async {
    final hasPosition = _project.positions.containsKey(volume);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${volume.displayName}?'),
        content: Text(
          hasPosition
              ? 'This will remove ${volume.displayName} from this study '
                  'plan and discard its saved reading position. Your '
                  'highlights and notes will stay.'
              : 'This will remove ${volume.displayName} from this study plan.',
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(studyProjectsProvider.notifier)
        .removeVolume(_project, volume);
    if (!mounted) return;
    final newVolumes = _project.volumes.where((v) => v != volume).toList();
    final newPositions = Map<StandardWork, ReadingPosition>.from(
      _project.positions,
    )..remove(volume);
    setState(() {
      _project = _project.copyWith(
        volumes: newVolumes,
        positions: newPositions,
        activeVolume:
            _project.activeVolume == volume ? null : _project.activeVolume,
        clearActiveVolume: _project.activeVolume == volume,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final discard = await _confirmDiscard();
        if (discard == true && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          actions: [
            TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionLabel('Name'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Description'),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'What is this study about?',
                alignLabelWithHint: true,
              ),
              minLines: 2,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Tags'),
            const SizedBox(height: 6),
            TagEditor(
              tags: _tags,
              onChanged: (next) => setState(() => _tags = next),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(child: _SectionLabel('Standard Works')),
                IconButton.filledTonal(
                  onPressed: _openAddVolume,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add standard work',
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (_project.volumes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No standard works yet. Tap + to add one.',
                  style: theme.textTheme.bodySmall,
                ),
              )
            else
              ..._project.volumes.map(
                (v) => _VolumeRow(
                  volume: v,
                  position: _project.positions[v],
                  onRemove: () => _confirmRemoveVolume(v),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDiscard() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved edits.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  final StandardWork volume;
  final ReadingPosition? position;
  final VoidCallback onRemove;
  const _VolumeRow({
    required this.volume,
    required this.position,
    required this.onRemove,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    ] else ...[
                      const SizedBox(height: 2),
                      Text(
                        'Not started',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                tooltip: 'Remove',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
