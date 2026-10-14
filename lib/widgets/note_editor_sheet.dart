import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/note_item.dart';

/// Bottom sheet dialog for creating and editing notes in Chronova.
/// Supports title validation, prefilled values in edit mode, folder assignment, and pinned toggle.
class NoteEditorSheet extends StatefulWidget {
  final NoteItem? initialNote;
  final List<String> availableFolders;
  final ValueChanged<NoteItem>? onSave;

  const NoteEditorSheet({
    super.key,
    this.initialNote,
    this.availableFolders = const ['Work', 'Architecture', 'Personal', 'Ideas'],
    this.onSave,
  });

  /// Helper static method to open the note editor sheet.
  static Future<NoteItem?> show(
    BuildContext context, {
    NoteItem? initialNote,
    List<String> availableFolders = const [
      'Work',
      'Architecture',
      'Personal',
      'Ideas',
    ],
  }) {
    return showModalBottomSheet<NoteItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => NoteEditorSheet(
        initialNote: initialNote,
        availableFolders: availableFolders,
      ),
    );
  }

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late String _selectedFolder;
  late bool _isPinned;
  String? _titleError;

  bool get _isEditing => widget.initialNote != null;

  @override
  void initState() {
    super.initState();
    final note = widget.initialNote;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _selectedFolder =
        note?.folder ??
        (widget.availableFolders.isNotEmpty
            ? widget.availableFolders.first
            : 'Work');
    _isPinned = note?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _titleError = 'Title cannot be empty';
      });
      return;
    }

    final content = _contentController.text.trim();
    final NoteItem result;

    if (_isEditing) {
      // Preserve ID, attachments count, and update timestamp
      result = widget.initialNote!.copyWith(
        title: title,
        content: content,
        folder: _selectedFolder,
        isPinned: _isPinned,
        updatedAt: DateTime.now(),
      );
    } else {
      result = NoteItem(
        id: 'note-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        content: content,
        folder: _selectedFolder,
        isPinned: _isPinned,
        updatedAt: DateTime.now(),
      );
    }

    widget.onSave?.call(result);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Edit Note' : 'Create Note',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title Field with validation
            TextField(
              controller: _titleController,
              autofocus: true,
              onChanged: (val) {
                if (_titleError != null && val.trim().isNotEmpty) {
                  setState(() {
                    _titleError = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Note Title *',
                hintText: 'e.g. Sprint Architecture Sync',
                errorText: _titleError,
              ),
            ),
            const SizedBox(height: 12),

            // Content / Body Field
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Note Content',
                hintText: 'Type your meeting notes, ideas, or documentation...',
              ),
            ),
            const SizedBox(height: 14),

            // Folder and Pinned Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Folder',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: widget.availableFolders.map((f) {
                          final isSelected = f == _selectedFolder;
                          return ChoiceChip(
                            label: Text(f),
                            selected: isSelected,
                            selectedColor: AppColors.primaryContainer,
                            backgroundColor: AppColors.surfaceVariant,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedFolder = f;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Pinned toggle
                Column(
                  children: [
                    const Text(
                      'Pin',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        color: _isPinned
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPinned = !_isPinned;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action Buttons: Cancel and Save
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    child: Text(_isEditing ? 'Save Changes' : 'Save Note'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
