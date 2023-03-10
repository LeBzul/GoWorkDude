import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:goworkdude/controller/notification_controller.dart';
import 'package:goworkdude/screen/alarm_screen.dart';
import 'package:goworkdude/screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AlarmManagerApp.prefs = await SharedPreferences.getInstance();
  NotificationAppLaunchDetails? appLaunchDetails = await NotificationController.instance.appLaunchWithNotification();
  runApp(AlarmManagerApp(
      notificationResponse:
          (appLaunchDetails?.didNotificationLaunchApp ?? false) ? appLaunchDetails?.notificationResponse : null));
}

class AlarmManagerApp extends StatelessWidget {
  static late SharedPreferences prefs;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  NotificationResponse? notificationResponse;

  AlarmManagerApp({Key? key, this.notificationResponse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Work Dude',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xff616161),
        primaryColorLight: const Color(0xff757575),
        primaryColorDark: const Color(0xff212121),
        scaffoldBackgroundColor: const Color(0xff121212),
        cardTheme: Theme.of(context).cardTheme.copyWith(
              color: const Color(0xff212020),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              surfaceTintColor: Colors.greenAccent,
            ),
      ),
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => notificationResponse == null
            ? const HomeScreen()
            : AlarmScreen(
                details: notificationResponse,
                playSound: true,
              ),
        '/alarm': (context) => const AlarmScreen(),
      },
    );
  }
}
