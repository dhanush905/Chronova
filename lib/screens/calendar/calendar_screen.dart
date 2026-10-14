import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/chronova_data_store.dart';
import '../../models/event_item.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/event_editor_sheet.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/status_badge.dart';

/// Calendar screen featuring customizable categories, search, date strip, and event management.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  String? _selectedCategoryId;
  String _searchQuery = '';
  final bool _isLoading = false;
  final String? _errorMessage = null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  List<EventItem> _getFilteredEvents(List<EventItem> allEvents) {
    return allEvents.where((event) {
      // Check date matching (ignoring time)
      final eventDay = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final isSameDay = eventDay.isAtSameMomentAs(_selectedDate);

      // Check category filter
      final matchesCategory =
          _selectedCategoryId == null ||
          event.category.id == _selectedCategoryId;

      // Check search query
      final matchesSearch =
          _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          event.location.toLowerCase().contains(_searchQuery.toLowerCase());

      return isSameDay && matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _showAddEventDialog() async {
    final newEvent = await EventEditorSheet.show(
      context,
      initialDate: _selectedDate,
    );

    if (newEvent != null && mounted) {
      ChronovaDataStore.instance.addEvent(newEvent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event scheduled successfully'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _showEditEventDialog(EventItem event) async {
    final updatedEvent = await EventEditorSheet.show(
      context,
      initialEvent: event,
    );

    if (updatedEvent != null && mounted) {
      ChronovaDataStore.instance.updateEvent(updatedEvent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event updated successfully'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _confirmDeleteEvent(EventItem event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Event',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ChronovaDataStore.instance.deleteEvent(event.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthYearStr = DateFormat('MMMM y').format(_selectedDate);

    return ListenableBuilder(
      listenable: ChronovaDataStore.instance,
      builder: (context, _) {
        final store = ChronovaDataStore.instance;
        final categories = store.categories;
        final filteredEvents = _getFilteredEvents(store.events);

        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            onPressed: _showAddEventDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Event'),
          ),
          body: SafeArea(
            child: ResponsiveContainer(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar with Month Navigation
                  _buildMonthNavigator(monthYearStr),
                  const SizedBox(height: 14),

                  // Date Selector Strip (Day selector)
                  _buildDateStrip(),
                  const SizedBox(height: 16),

                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 12),

                  // Category Filter Chips
                  _buildCategoryChips(categories),
                  const SizedBox(height: 14),

                  // Event List Area with state handling
                  Expanded(child: _buildEventListArea(filteredEvents)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthNavigator(String monthYearStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calendar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              monthYearStr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton.filledTonal(
              icon: const Icon(Icons.chevron_left_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
              ),
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day - 7,
                  );
                });
              },
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              icon: const Icon(Icons.chevron_right_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
              ),
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day + 7,
                  );
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateStrip() {
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    return SizedBox(
      height: 74,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = startOfWeek.add(Duration(days: index));
          final isSelected =
              day.year == _selectedDate.year &&
              day.month == _selectedDate.month &&
              day.day == _selectedDate.day;
          final isToday =
              day.year == DateTime.now().year &&
              day.month == DateTime.now().month &&
              day.day == DateTime.now().day;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
              });
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isToday ? AppColors.primaryLight : AppColors.border),
                  width: isToday && !isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white70
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (val) {
        setState(() {
          _searchQuery = val;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search events, tags, or location...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }

  Widget _buildCategoryChips(List<EventCategory> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All Categories'),
            selected: _selectedCategoryId == null,
            selectedColor: AppColors.primaryContainer,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: _selectedCategoryId == null
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: _selectedCategoryId == null
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            side: BorderSide(
              color: _selectedCategoryId == null
                  ? AppColors.primary
                  : AppColors.border,
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedCategoryId = null;
                });
              }
            },
          ),
          ...categories.map((category) {
            final isSelected = _selectedCategoryId == category.id;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(category.name),
                selected: isSelected,
                selectedColor: category.color.withAlpha(35),
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? category.color : AppColors.textSecondary,
                ),
                side: BorderSide(
                  color: isSelected ? category.color : AppColors.border,
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedCategoryId = selected ? category.id : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEventListArea(List<EventItem> events) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              style: const TextStyle(color: AppColors.danger),
            ),
          ],
        ),
      );
    }

    if (events.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(80),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No events for this date',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap "+ New Event" to schedule your activities.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _showAddEventDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Event Now'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final timeFormat = DateFormat('h:mm a');
        final timeStr =
            '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            onTap: () => _showEditEventDialog(event),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 52,
                  decoration: BoxDecoration(
                    color: event.category.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          StatusBadge(
                            label: event.category.name,
                            color: event.category.color,
                          ),
                        ],
                      ),
                      if (event.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (event.location.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                event.location,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _showEditEventDialog(event);
                    } else if (val == 'delete') {
                      _confirmDeleteEvent(event);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.danger,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
