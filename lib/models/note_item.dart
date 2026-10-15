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

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      folder: json['folder'] as String? ?? 'Work',
      isPinned: json['is_pinned'] as bool? ?? false,
      attachmentCount: (json['attachment_count'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson({String? userId}) {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'content': content,
      'folder': folder,
      'is_pinned': isPinned,
      'attachment_count': attachmentCount,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
    if (userId != null) {
      map['user_id'] = userId;
    }
    return map;
  }
}
