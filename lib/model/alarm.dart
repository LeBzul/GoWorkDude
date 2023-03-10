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

  void removeCycle(AlarmCycle cycle, int index) {
    _cycleList.removeAt(cycle.originalPosition);
  }

  set cycleList(List<AlarmCycle> cycleList) {
    int i = 0;
    int max = cycleList.length;
    List<List<bool>> newList = <List<bool>>[];
    while (i < max) {
      for (var element in cycleList) {
        if (element.originalPosition == i) {
          newList.add(element.cycle);
        }
      }
      i++;
    }
    _cycleList = newList;
  }

  String hourToString() {
    return '${hour < 10 ? '0$hour' : hour}:${minute < 10 ? '0$minute' : minute}';
  }

  List<AlarmCycle> getCycleList() {
    List<AlarmCycle> cycleList = <AlarmCycle>[];
    int i = 0;
    for (var element in _cycleList) {
      cycleList.add(AlarmCycle(i++, element));
    }
    return cycleList;
  }

  bool isActivateToday() {
    return getActualCycleList().cycle[getTodayAlarm().weekday - 1];
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
  DateTime? findNextDateTimeAlarm() {
    /// Si l'alarme est désactivé, il n'y a pas de prochain alarme
    if (!activated) {
      return null;
    }

    DateTime now = DateTime.now();
    DateTime nextDateAlarm = getTodayAlarm();
/*
    int dayIndex = 0;
    int cycleIndex = 0;
    switch (now.compareTo(nextDateAlarm)) {

      /// 0 ou 1  l'alarme d'ajourd'hui est déjà passé, on prend demain
      case 0:
      case 1:
        nextDateAlarm = nextDateAlarm.add(const Duration(days: 1));
        dayIndex = nextDateAlarm.weekday - 1;

        /// Si le prochain jour est lundi, on change de semaine / cycle
        /// Si l'index depasse la taille on repart de 0 pour analyser les jours du 1er cycle non traité
        if (dayIndex == 0 && cycleIndex < orderedCycleList().length) {
          cycleIndex = 1;
        }
        break;

      /// -1 l'alarme d'ajourd'hui n'est pas encore passé
      default:
        dayIndex = nextDateAlarm.weekday - 1;
    }
*/
    int dayIndex = nextDateAlarm.weekday - 1;
    int cycleIndex = 0;

    /// Nombre de jours maximum à vérifier
    int numberOfDays = orderedCycleList().length * 7;
    int i = 0;
    bool todayDate = true;
    while (numberOfDays >= i) {
      nextDateAlarm = getTodayAlarm().add(Duration(days: i));

      /// On a trouvé la prochaine alarm
      if (orderedCycleList()[cycleIndex].cycle[dayIndex] &&
          (todayDate == false || (todayDate && now.compareTo(nextDateAlarm) == -1))) {
        i = numberOfDays;
        return nextDateAlarm;
      }
      i++;
      todayDate = false;
      dayIndex = getTodayAlarm().add(Duration(days: i)).weekday - 1;

      /// Si le prochain jour est lundi, on change de semaine
      if (dayIndex == 0) {
        cycleIndex++;

        /// Si l'index depasse la taille on repart de 0 pour analyser les jours du 1er cycle non traité
        if (cycleIndex >= orderedCycleList().length) {
          cycleIndex = 0;
        }
      }
    }
    return null;
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
          if (orderedCycleList().length > 1) {
            /// Si y a plusieurs cycle
            return orderedCycleList()[1].cycle[nextAlarm.weekday - 1] == true ? nextAlarm : null;
          } else {
            /// Si y a qu'un cycle
            return getActualCycleList().cycle[nextAlarm.weekday - 1] == true ? nextAlarm : null;
          }
        } else {
          /// Si demain est dans le cycle actuel
          return getActualCycleList().cycle[nextAlarm.weekday - 1] == true ? nextAlarm : null;
        }

      /// -1 l'alarme d'ajourd'hui n'est pas encore passé
      default:
        return getActualCycleList().cycle[todayAlarm.weekday - 1] == true ? todayAlarm : null;
    }
  }

  /// Retourne le cycle de jour de la semaine en cours
  AlarmCycle getActualCycleList() {
    return orderedCycleList().first;
  }

  /// Retourne le cycle de jour des semaines ordonné selon la date actuel
  List<AlarmCycle> orderedCycleList() {
    List<AlarmCycle> orderedList = <AlarmCycle>[];
    int startedIndex = _indexOfActualWeek();

    int index = 0;
    for (int i = 0; i < _cycleList.length; i++) {
      if (startedIndex + i < _cycleList.length) {
        orderedList.add(AlarmCycle(startedIndex + i, _cycleList[startedIndex + i]));
      } else {
        orderedList.add(AlarmCycle(index, _cycleList[index]));
        index++;
      }
    }

    return orderedList;
  }

  /// Retourne l'index du cycle de la semaine actuel
  int _indexOfActualWeek() {
    DateTime now = DateTime.now();
    DateTime nowUp = now; //now.add(Duration(days: 7)); /// Juste pour test
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
    map['cycleList'] = _cycleList;
    map['referenceDate'] = referenceDate.microsecondsSinceEpoch;
    return map;
  }
}

class AlarmCycle {
  /// Position réel dans la liste des cycle pour cette alarme
  int originalPosition;

  /// Cycle des jours
  List<bool> cycle;
  AlarmCycle(
    this.originalPosition,
    this.cycle,
  );
}
