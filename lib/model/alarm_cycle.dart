import 'package:darty_json/darty_json.dart';

class AlarmCycle {
  int position;
  List<bool> cycle;
  AlarmCycle(
    this.position,
    this.cycle,
  );

  AlarmCycle.fromJson(Json json)
      : position = json["position"].integerValue,
        cycle = json["cycle"].listOf(
              (p0) => p0 as bool,
            ) ??
            <bool>[];


  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['position'] = position;
    map['cycle'] = cycle;
    return map;
  }
}
