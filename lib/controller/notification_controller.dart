import 'dart:convert';
import 'dart:typed_data';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:app_settings/app_settings.dart';
import 'package:darty_json/darty_json.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:goworkdude/controller/home_controller.dart';
import 'package:goworkdude/screen/alarm_screen.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../main.dart';
import '../model/alarm.dart';

///  *********************************************
///     NOTIFICATION CONTROLLER
///  *********************************************

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse details) async {
  WidgetsFlutterBinding.ensureInitialized();
  AlarmManagerApp.prefs = await SharedPreferences.getInstance();
  Alarm alarm = Alarm.fromJson(
    Json.fromString(details.payload ?? ''),
  );
  NotificationController.instance.stopNotification(alarm);

  switch (details.actionId) {
    case NotificationController.ACTION_STOP:
      // Nothing
      break;
    case NotificationController.ACTION_SNOOZE:
      NotificationController.instance.snoozeAction(alarm);
      break;
  }
}

@pragma('vm:entry-point')
void alarmLaunched(int id, Map<String, dynamic> param) async {
  if (kDebugMode) {
    print("============");
    print("alarmLaunched START");
    print("============");
  }
  WidgetsFlutterBinding.ensureInitialized();
  AlarmManagerApp.prefs = await SharedPreferences.getInstance();
  NotificationController.instance.synchronizeAllAlarm();
}

class NotificationController {
  static const String ACTION_STOP = "stop";
  static const String ACTION_SNOOZE = "snooze";
  static const int SNOOZE_ALARM_ID = -2;

  bool _asNotificationInit = false;

  static NotificationController? _instance;
  NotificationController._() {
    _configureLocalTimeZone();
    _createTimerSynchronizer();
    alarmLaunched(0, <String, dynamic>{});
  }

  static NotificationController get instance => _instance ??= NotificationController._();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotification() async {
    if (_asNotificationInit) {
      return;
    }
    _asNotificationInit = true;
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_notif');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
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

  Future<NotificationAppLaunchDetails?> appLaunchWithNotification() async {
    return await NotificationController.instance.flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }

  void goToAlarm(NotificationAppLaunchDetails notificationAppLaunchDetails) {
    AlarmManagerApp.navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/alarm'),
        builder: (context) => AlarmScreen(
          details: notificationAppLaunchDetails.notificationResponse,
        ),
      ),
    );
  }

  /// Crée un alarmManager qui va resynchroniser les alarm toutes les 12h
  /// - Ceinture bretelle -
  void _createTimerSynchronizer() async {
    if (kDebugMode) {
      print("============");
      print("createTimerSynchronizer");
      print("============");
    }
    // On resynchronise les alarmes 2x/jours
    await AndroidAlarmManager.initialize();
    AndroidAlarmManager.periodic(
      const Duration(hours: 12),
      0,
      alarmLaunched,
      wakeup: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
    );
  }

  Future<void> _createScheduledNotification(Alarm alarm, {bool snooze = false}) async {
    await stopNotification(alarm);

    /// Alarme désactivé
    if (!alarm.activated) {
      if (kDebugMode) {
        print("============");
        print("createScheduledNotification = Alarme désactivé pour ${alarm.id}");
        print("============");
      }
      return;
    }

    DateTime? nextAlarm = alarm.findNextDateTimeAlarm();

    /// Pas d'alarme de prévu
    if (nextAlarm == null && snooze == false) {
      if (kDebugMode) {
        print("============");
        print("createScheduledNotification = Aucune alarme de prévu pour ${alarm.id}");
        print("============");
      }
      return;
    }

    if (kDebugMode) {
      print("=============");
      print("createScheduledNotification $nextAlarm, Snooze : $snooze  pour ${alarm.id}");
      print("=============");
    }
    const int insistentFlag = 4;
    await NotificationController.instance.initLocalNotification();
    await NotificationController.instance.flutterLocalNotificationsPlugin.zonedSchedule(
      snooze == false ? alarm.id : NotificationController.SNOOZE_ALARM_ID,
      language['notif_title'],
      '${language['notif_body']} ${alarm.hourToString()}${snooze == true ? language['notif_body_snooze'] : ''}',
      snooze == false
          ? tz.TZDateTime.from(nextAlarm!, tz.local)
          : tz.TZDateTime.from(
              DateTime.now().add(
                Duration(minutes: 5),
              ),
              tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          language['notif_channel_id'],
          language['notif_channel_name'],
          channelDescription: language['notif_channel_description'],
          priority: Priority.max,
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('praveen'),
          ongoing: true,
          onlyAlertOnce: false,
          additionalFlags: Int32List.fromList(<int>[insistentFlag]),
          autoCancel: false,
          enableVibration: false,
          fullScreenIntent: true,
          chronometerCountDown: true,
          visibility: NotificationVisibility.public,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(NotificationController.ACTION_SNOOZE, 'Snooze'),
            AndroidNotificationAction(NotificationController.ACTION_STOP, 'Stop'),
          ],
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: jsonEncode(alarm),
    );
  }

  Future<void> snoozeAction(Alarm alarm) async {
    return await _createScheduledNotification(alarm, snooze: true);
  }

  Future<void> stopNotification(Alarm alarm) async {
    if (kDebugMode) {
      print("=============");
      print("cancel Notification pour ${alarm.id}");
      print("=============");
    }
    return await NotificationController.instance.flutterLocalNotificationsPlugin.cancel(alarm.id);
  }

  Future<void> startNotification(Alarm alarm) async {
    return await _createScheduledNotification(alarm);
  }

  Future<bool> checkPermission() async {
    Map<Permission, PermissionStatus> permissions = {};
    initLocalNotification();

    PermissionStatus notificationStatus = await Permission.notification.status;
    permissions.putIfAbsent(Permission.notification, () => notificationStatus);

    if (notificationStatus != PermissionStatus.granted) {
      await AppSettings.openNotificationSettings();
      return false;
    }

    PermissionStatus accessNotificationPolicyStatus = await Permission.accessNotificationPolicy.status;
    permissions.putIfAbsent(Permission.accessNotificationPolicy, () => accessNotificationPolicyStatus);

    if (accessNotificationPolicyStatus != PermissionStatus.granted) {
      await OpenSettings.openNotificationPolicyAccessSetting();
      return false;
    }

    PermissionStatus ignoreBatteryOptimizationsStatus = await Permission.ignoreBatteryOptimizations.status;
    permissions.putIfAbsent(Permission.ignoreBatteryOptimizations, () => ignoreBatteryOptimizationsStatus);
    if (ignoreBatteryOptimizationsStatus != PermissionStatus.granted) {
      await AppSettings.openBatteryOptimizationSettings();
      return false;
    }
    return true;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> synchronizeAllAlarm() async {
    if (kDebugMode) {
      print("=============");
      print("synchronizeAllAlarm");
      print("=============");
    }
    for (var alarm in HomeController().list) {
      await startNotification(alarm);
    }
  }
}

