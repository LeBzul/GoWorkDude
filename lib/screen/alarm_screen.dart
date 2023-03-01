import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:goworkdude/controller/notification_controller.dart';

class AlarmScreen extends StatefulWidget {
  final NotificationResponse? details;

  const AlarmScreen({Key? key, this.details}) : super(key: key);

  @override
  AlarmScreenState createState() => AlarmScreenState();
}

class AlarmScreenState extends State<AlarmScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    NotificationController.instance.stopNotification();
                    _closeApp();
                  },
                  child: const Text('STOP'),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    NotificationController.instance.snoozeAction();
                    _closeApp();
                  },
                  child: const Text('SNOOZE'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// TODO: faire un controller pour ce screen
  /// Close App
  void _closeApp() {
    SystemNavigator.pop();
  }
}
