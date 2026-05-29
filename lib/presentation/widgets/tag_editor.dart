import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';

/// Compact tag editor: shows existing tags as deletable chips and an
/// inline text field for adding new ones. Each tag is capped at
/// [TagConfig.maxLength] characters at input time.
///
/// State is owned by the caller — [tags] is the source of truth and
/// [onChanged] is invoked whenever the list changes. The caller decides
/// whether to persist immediately or batch until save.
class TagEditor extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  /// Hint shown in the input field.
  final String hint;

  const TagEditor({
    super.key,
    required this.tags,
    required this.onChanged,
    this.hint = 'Add a tag',
  });

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;
    // Case-insensitive dedupe.
    final exists =
        widget.tags.any((t) => t.toLowerCase() == raw.toLowerCase());
    if (exists) {
      _controller.clear();
      return;
    }
    final updated = [...widget.tags, raw];
    widget.onChanged(updated);
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _removeTag(String tag) {
    final updated = widget.tags.where((t) => t != tag).toList();
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tags.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.tags
                .map((tag) => InputChip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLength: TagConfig.maxLength,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addTag(),
                inputFormatters: [
                  // Disallow commas (used as DB separator) and leading whitespace.
                  FilteringTextInputFormatter.deny(RegExp(r',')),
                ],
                decoration: InputDecoration(
                  hintText: widget.hint,
                  isDense: true,
                  counterText: '',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: _addTag,
              icon: const Icon(Icons.add),
              tooltip: 'Add tag',
            ),
          ],
        ),
      ],
    );
  }
}
