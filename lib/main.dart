import 'package:flutter/material.dart';
import 'package:goworkdude/screen/alarm_screen.dart';
import 'package:goworkdude/screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AlarmManagerApp.prefs = await SharedPreferences.getInstance();

  runApp(const AlarmManagerApp());
}

class AlarmManagerApp extends StatelessWidget {
  static late SharedPreferences prefs;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const AlarmManagerApp({Key? key}) : super(key: key);

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
              surfaceTintColor: Colors.blue,
            ),
      ),
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(title: 'GoWork'),
        '/alarm': (context) => const AlarmScreen(),
      },
    );
  }
}
