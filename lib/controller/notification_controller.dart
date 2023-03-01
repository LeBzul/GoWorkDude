import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:goworkdude/screen/alarm_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vibration/vibration.dart';

import '../main.dart';
import '../model/alarm.dart';

///  *********************************************
///     NOTIFICATION CONTROLLER
///  *********************************************
@pragma('vm:entry-point')
void alarmLaunched(int id, Map<String, dynamic> param) {
  NotificationController.instance.startNotification();
}

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse details) {
  NotificationController.instance.stopNotification();

  switch (details.actionId) {
    case NotificationController.ACTION_STOP:
      break;
    case NotificationController.ACTION_SNOOZE:
      NotificationController.instance.snoozeAction();
      break;
  }
}

class NotificationController {
  static const String ACTION_STOP = "stop";
  static const String ACTION_SNOOZE = "snooze";
  static const int SNOOZE_ALARM_ID = 9999;

  bool _asNotificationInit = false;

  static NotificationController? _instance;
  NotificationController._() {
    _configureLocalTimeZone();
  }

  static NotificationController get instance => _instance ??= NotificationController._();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotification() async {
    if (_asNotificationInit) {
      return;
    }
    _asNotificationInit = true;
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        AlarmManagerApp.navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            settings: const RouteSettings(name: '/alarm'),
            builder: (context) => AlarmScreen(
              details: details,
            ),
          ),
        );
      },
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    return;
  }

  Future<void> snoozeAction() async {
    _Isolate.instance.snoozeNotification();
  }

  Future<void> stopNotification() async {
    _Isolate.instance.stopNotification();
  }

  Future<void> startNotification() async {
    _Isolate.instance.startNotification();
  }

  Future<void> putOrAddScheduledNotification(Alarm alarm) async {
    _Isolate.instance.putOrAddAlarm(alarm);
  }

  Future<bool> checkPermission() async {
    if (await Permission.notification.status != PermissionStatus.granted) {
      return false;
    }
    return true;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
}

enum IsolateAction {
  startNotification,
  stopNotification,
  snoozeNotification,
}

class _Isolate {
  static const String isolatePort = 'alarm';

  static _Isolate? _instance;
  static _Isolate get instance => _instance ??= _Isolate._();

  _Isolate._() {
    _createIsolate();
  }

  void startNotification() {
    IsolateNameServer.lookupPortByName(isolatePort)?.send(IsolateAction.startNotification);
  }

  void stopNotification() {
    IsolateNameServer.lookupPortByName(isolatePort)?.send(IsolateAction.stopNotification);
  }

  void snoozeNotification() {
    IsolateNameServer.lookupPortByName(isolatePort)?.send(IsolateAction.snoozeNotification);
  }

  void putOrAddAlarm(Alarm alarm) {
    IsolateNameServer.lookupPortByName(isolatePort)?.send(alarm);
  }

  void _createIsolate() {
    ReceivePort receiver = ReceivePort();
    IsolateNameServer.registerPortWithName(receiver.sendPort, isolatePort);
    receiver.listen(
      (message) {
        switch (message) {
          case IsolateAction.startNotification:
            _createNotification();
            break;
          case IsolateAction.stopNotification:
            _cancelNotification();
            break;
          case IsolateAction.snoozeNotification:
            _snoozeNotification();
            break;
          default:
            if (message is Alarm) {
              AndroidAlarmManager.periodic(
                const Duration(minutes: 1),
                message.id,
                alarmLaunched,
                startAt: message.getNextDateTimeAlarm(),
                exact: true,
                wakeup: true,
                rescheduleOnReboot: true,
                allowWhileIdle: true,
              );
            }
        }
      },
    );
  }

  Future<void> _snoozeNotification() async {
    _cancelNotification();
    AndroidAlarmManager.oneShotAt(
      DateTime.now().add(const Duration(minutes: 1)),
      NotificationController.SNOOZE_ALARM_ID,
      alarmLaunched,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
    );
  }

  Future<void> _cancelNotification() async {
    Vibration.cancel();
    FlutterRingtonePlayer.stop();
    await NotificationController.instance.flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> _createNotification() async {
    Vibration.vibrate(duration: 1000, repeat: 1);
    await FlutterRingtonePlayer.playAlarm(asAlarm: true, looping: true);
    await NotificationController.instance.initLocalNotification();
    await NotificationController.instance.flutterLocalNotificationsPlugin.show(
      0,
      "title",
      "body",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'GoWorkDude',
          'Notification de lancement du reveil',
          channelDescription: 'Indispensable pour lancer le reveil',
          priority: Priority.high,
          importance: Importance.high,
          playSound: false,
          ongoing: true,
          autoCancel: false,
          enableVibration: false,
          fullScreenIntent: true,
          chronometerCountDown: true,
          visibility: NotificationVisibility.public,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(NotificationController.ACTION_STOP, 'Stop'),
            AndroidNotificationAction(NotificationController.ACTION_SNOOZE, 'Snooze'),
          ],
        ),
      ),
    );
  }
}
