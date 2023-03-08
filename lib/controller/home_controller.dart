import 'dart:async';
import 'dart:convert';

import 'package:darty_json/darty_json.dart';

import '../main.dart';
import '../model/alarm.dart';
import 'notification_controller.dart';

class HomeController {
  List<Alarm> get list => _getListAlarm();

  List<Alarm> _getListAlarm() {
    List<Alarm> list = <Alarm>[];
    AlarmManagerApp.prefs.getKeys().forEach(
      (element) {
        String? stringAlarm = AlarmManagerApp.prefs.getString(element);
        if (stringAlarm == null) {
          return;
        }
        list.add(
          Alarm.fromJson(
            Json.fromString(stringAlarm),
          ),
        );
      },
    );

    list.sort(
      (a, b) => a.id.compareTo(
        b.id,
      ),
    );
    return list;
  }

  void removeDayList(Alarm alarm, List<bool> dayList, int index) {
    alarm.removeCycle(dayList, index);
    NotificationController.instance.startNotification(alarm);
  }

  Future<void> removeAlarm(Alarm alarm) async {
    await AlarmManagerApp.prefs.remove('alarm-${alarm.id}');
    NotificationController.instance.stopNotification(alarm);
  }

  Future<void> putOrAddAlarm(Alarm alarm) async {
    await AlarmManagerApp.prefs.setString(
      'alarm-${alarm.id}',
      jsonEncode(alarm),
    );

    NotificationController.instance.startNotification(alarm);
  }
}
