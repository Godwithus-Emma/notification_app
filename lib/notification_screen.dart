import 'package:flutter/material.dart';
import 'package:notification_app/datetime_picker.dart';
import 'package:notification_app/notice_service.dart'; 

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  DateTime? _scheduledDateTime;

  void _scheduleNotification() async {
    final selectedDateTime = await pickDateTime(context);
    if (selectedDateTime == null) return;

    setState(() => _scheduledDateTime = selectedDateTime);

    await NoticeService().scheduleNotification(
      id: 1,
      title: 'Scheduled Reminder',
      body: 'This is your scheduled notification!',
      hour: selectedDateTime.hour,
      minute: selectedDateTime.minute,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification scheduled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification App')),
      body: Center(
        child: Text(
          _scheduledDateTime == null
              ? 'Welcome to the Notification App'
              : 'Next scheduled notification:\n$_scheduledDateTime',
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
            onPressed: _scheduleNotification,
            child: const Icon(Icons.schedule),
          ),
        ],
      ),
    );
  }
}
