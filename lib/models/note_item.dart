/// Represents a rich note item organized in folders with optional attachments.
class NoteItem {
  final String id;
  final String title;
  final String content;
  final String folder;
  final DateTime updatedAt;
  final int attachmentCount;
  final bool isPinned;

  const NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.folder,
    required this.updatedAt,
    this.attachmentCount = 0,
    this.isPinned = false,
  });

  NoteItem copyWith({
    String? id,
    String? title,
    String? content,
    String? folder,
    DateTime? updatedAt,
    int? attachmentCount,
    bool? isPinned,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      folder: folder ?? this.folder,
      updatedAt: updatedAt ?? this.updatedAt,
      attachmentCount: attachmentCount ?? this.attachmentCount,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
