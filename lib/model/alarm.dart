import 'package:darty_json/darty_json.dart';
import 'package:goworkdude/core/extension/date_time.dart';

class Alarm {
  int id;
  int hour;
  int minute;
  bool activated;
  List<List<bool>> _cycleList;
  DateTime referenceDate;

  Alarm({
    required this.hour,
    required this.minute,
    required this.activated,
    required List<List<bool>> cycleList,
    required this.referenceDate,
  })  : _cycleList = cycleList,
        id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Alarm.fromJson(Json json)
      : id = json["id"].integerValue,
        hour = json["hour"].integerValue,
        minute = json["minute"].integerValue,
        activated = json["activated"].booleanValue,
        _cycleList = json["cycleList"].listObjectValue.map((e) => List<bool>.from(e)).toList(),
        referenceDate = DateTime.fromMicrosecondsSinceEpoch(json["referenceDate"].integerValue);

  void addCycle(List<bool> newCycle) {
    _cycleList.add(newCycle);
  }

  void removeCycle(List<bool> cycle, int index) {
    _cycleList.removeAt(index);
  }

  set cycleList(List<List<bool>> cycleList) {
    _cycleList = cycleList;
  }

  String hourToString() {
    return '${hour < 10 ? '0$hour' : hour}:${minute < 10 ? '0$minute' : minute}';
  }

  List<List<bool>> getCycleList() {
    return _cycleList;
  }

  bool isActivateToday() {
    return getActualCycleList()[getTodayAlarm().weekday - 1];
  }

  DateTime getTodayAlarm() {
    DateTime dateTime = DateTime.now();
    DateTime todayAlarm = dateTime.copyWith(
      hour: hour,
      minute: minute,
      second: 0,
      microsecond: 0,
      millisecond: 0,
    );
    return todayAlarm;
  }

  DateTime getNextDateTimeAlarm() {
    DateTime now = DateTime.now();
    DateTime todayAlarm = getTodayAlarm();
    DateTime nextAlarm;
    switch (now.compareTo(todayAlarm)) {
      // 0 ou 1 on prend le lendemain
      case 0:
      case 1:
        nextAlarm = todayAlarm.add(const Duration(days: 1));
        print('getNextDateTimeAlarm (todayAlarm+1) = ${nextAlarm}');
        break;
      // -1 on prend aujourd'hui
      default:
        print('getNextDateTimeAlarm (todayAlarm) = ${todayAlarm}');
        nextAlarm = todayAlarm;
        break;
    }

    return nextAlarm;
  }

  List<bool> getActualCycleList() {
    return _orderedCycleList().first;
  }

  List<List<bool>> _orderedCycleList() {
    List<List<bool>> orderedList = <List<bool>>[];
    int startedIndex = _indexOfActualWeek();

    int index = 0;
    for (int i = 0; i < _cycleList.length; i++) {
      if (startedIndex + i < _cycleList.length) {
        orderedList.add(_cycleList[startedIndex + i]);
      } else {
        orderedList.add(_cycleList[index]);
        index++;
      }
    }

    return orderedList;
  }

  int _indexOfActualWeek() {
    DateTime now = DateTime.now();
    DateTime nowUp = now; //.add(Duration(days: 7 * 2));
    Duration duration = nowUp.difference(referenceDate);
    double nbWeek = (duration.inDays / 7);
    return (nbWeek % _cycleList.length).toInt();
  }

  static List<bool> defaultCycle() {
    return [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['hour'] = hour;
    map['minute'] = minute;
    map['activated'] = activated;
    map['cycleList'] = _cycleList; //cycleMap.map((key, value) => MapEntry(key.toString(), value));
    map['referenceDate'] = referenceDate.microsecondsSinceEpoch;
    return map;
  }
}
