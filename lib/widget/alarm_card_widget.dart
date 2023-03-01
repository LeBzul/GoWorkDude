import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../model/alarm.dart';
import 'cycle_day_list_widget.dart';

@immutable
class AlarmCardWidget extends StatefulWidget {
  final void Function(Alarm) alarmChanged;
  final void Function(Alarm) alarmRemoved;
  final void Function(Alarm, List<bool>, int) removedDayList;

  final Alarm alarm;
  final bool enableInteraction;

  const AlarmCardWidget({
    Key? key,
    required this.alarm,
    required this.enableInteraction,
    required this.alarmChanged,
    required this.alarmRemoved,
    required this.removedDayList,
  }) : super(key: key);

  @override
  AlarmCardWidgetState createState() => AlarmCardWidgetState();
}

class AlarmCardWidgetState extends State<AlarmCardWidget> {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              ScrollOnExpand(
                scrollOnExpand: false,
                scrollOnCollapse: false,
                child: ExpandablePanel(
                  theme: ExpandableThemeData(
                    tapBodyToCollapse: false,
                    expandIcon: const Icon(Icons.edit).icon,
                    iconColor: Theme.of(context).indicatorColor,
                  ),
                  header: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          InkWell(
                            child: Text(
                              widget.alarm.hourToString(),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 35,
                                color: widget.alarm.activated == false
                                    ? Theme.of(context).highlightColor
                                    : Theme.of(context).selectedRowColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              TimeOfDay? timeTemp = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                initialEntryMode: TimePickerEntryMode.input,
                              );

                              if (timeTemp != null) {
                                widget.alarm.hour = timeTemp.hour;
                                widget.alarm.minute = timeTemp.minute;
                                widget.alarmChanged(widget.alarm);
                              }
                            },
                          ),
                          Switch(
                            value: widget.alarm.activated,
                            onChanged: (value) {
                              setState(() {
                                widget.alarm.activated = value;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  collapsed: CycleDayListWidget(
                    activated: widget.alarm.activated,
                    enableInteraction: false,
                    collapsed: true,
                    listChanged: (cycleList) {
                      widget.alarm.cycleList = cycleList;
                      widget.alarmChanged(widget.alarm);
                    },
                    cycleDayList: <List<bool>>[widget.alarm.getActualCycleList()],
                    removedDayList: (List<bool> dayList, int index) {
                      widget.removedDayList.call(
                        widget.alarm,
                        dayList,
                        index,
                      );
                    },
                  ),
                  expanded: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CycleDayListWidget(
                        activated: widget.alarm.activated,
                        enableInteraction: true,
                        collapsed: false,
                        listChanged: (cycleList) {
                          widget.alarm.cycleList = cycleList;
                          widget.alarmChanged(widget.alarm);
                        },
                        cycleDayList: widget.alarm.getCycleList(),
                        removedDayList: (List<bool> dayList, int index) {
                          widget.removedDayList.call(
                            widget.alarm,
                            dayList,
                            index,
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      buildAction(context),
                    ],
                  ),
                  builder: (_, collapsed, expanded) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: const ExpandableThemeData(crossFadePoint: 0),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAction(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                widget.alarm.addCycle(Alarm.defaultCycle());
                widget.alarmChanged(widget.alarm);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Ajouter un cycle',
                  style: TextStyle(
                    color: Theme.of(context).indicatorColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                widget.alarmRemoved(widget.alarm);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Supprimer',
                  style: TextStyle(
                    color: Theme.of(context).indicatorColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
