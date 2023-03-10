import 'package:flutter/material.dart';
import 'package:goworkdude/core/helper/date_helper.dart';

import '../model/alarm.dart';
import 'day_button.dart';

class DayListWidget extends StatefulWidget {
  final void Function(AlarmCycle dayList) listChanged;
  final void Function(AlarmCycle dayList)? removed;

  final AlarmCycle dayList;
  final bool enableInteraction;
  final bool activated;

  const DayListWidget({
    Key? key,
    required this.listChanged,
    required this.removed,
    required this.dayList,
    required this.activated,
    required this.enableInteraction,
  }) : super(key: key);

  @override
  DayListWidgetState createState() => DayListWidgetState();
}

class DayListWidgetState extends State<DayListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: buildDayList(context),
    );
  }

  List<Widget> buildDayList(BuildContext context) {
    List<Widget> listDay = [];
    int i = 0;
    for (var element in widget.dayList.cycle) {
      int index = i;
      listDay.add(
        DayButtonWidget(
          activated: widget.activated,
          letter: DateHelper.getDay(i + 1),
          selected: element,
          size: Size(
            ((MediaQuery.of(context).size.width - 60) / 8),
            ((MediaQuery.of(context).size.width - 60) / 8),
          ),
          enableInteraction: widget.enableInteraction,
          selectChanged: (value) {
            widget.dayList.cycle[index] = value;
            widget.listChanged.call(widget.dayList);
          },
        ),
      );
      i++;
    }

    if (widget.removed != null) {
      listDay.add(const SizedBox(
        width: 8,
      ));

      listDay.add(
        InkWell(
          onTap: () {
            widget.removed?.call(widget.dayList);
          },
          child: Icon(
            Icons.remove_circle_outline,
            color: Theme.of(context).indicatorColor,
          ),
        ),
      );
    }

    return listDay;
  }
}
