import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/calendar_event_model.dart';
import '../../core/utils/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../screens/calendar/add_edit_event_screen.dart';

class EventCard extends StatelessWidget {
  final CalendarEventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: Responsive.spacing12),
      child: InkWell(
        onTap: () =>
            Get.to(() => AddEditEventScreen(date: event.date, event: event)),
        borderRadius: BorderRadius.circular(Responsive.radius12),
        child: Padding(
          padding: EdgeInsets.all(Responsive.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: TextStyle(
                  fontSize: Responsive.fontSize18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: Responsive.spacing8),
              if (event.time != null)
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: Responsive.iconSize20,
                      color: AppTheme.accentColor,
                    ),
                    SizedBox(width: Responsive.spacing8),
                    Text(
                      '${event.time} PKT',
                      style: TextStyle(
                        fontSize: Responsive.fontSize14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              if (event.location != null) ...[
                SizedBox(height: Responsive.spacing4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: Responsive.iconSize20,
                      color: AppTheme.accentColor,
                    ),
                    SizedBox(width: Responsive.spacing8),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: TextStyle(
                          fontSize: Responsive.fontSize14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (event.reminderTime != null) ...[
                SizedBox(height: Responsive.spacing4),
                Row(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: Responsive.iconSize20,
                      color: AppTheme.accentColor,
                    ),
                    SizedBox(width: Responsive.spacing8),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy hh:mm a',
                      ).format(event.reminderTime!),
                      style: TextStyle(
                        fontSize: Responsive.fontSize12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
