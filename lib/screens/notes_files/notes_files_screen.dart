import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/sample_data.dart';
import '../../models/note_item.dart';
import '../../models/file_item.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/status_badge.dart';

/// Notes and Files screen offering organized notes by folder
/// and document management with file import preview and confirmation.
class NotesFilesScreen extends StatefulWidget {
  const NotesFilesScreen({super.key});

  @override
  State<NotesFilesScreen> createState() => _NotesFilesScreenState();
}

class _NotesFilesScreenState extends State<NotesFilesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<NoteItem> _notes;
  late List<FileItem> _files;
  String? _selectedFolder;
  String _noteSearchQuery = '';
  String _fileSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _notes = SampleData.getSampleNotes();
    _files = SampleData.getSampleFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> get _folders {
    final set = <String>{'All'};
    for (var n in _notes) {
      set.add(n.folder);
    }
    return set.toList();
  }

  List<NoteItem> get _filteredNotes {
    return _notes.where((note) {
      final matchesFolder =
          _selectedFolder == null ||
          _selectedFolder == 'All' ||
          note.folder == _selectedFolder;
      final matchesQuery =
          _noteSearchQuery.isEmpty ||
          note.title.toLowerCase().contains(_noteSearchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_noteSearchQuery.toLowerCase());
      return matchesFolder && matchesQuery;
    }).toList();
  }

  List<FileItem> get _filteredFiles {
    return _files.where((file) {
      return _fileSearchQuery.isEmpty ||
          file.name.toLowerCase().contains(_fileSearchQuery.toLowerCase()) ||
          file.fileType.label.toLowerCase().contains(
            _fileSearchQuery.toLowerCase(),
          );
    }).toList();
  }

  void _showNewNoteDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String folder = 'Work';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create Note',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Note Title',
                hintText: 'e.g. Project Brainstorm',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Type your thoughts, meeting notes, or ideas...',
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty) return;
                  setState(() {
                    _notes.insert(
                      0,
                      NoteItem(
                        id: 'note-${DateTime.now().millisecondsSinceEpoch}',
                        title: titleCtrl.text.trim(),
                        content: contentCtrl.text.trim(),
                        folder: folder,
                        updatedAt: DateTime.now(),
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note created successfully')),
                  );
                },
                child: const Text('Save Note'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportPreviewDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.file_upload_outlined, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              'Import File Preview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.description_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Team_Sprint_Schedule.csv',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '4 events detected for import',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Detected Events:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildDetectedEventItem(
              '1. Sprint Retro',
              '10:00 AM • Engineering',
            ),
            _buildDetectedEventItem(
              '2. Product Showcase',
              '02:00 PM • Product Design',
            ),
            _buildDetectedEventItem('3. Sync Call', '04:30 PM • Strategy'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('3 events imported and synced to Calendar!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Confirm & Import'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedEventItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: _showNewNoteDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Note'),
            )
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: _showImportPreviewDialog,
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Import File'),
            ),
      body: SafeArea(
        child: ResponsiveContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Notes & Files',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Segmented Tabs
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primary,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  onTap: (index) {
                    setState(() {});
                  },
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_note_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Notes'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_shared_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Files & Import'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tab View Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildNotesTab(), _buildFilesTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesTab() {
    final notes = _filteredNotes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search
        TextField(
          onChanged: (val) {
            setState(() {
              _noteSearchQuery = val;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search notes by keyword...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: 12),

        // Folder Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _folders.map((folder) {
              final isSelected = (_selectedFolder ?? 'All') == folder;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(folder),
                  selected: isSelected,
                  selectedColor: AppColors.primaryContainer,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedFolder = selected ? folder : 'All';
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Notes List
        Expanded(
          child: notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.note_alt_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No notes found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Create a new note to keep your thoughts organized.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final dateStr = DateFormat(
                      'MMM d, h:mm a',
                    ).format(note.updatedAt);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CustomCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (note.isPinned) ...[
                                  const Icon(
                                    Icons.push_pin_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Expanded(
                                  child: Text(
                                    note.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                StatusBadge(
                                  label: note.folder,
                                  color: AppColors.primary,
                                  fontSize: 10,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              note.content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                if (note.attachmentCount > 0) ...[
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.attach_file_rounded,
                                    size: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${note.attachmentCount}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilesTab() {
    final files = _filteredFiles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Import Banner Card
        CustomCard(
          backgroundColor: AppColors.primaryContainer.withAlpha(50),
          borderColor: AppColors.primary.withAlpha(60),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Import & Preview Events',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Import CSV, PDF schedules, Spreadsheets, or Images with preview before syncing.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _showImportPreviewDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text('Import'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Files Search
        TextField(
          onChanged: (val) {
            setState(() {
              _fileSearchQuery = val;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search documents by filename...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: 14),

        // Files List
        Expanded(
          child: files.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No files found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final dateStr = DateFormat(
                      'MMM d, y',
                    ).format(file.uploadedAt);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CustomCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: file.fileType.color.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                file.fileType.icon,
                                color: file.fileType.color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      StatusBadge(
                                        label: file.fileType.label,
                                        color: file.fileType.color,
                                        fontSize: 9,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${file.sizeString} • $dateStr',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (file.linkedEventsCount > 0)
                              StatusBadge(
                                label: '${file.linkedEventsCount} events',
                                color: AppColors.primary,
                                icon: Icons.event_rounded,
                                fontSize: 10,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
