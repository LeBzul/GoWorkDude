import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:goworkdude/controller/permissions_controller.dart';
import 'package:goworkdude/main.dart';
import 'package:goworkdude/screen/permissions_screen.dart';

import '../controller/home_controller.dart';
import '../model/alarm.dart';
import '../widget/alarm_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late HomeController controller;
  late PermissionsController permissionsController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    AndroidAlarmManager.initialize();
    controller = HomeController();
    permissionsController = PermissionsController();
    permissionsController.refreshStatus(() => setState(
          () {},
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (permissionsController.asAllGranted()) {
              createNewAlarm();
            } else {
              AlarmManagerApp.navigatorKey.currentState?.push(
                MaterialPageRoute(
                  settings: const RouteSettings(name: '/permissions'),
                  builder: (context) => const PermissionsScreen(),
                ),
              );
            }
          },
          backgroundColor: permissionsController.asAllGranted() ? Theme.of(context).toggleableActiveColor : Colors.pink,
          child: const Icon(Icons.add)),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  controller.list.isNotEmpty ? language['alarm'] : language['no_alarm'],
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (controller.list.isNotEmpty)
                Expanded(
                  child: ExpandableTheme(
                    data: const ExpandableThemeData(
                      iconColor: Colors.blue,
                      useInkWell: true,
                    ),
                    child: buildListView(),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListView buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: controller.list.length,
      itemBuilder: (BuildContext context, int index) {
        return AlarmCardWidget(
          alarm: controller.list[index],
          enableInteraction: true,
          alarmChanged: (alarm) {
            setState(() {
              controller.putOrAddAlarm(alarm);
            });
          },
          alarmRemoved: (alarm) {
            setState(() {
              controller.removeAlarm(alarm);
            });
          },
          removedDayList: (Alarm alarm, AlarmCycle dayList, int index) {
            setState(() {
              controller.removeDayList(
                alarm,
                dayList,
                index,
              );
            });
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  void createNewAlarm() async {
    TimeOfDay? timeTemp = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(
          const Duration(minutes: 1),
        ),
      ),
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (timeTemp != null) {
      setState(
        () {
          controller.putOrAddAlarm(
            Alarm(
                hour: timeTemp.hour,
                minute: timeTemp.minute,
                activated: true,
                cycleList: <List<bool>>[Alarm.defaultCycle()],
                referenceDate: DateTime.now()),
          );
        },
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        permissionsController.refreshStatus(
          () {
            setState(() {});
          },
        );
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
