import 'package:flutter/material.dart';

/// Supported file types for Chronova document & event import engine.
enum FileTypeEnum {
  pdf,
  spreadsheet,
  csv,
  document,
  image,
  text,
  other;

  String get label {
    switch (this) {
      case FileTypeEnum.pdf:
        return 'PDF';
      case FileTypeEnum.spreadsheet:
        return 'Spreadsheet';
      case FileTypeEnum.csv:
        return 'CSV';
      case FileTypeEnum.document:
        return 'Document';
      case FileTypeEnum.image:
        return 'Image';
      case FileTypeEnum.text:
        return 'Text';
      case FileTypeEnum.other:
        return 'File';
    }
  }

  IconData get icon {
    switch (this) {
      case FileTypeEnum.pdf:
        return Icons.picture_as_pdf_rounded;
      case FileTypeEnum.spreadsheet:
        return Icons.table_chart_rounded;
      case FileTypeEnum.csv:
        return Icons.grid_on_rounded;
      case FileTypeEnum.document:
        return Icons.description_rounded;
      case FileTypeEnum.image:
        return Icons.image_rounded;
      case FileTypeEnum.text:
        return Icons.article_rounded;
      case FileTypeEnum.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color get color {
    switch (this) {
      case FileTypeEnum.pdf:
        return const Color(0xFFEF4444);
      case FileTypeEnum.spreadsheet:
        return const Color(0xFF10B981);
      case FileTypeEnum.csv:
        return const Color(0xFF059669);
      case FileTypeEnum.document:
        return const Color(0xFF3B82F6);
      case FileTypeEnum.image:
        return const Color(0xFF8B5CF6);
      case FileTypeEnum.text:
        return const Color(0xFF64748B);
      case FileTypeEnum.other:
        return const Color(0xFF94A3B8);
    }
  }
}

/// Managed document/file model in Chronova.
class FileItem {
  final String id;
  final String name;
  final String sizeString;
  final FileTypeEnum fileType;
  final DateTime uploadedAt;
  final int linkedEventsCount;
  final String? previewSnippet;

  const FileItem({
    required this.id,
    required this.name,
    required this.sizeString,
    required this.fileType,
    required this.uploadedAt,
    this.linkedEventsCount = 0,
    this.previewSnippet,
  });
}
