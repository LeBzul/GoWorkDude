import 'package:auto_size_text/auto_size_text.dart';
import 'package:darty_json/darty_json.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:goworkdude/controller/notification_controller.dart';
import 'package:goworkdude/core/helper/date_helper.dart';

import '../model/alarm.dart';

class AlarmScreen extends StatefulWidget {
  final NotificationResponse? details;

  const AlarmScreen({Key? key, this.details}) : super(key: key);

  @override
  AlarmScreenState createState() => AlarmScreenState();
}

class AlarmScreenState extends State<AlarmScreen> {
  late Alarm alarm;

  @override
  void initState() {
    super.initState();
    String? payload = widget.details?.payload;
    if (payload == null) {
      _closeApp();
      return;
    }
    alarm = Alarm.fromJson(Json.fromString(payload));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 32,
                top: 0,
                bottom: 60,
              ),
              child: Center(
                child: AutoSizeText(
                  DateHelper.dateToHourFormat(DateTime.now()),
                  style: const TextStyle(fontSize: 200),
                  maxLines: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 32,
                bottom: 64,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: buildActions(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Row buildActions() {
    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            children: [
              ElevatedButton(
                onPressed: () {
                  NotificationController.instance.snoozeAction(alarm);
                  _closeApp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(24),
                ),
                child: Container(),
              ),
              const Center(
                child: Text(
                  'Snooze',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              )
            ],
          ),
        ),
        Spacer(),
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            children: [
              ElevatedButton(
                onPressed: () {
                  NotificationController.instance.stopNotification(alarm);
                  _closeApp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(24),
                ),
                child: Container(),
              ),
              const Center(
                child: Text(
                  'Stop',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  /// TODO: faire un controller pour ce screen
  /// Close App
  void _closeApp() {
    SystemNavigator.pop();
  }
}
