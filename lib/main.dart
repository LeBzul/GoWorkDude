import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:goworkdude/controller/notification_controller.dart';
import 'package:goworkdude/screen/alarm_screen.dart';
import 'package:goworkdude/screen/home_screen.dart';
import 'package:goworkdude/screen/permissions_screen.dart';
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
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', ''),
        Locale('en', ''),
      ],
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
        '/permissions': (context) => const PermissionsScreen(),
        '/alarm': (context) => const AlarmScreen(),
      },
    );
  }
}

// this class is used for localizations
class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String getText(String key) => language[key];
}

late Map<String, dynamic> language;

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr_FR', 'fr', 'en_US', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    String string =
        await rootBundle.loadString("assets/strings/${locale.languageCode.split('_').first.toLowerCase()}.json");
    language = json.decode(string);
    return SynchronousFuture<AppLocalizations>(AppLocalizations());
  }

  static Future<Map<String, dynamic>> getText(String locale) async {
    String string = await rootBundle.loadString("assets/strings/${locale.split('_').first.toLowerCase()}.json");
    return json.decode(string);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
