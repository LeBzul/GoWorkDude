import 'package:flutter/material.dart';
import 'package:goworkdude/main.dart';
import 'package:goworkdude/model/alarm.dart';

import 'day_list_widget.dart';

class CycleDayListWidget extends StatefulWidget {
  final void Function(List<AlarmCycle>) listChanged;
  final void Function(AlarmCycle dayList, int index)? removedDayList;

  final List<AlarmCycle> cycleDayList;
  final bool enableInteraction;
  final bool collapsed;
  final bool activated;

  const CycleDayListWidget({
    Key? key,
    required this.collapsed,
    required this.listChanged,
    required this.removedDayList,
    required this.cycleDayList,
    required this.activated,
    required this.enableInteraction,
  }) : super(key: key);

  @override
  CycleDayListWidgetState createState() => CycleDayListWidgetState();
}

class CycleDayListWidgetState extends State<CycleDayListWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: buildDayList(),
    );
  }

  List<Widget> buildDayList() {
    List<Widget> listDay = [];
    if (widget.collapsed) {
      listDay.add(
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  language["cycle_0"],
                  style: TextStyle(
                      color: widget.activated
                          ? Theme.of(context).colorScheme.inversePrimary
                          : Theme.of(context).primaryColor),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: DayListWidget(
                activated: widget.activated,
                dayList: widget.cycleDayList.first,
                enableInteraction: widget.enableInteraction,
                listChanged: (newDayList) {
                  widget.cycleDayList.first = newDayList;
                  widget.listChanged(widget.cycleDayList);
                },
                removed: null,
              ),
            ),
          ],
        ),
      );
      return listDay;
    }

    int i = 0;
    for (var dayList in widget.cycleDayList) {
      int index = i;
      listDay.add(
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  i == 0
                      ? language["cycle_0"]
                      : i == 1
                          ? language["cycle_1"]
                          : "${language["cycle_other_0"]} $i ${language["cycle_other_1"]}",
                  style: TextStyle(
                      color: widget.activated
                          ? Theme.of(context).colorScheme.inversePrimary
                          : Theme.of(context).primaryColor),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: DayListWidget(
                activated: widget.activated,
                dayList: dayList,
                enableInteraction: widget.enableInteraction,
                listChanged: (newDayList) {
                  dayList = newDayList;
                  widget.listChanged(widget.cycleDayList);
                },
                removed: i == 0
                    ? null
                    : (removedDayList) {
                        widget.removedDayList?.call(
                          removedDayList,
                          index,
                        );
                      },
              ),
            ),
          ],
        ),
      );
      i++;
    }

    return listDay;
  }
}
