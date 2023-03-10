import 'package:auto_size_text/auto_size_text.dart';
import 'package:darty_json/darty_json.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:goworkdude/core/helper/date_helper.dart';

import '../controller/notification_controller.dart';
import '../model/alarm.dart';

class AlarmScreen extends StatefulWidget {
  final NotificationResponse? details;
  final bool playSound;

  const AlarmScreen({Key? key, this.details, this.playSound = false}) : super(key: key);

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
    if (widget.playSound) {
      FlutterRingtonePlayer.play(
        android: AndroidSounds.alarm,
        fromAsset: "assets/praveen.mp3",
        looping: true,
        asAlarm: true, // Android only - all APIs
      );
    }
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
        Stack(
          children: [
            ElevatedButton(
              onPressed: () {
                NotificationController.instance.snoozeAction(alarm);
                _closeApp();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                shape: const CircleBorder(),
                maximumSize: const Size(110, 110),
                minimumSize: const Size(110, 110),
              ),
              child: const AutoSizeText(
                'Snooze',
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        Spacer(),
        Stack(
          children: [
            ElevatedButton(
              onPressed: () {
                NotificationController.instance.stopNotification(alarm);
                _closeApp();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: const CircleBorder(),
                maximumSize: const Size(110, 110),
                minimumSize: const Size(110, 110),
              ),
              child: const AutoSizeText(
                'Stop',
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// TODO: faire un controller pour ce screen
  /// Close App
  void _closeApp() {
    FlutterRingtonePlayer.stop();
    SystemNavigator.pop();
  }
}