/*
enum IsolateEnumAction {
  startNotification,
  stopNotification,
  snoozeNotification,
}

class IsolateAction {
  Alarm alarm;
  IsolateEnumAction action;

  IsolateAction(this.alarm, this.action);
}

class _Isolate {
  static const String isolatePort = 'alarm';

  static _Isolate? _instance;
  static _Isolate get instance => _instance ??= _Isolate._();

  _Isolate._() {
    _createIsolate();
  }

  void execute(IsolateAction isolateAction) {
    IsolateNameServer.lookupPortByName(isolatePort)?.send(isolateAction);
  }

  void _createIsolate() {
    ReceivePort receiver = ReceivePort();
    IsolateNameServer.registerPortWithName(receiver.sendPort, isolatePort);
    receiver.listen(
      (message) {
        switch ((message as IsolateAction).action) {
          case IsolateEnumAction.startNotification:
            _createScheduledNotification(message.alarm);
            break;
          case IsolateEnumAction.stopNotification:
            _cancelNotification(message.alarm);
            break;
          case IsolateEnumAction.snoozeNotification:
            _snoozeNotification(message.alarm);
            break;
          default:
            break;
        }
      },
    );
  }

  Future<void> _snoozeNotification(Alarm alarm) async {
    _createScheduledNotification(
      alarm,
      snooze: true,
    );
  }

  Future<void> _cancelNotification(Alarm alarm) async {
    await NotificationController.instance.flutterLocalNotificationsPlugin.cancel(alarm.id);
  }

  Future<void> _createScheduledNotification(Alarm alarm, {bool snooze = false}) async {
    DateTime? nextAlarm = alarm.getNextDateAlarm();

    /// Pas d'alarme de prévu dans les 24h
    if (nextAlarm == null && snooze == false) {
      return;
    }

    print("=============");
    print("createScheduledNotification $nextAlarm, Snooze : $snooze");
    print("=============");
    const int insistentFlag = 4;
    await NotificationController.instance.initLocalNotification();
    await NotificationController.instance.flutterLocalNotificationsPlugin.zonedSchedule(
      snooze == false ? alarm.id : NotificationController.SNOOZE_ALARM_ID,
      'title',
      'body',
      snooze == false
          ? tz.TZDateTime.from(nextAlarm!, tz.local)
          : tz.TZDateTime.from(
              DateTime.now().add(
                Duration(minutes: 5),
              ),
              tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'GoWorkDude',
          'Notification de lancement du reveil',
          channelDescription: 'Indispensable pour lancer le reveil',
          priority: Priority.max,
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('praveen'),
          ongoing: true,
          onlyAlertOnce: false,
          additionalFlags: Int32List.fromList(<int>[insistentFlag]),
          autoCancel: false,
          enableVibration: false,
          fullScreenIntent: true,
          chronometerCountDown: true,
          visibility: NotificationVisibility.public,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(NotificationController.ACTION_STOP, 'Stop'),
            AndroidNotificationAction(NotificationController.ACTION_SNOOZE, 'Snooze'),
          ],
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: jsonEncode(alarm),
    );
  }
}
*/
