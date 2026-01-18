import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/presentation/widgets/primary_button.dart';
import '../../controllers/calendar_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/calendar_event_model.dart';

class AddEditEventScreen extends StatefulWidget {
  final DateTime date;
  final CalendarEventModel? event;

  const AddEditEventScreen({super.key, required this.date, this.event});

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final CalendarController controller = Get.find<CalendarController>();
  late TextEditingController titleController;
  late TextEditingController locationController;
  late DateTime selectedDate;
  TimeOfDay? selectedTime;
  DateTime? reminderTime;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event?.title ?? '');
    locationController = TextEditingController(
      text: widget.event?.location ?? '',
    );
    selectedDate = widget.event?.date ?? widget.date;

    if (widget.event?.time != null) {
      try {
        final timeParts = widget.event!.time!.split(':');
        selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      } catch (e) {
        selectedTime = null;
      }
    }

    reminderTime = widget.event?.reminderTime;
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    // Dismiss keyboard before showing picker
    FocusScope.of(context).unfocus();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentColor,
              surface: AppTheme.secondaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _selectReminderTime() async {
    // Dismiss keyboard before showing the first picker to prevent it popping up between dialogs
    FocusScope.of(context).unfocus();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: reminderTime ?? selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentColor,
              surface: AppTheme.secondaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(reminderTime ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppTheme.accentColor,
                surface: AppTheme.secondaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          reminderTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveEvent() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter event title');
      return;
    }

    final timeString = selectedTime != null
        ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
        : null;

    if (widget.event == null) {
      controller.addEvent(
        date: selectedDate,
        title: titleController.text.trim(),
        time: timeString,
        location: locationController.text.trim().isEmpty
            ? null
            : locationController.text.trim(),
        reminderTime: reminderTime,
      );
    } else {
      widget.event!.title = titleController.text.trim();
      widget.event!.date = selectedDate;
      widget.event!.time = timeString;
      widget.event!.location = locationController.text.trim().isEmpty
          ? null
          : locationController.text.trim();
      widget.event!.reminderTime = reminderTime;
      controller.updateEvent(widget.event!);
    }
  }

  void _deleteEvent() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.secondaryColor,
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteEvent(widget.event!.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
          actions: widget.event != null
              ? [
                  IconButton(
                    icon: Icon(Icons.delete, size: Responsive.iconSize24),
                    onPressed: _deleteEvent,
                  ),
                ]
              : null,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  hintText: 'Enter event title',
                ),
                style: TextStyle(fontSize: Responsive.fontSize16),
              ),
              SizedBox(height: Responsive.spacing16),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.calendar_today,
                    color: AppTheme.accentColor,
                    size: Responsive.iconSize24,
                  ),
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(selectedDate),
                    style: TextStyle(fontSize: Responsive.fontSize14),
                  ),
                ),
              ),
              SizedBox(height: Responsive.spacing12),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.access_time,
                    color: AppTheme.accentColor,
                    size: Responsive.iconSize24,
                  ),
                  title: const Text('Time (PKT)'),
                  subtitle: Text(
                    selectedTime != null
                        ? selectedTime!.format(context)
                        : 'No time set',
                    style: TextStyle(fontSize: Responsive.fontSize14),
                  ),
                  trailing: selectedTime != null
                      ? IconButton(
                          icon: Icon(Icons.clear, size: Responsive.iconSize20),
                          onPressed: () => setState(() => selectedTime = null),
                        )
                      : null,
                  onTap: _selectTime,
                ),
              ),
              SizedBox(height: Responsive.spacing12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  hintText: 'Enter location',
                  prefixIcon: Icon(Icons.location_on),
                ),
                style: TextStyle(fontSize: Responsive.fontSize16),
              ),
              SizedBox(height: Responsive.spacing16),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: AppTheme.accentColor,
                    size: Responsive.iconSize24,
                  ),
                  title: const Text('Reminder'),
                  subtitle: Text(
                    reminderTime != null
                        ? DateFormat(
                            'MMM dd, yyyy hh:mm a',
                          ).format(reminderTime!)
                        : 'No reminder set',
                    style: TextStyle(fontSize: Responsive.fontSize14),
                  ),
                  trailing: reminderTime != null
                      ? IconButton(
                          icon: Icon(Icons.clear, size: Responsive.iconSize20),
                          onPressed: () => setState(() => reminderTime = null),
                        )
                      : null,
                  onTap: _selectReminderTime,
                ),
              ),
              SizedBox(height: Responsive.spacing32),
              PrimaryButton(text: 'Save', onTap: _saveEvent),
            ],
          ),
        ),
      ),
    );
  }
}
