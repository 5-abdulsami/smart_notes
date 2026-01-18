import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../controllers/calendar_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../settings/settings_screen.dart';
import 'add_edit_event_screen.dart';
import '../../widgets/event_card.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController controller = Get.put(CalendarController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, size: Responsive.iconSize24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.today, size: Responsive.iconSize24),
            onPressed: () {
              controller.focusedDay.value = DateTime.now();
              controller.selectedDay.value = DateTime.now();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => Card(
              margin: EdgeInsets.all(Responsive.spacing16),
              child: TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: controller.focusedDay.value,
                selectedDayPredicate: (day) =>
                    isSameDay(controller.selectedDay.value, day),
                onDaySelected: (selected, focused) {
                  controller.onDaySelected(selected, focused);
                  if (controller.getEventsForDay(selected).isEmpty) {
                    Get.to(() => AddEditEventScreen(date: selected));
                  }
                },
                onPageChanged: (focusedDay) {
                  controller.focusedDay.value = focusedDay;
                },
                calendarFormat: CalendarFormat.month,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: Responsive.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: AppTheme.textPrimary,
                    size: Responsive.iconSize28,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: AppTheme.textPrimary,
                    size: Responsive.iconSize28,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: Responsive.fontSize14,
                  ),
                  weekendTextStyle: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: Responsive.fontSize14,
                  ),
                  outsideTextStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: Responsive.fontSize14,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: Responsive.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                  weekendStyle: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: Responsive.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                eventLoader: (day) => controller.getEventsForDay(day),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.spacing16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    DateFormat(
                      'EEEE, MMMM dd, yyyy',
                    ).format(controller.selectedDay.value),
                    style: TextStyle(
                      fontSize: Responsive.fontSize16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Get.to(
                    () =>
                        AddEditEventScreen(date: controller.selectedDay.value),
                  ),
                  icon: Icon(Icons.add, size: Responsive.iconSize20),
                  label: const Text('Add Event'),
                ),
              ],
            ),
          ),
          Divider(color: AppTheme.dividerColor, height: 1),
          Expanded(
            child: Obx(() {
              final events = controller.getEventsForDay(
                controller.selectedDay.value,
              );

              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: Responsive.getWidth(15),
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(height: Responsive.spacing16),
                      Text(
                        'No events for this day',
                        style: TextStyle(
                          fontSize: Responsive.fontSize16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(Responsive.spacing16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return EventCard(event: events[index]);
                },
              );
            }),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.secondaryColor,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: Responsive.spacing24),
              Icon(
                Icons.note_alt,
                size: Responsive.getWidth(20),
                color: AppTheme.accentColor,
              ),
              SizedBox(height: Responsive.spacing12),
              Text(
                'Notes App',
                style: TextStyle(
                  fontSize: Responsive.fontSize24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: Responsive.spacing32),
              Divider(color: AppTheme.dividerColor),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: AppTheme.accentColor,
                  size: Responsive.iconSize24,
                ),
                title: Text(
                  'Settings & Backup',
                  style: TextStyle(
                    fontSize: Responsive.fontSize16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                onTap: () {
                  Get.back();
                  Get.to(() => const SettingsScreen());
                },
              ),
              Divider(color: AppTheme.dividerColor),
            ],
          ),
        ),
      ),
    );
  }
}
