import 'package:flutter/material.dart';

import 'day_list_widget.dart';

class CycleDayListWidget extends StatefulWidget {
  final void Function(List<List<bool>>) listChanged;
  final void Function(List<bool> dayList, int index)? removedDayList;

  final List<List<bool>> cycleDayList;
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
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Semaine actuel"),
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
                child: Text("Semaine ${i + 1}"),
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
