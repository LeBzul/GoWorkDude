import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controller/permissions_controller.dart';
import '../main.dart';
import '../model/alarm.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({Key? key}) : super(key: key);

  @override
  PermissionsScreenState createState() => PermissionsScreenState();
}

class PermissionsScreenState extends State<PermissionsScreen> with WidgetsBindingObserver {
  late Alarm alarm;
  late PermissionsController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = PermissionsController();
    controller.refreshStatus(
      () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff121212),
        title: Text(language['permission_title']),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 24,
            bottom: 12,
          ),
          child: ListView.builder(
            itemCount: controller.permissions.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return buildIntro();
              } else {
                return buildPermissions(index - 1);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildIntro() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language['permission_description'],
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(
            height: 32,
          ),
        ],
      ),
    );
  }

  Widget buildPermissions(int index) {
    final item = controller.permissions[index];

    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    SizedBox(
                      height: item.info != null ? 8 : 0,
                    ),
                    item.info != null
                        ? Text(
                            item.info ?? "",
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).hintColor,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              item.status != null
                  ? ElevatedButton(
                      onPressed: () {
                        item.openSetting.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.status == PermissionStatus.granted
                            ? Theme.of(context).toggleableActiveColor
                            : Colors.pink,
                      ),
                      child: Text(
                        language['permission_open'],
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    )
                  : const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        controller.refreshStatus(
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
