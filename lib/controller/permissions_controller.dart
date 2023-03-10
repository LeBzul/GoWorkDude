import 'package:app_settings/app_settings.dart';
import 'package:goworkdude/main.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsController {
  List<PermissionInfo> permissions = [
    PermissionInfo(
      language['permission_notification_title'],
      language['permission_notification_description'],
      null,
      Permission.notification,
      null,
      AppSettings.openNotificationSettings,
    ),
    PermissionInfo(
      language['permission_notification_policy_title'],
      language['permission_notification_policy_description'],
      language['permission_notification_policy_info'],
      Permission.accessNotificationPolicy,
      null,
      OpenSettings.openNotificationPolicyAccessSetting,
    ),
    PermissionInfo(
      language['permission_battery_optimizations_title'],
      language['permission_battery_optimizations_description'],
      language['permission_battery_optimizations_info'],
      Permission.ignoreBatteryOptimizations,
      null,
      AppSettings.openBatteryOptimizationSettings,
    ),
  ];

  Future<void> refreshStatus(Function() callBack) async {
    int i = 0;
    for (var element in permissions) {
      permissions[i].status = null;
    }
    callBack();

    i = 0;
    for (var element in permissions) {
      PermissionStatus permissionStatus = await element.permission.status;
      permissions[i].status = permissionStatus;
      i++;
    }
    callBack();
  }

  bool asAllGranted() {
    for (var element in permissions) {
      if (element.status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }
}

class PermissionInfo {
  Permission permission;
  PermissionStatus? status;
  Function openSetting;
  String title;
  String description;
  String? info;
  PermissionInfo(
    this.title,
    this.description,
    this.info,
    this.permission,
    this.status,
    this.openSetting,
  );
}
