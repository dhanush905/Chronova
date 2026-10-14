import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../data/chronova_data_store.dart';
import '../models/event_item.dart';

/// Bottom sheet dialog for creating and editing calendar events.
/// Handles title validation, interactive date/time pickers, and dynamic category selection.
class EventEditorSheet extends StatefulWidget {
  final EventItem? initialEvent;
  final DateTime? initialDate;
  final ValueChanged<EventItem>? onSave;

  const EventEditorSheet({
    super.key,
    this.initialEvent,
    this.initialDate,
    this.onSave,
  });

  /// Helper static method to display the sheet easily from any screen.
  static Future<EventItem?> show(
    BuildContext context, {
    EventItem? initialEvent,
    DateTime? initialDate,
  }) {
    return showModalBottomSheet<EventItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => EventEditorSheet(
        initialEvent: initialEvent,
        initialDate: initialDate,
      ),
    );
  }

  @override
  State<EventEditorSheet> createState() => _EventEditorSheetState();
}

class _EventEditorSheetState extends State<EventEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late EventCategory _selectedCategory;

  String? _titleError;

  bool get _isEditing => widget.initialEvent != null;

  @override
  void initState() {
    super.initState();
    final event = widget.initialEvent;
    final storeCategories = ChronovaDataStore.instance.categories;

    _titleController = TextEditingController(text: event?.title ?? '');
    _descriptionController = TextEditingController(
      text: event?.description ?? '',
    );
    _locationController = TextEditingController(text: event?.location ?? '');

    if (event != null) {
      _selectedDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      _startTime = TimeOfDay.fromDateTime(event.startTime);
      _endTime = TimeOfDay.fromDateTime(event.endTime);
      // Ensure selected category matches current list by ID, or fallback
      _selectedCategory = storeCategories.firstWhere(
        (c) => c.id == event.category.id,
        orElse: () => event.category,
      );
    } else {
      final baseDate = widget.initialDate ?? DateTime.now();
      _selectedDate = DateTime(baseDate.year, baseDate.month, baseDate.day);
      _startTime = const TimeOfDay(hour: 10, minute: 0);
      _endTime = const TimeOfDay(hour: 11, minute: 0);
      _selectedCategory = storeCategories.isNotEmpty
          ? storeCategories.first
          : const EventCategory(
              id: 'cat-default',
              name: 'General',
              color: AppColors.primary,
            );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
        // If end time is before or equal to start time, adjust end time by 1 hour
        final startMinutes = _startTime.hour * 60 + _startTime.minute;
        final endMinutes = _endTime.hour * 60 + _endTime.minute;
        if (endMinutes <= startMinutes) {
          _endTime = TimeOfDay(
            hour: (_startTime.hour + 1) % 24,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _titleError = 'Title cannot be empty';
      });
      return;
    }

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    DateTime endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    // If end time is before start time, assume it ends next day or push by 1 hour
    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      endDateTime = startDateTime.add(const Duration(hours: 1));
    }

    final EventItem resultEvent;
    if (_isEditing) {
      // Preserve ID and existing completion state
      resultEvent = widget.initialEvent!.copyWith(
        title: title,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        category: _selectedCategory,
      );
    } else {
      resultEvent = EventItem(
        id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        category: _selectedCategory,
      );
    }

    widget.onSave?.call(resultEvent);
    Navigator.of(context).pop(resultEvent);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ChronovaDataStore.instance.categories;
    final dateDisplay = DateFormat('EEE, MMM d, y').format(_selectedDate);

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
            // Header with Title and Cancel button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Edit Event' : 'New Calendar Event',
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

            // Event Title
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
                labelText: 'Event Title *',
                hintText: 'e.g. Design review with team',
                errorText: _titleError,
              ),
            ),
            const SizedBox(height: 12),

            // Date picker trigger
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dateDisplay,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Start & End Time row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickStartTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _startTime.format(context),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: _pickEndTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _endTime.format(context),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Location
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location / Meeting Link (Optional)',
                hintText: 'e.g. Conference Room 3B or Meet link',
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Notes, agenda, or reminders...',
              ),
            ),
            const SizedBox(height: 14),

            // Customizable Category selector
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isChosen = cat.id == _selectedCategory.id;
                return ChoiceChip(
                  label: Text(cat.name),
                  selected: isChosen,
                  selectedColor: cat.color.withAlpha(40),
                  backgroundColor: AppColors.surfaceVariant,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isChosen ? FontWeight.w700 : FontWeight.w500,
                    color: isChosen ? cat.color : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: isChosen ? cat.color : AppColors.border,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Action Buttons Row: Cancel and Save
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
                    child: Text(_isEditing ? 'Save Changes' : 'Create Event'),
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
