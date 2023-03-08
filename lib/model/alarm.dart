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

  /// Retourne un DateTime de la date d'aujourd'hui ou la date de demain
  /// si l'alarme est activé le jour la
  DateTime? getNextDateAlarm() {
    /// Si l'alarme est désactivé, il n'y a pas de prochain alarme
    if (!activated) {
      return null;
    }
    DateTime now = DateTime.now();
    DateTime todayAlarm = getTodayAlarm();
    DateTime nextAlarm;
    switch (now.compareTo(todayAlarm)) {

      /// 0 ou 1  l'alarme d'ajourd'hui est déjà passé, on prend demain
      case 0:
      case 1:
        nextAlarm = todayAlarm.add(const Duration(days: 1));
        if (nextAlarm.weekday - 1 == 0) {
          /// Demain est une nouvelle semaine, il faut regarder dans le cycle prochain
          if (_orderedCycleList().length > 1) {
            /// Si y a plusieurs cycle
            return _orderedCycleList()[1][nextAlarm.weekday - 1] == true ? nextAlarm : null;
          } else {
            /// Si y a qu'un cycle
            return getActualCycleList()[nextAlarm.weekday - 1] == true ? nextAlarm : null;
          }
        } else {
          /// Si demain est dans le cycle actuel
          return getActualCycleList()[nextAlarm.weekday - 1] == true ? nextAlarm : null;
        }

      /// -1 l'alarme d'ajourd'hui n'est pas encore passé
      default:
        return getActualCycleList()[todayAlarm.weekday - 1] == true ? todayAlarm : null;
    }
  }

  /// Retourne le cycle de jour de la semaine en cours
  List<bool> getActualCycleList() {
    return _orderedCycleList().first;
  }

  /// Retourne le cycle de jour des semaines ordonné selon la date actuel
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

  /// Retourne l'index du cycle de la semaine actuel
  int _indexOfActualWeek() {
    DateTime now = DateTime.now();
    DateTime nowUp = now;
    Duration duration = nowUp.difference(referenceDate);
    double nbWeek = (duration.inDays / 7);
    return (nbWeek % _cycleList.length).toInt();
  }

  /// Pour crée un cycle de jour rapidement
  static List<bool> defaultCycle() {
    return [
      true,
      true,
      true,
      true,
      true,
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
