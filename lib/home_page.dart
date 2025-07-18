import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notification_app/datetime_picker.dart';
import 'package:notification_app/notice_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _scheduledDateTime;
  String _formatScheduledDateTime(
    DateTime dateTime, {
    bool timeOnly = false,
    String? locale,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final localDateTime = dateTime.toLocal(); 
    final timeFormat = DateFormat.jm(
      locale ?? Intl.getCurrentLocale(),
    ); // 12-hour for user preference
    final time = timeFormat.format(localDateTime); // e.g., "2:30 PM"
    final difference = date.difference(today).inDays;
    final minutesDifference = localDateTime.difference(now).inMinutes;
    final secondsDifference = localDateTime.difference(now).inSeconds;
    if (timeOnly) {
      return time; // For frequent reminders (e.g., hourly)
    }

    if (difference < 0 || (difference == 0 && minutesDifference < 0)) {
      return '${Intl.message('Overdue: ', name: 'overdue')}${difference < 0 ? DateFormat.yMMMMEEEEd(locale).format(localDateTime) : ''} at $time';
    } else if (difference == 0 && minutesDifference < 120) {
      if (minutesDifference < 1) {
        return Intl.message(
          'In $secondsDifference seconds',
          name: 'inSeconds',
          args: [secondsDifference],
        );
      } else if (minutesDifference < 60) {
        return Intl.message(
          'In $minutesDifference minutes',
          name: 'inMinutes',
          args: [minutesDifference],
        );
      } else {
        return Intl.message('In 1 hour', name: 'inOneHour');
      }
    } else if (difference == 0) {
      return Intl.message('Today at $time', name: 'todayAt', args: [time]);
    } else if (difference == 1) {
      return Intl.message(
        'Tomorrow at $time',
        name: 'tomorrowAt',
        args: [time],
      );
    } else if (difference < 7) {
      return Intl.message(
        'In $difference days at $time',
        name: 'inDays',
        args: [difference, time],
      );
    } else {
      return '${DateFormat.yMMMMEEEEd(locale).format(localDateTime)} at $time';
    }
  }

  Future<void> _pickDateTimeAndSchedule() async {
    final selectedDateTime = await pickDateTime(context);
    if (selectedDateTime == null) return;

    setState(() => _scheduledDateTime = selectedDateTime);

    await NoticeService().scheduleNotification(
      title: 'Scheduled Reminder',
      body: 'This is your scheduled notification!',
      hour: selectedDateTime.hour,
      minute: selectedDateTime.minute,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notification scheduled')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification App')),
      body: Center(
        child: Text(
          _scheduledDateTime == null
              ? 'Welcome to the Notification App'
              : 'Next scheduled notification:\n${_formatScheduledDateTime(_scheduledDateTime!)}',
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'notifyNow',
            onPressed: () {
              NoticeService().showNotification(
                title: 'Daily Reminder',
                body: 'This is your daily reminder notification!',
              );
            },
            child: const Icon(Icons.notifications),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'scheduleNotify',
            onPressed: _pickDateTimeAndSchedule,
            child: const Icon(Icons.schedule),
          ),
        ],
      ),
    );
  }
}
