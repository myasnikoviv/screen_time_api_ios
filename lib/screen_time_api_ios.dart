import 'dart:async';
import 'dart:convert';

import 'screen_time_api_ios_method_channel.dart';
import 'screen_time_api_ios_platform_interface.dart';

class ScreenTimeApiIos {
  Future authorize() async {
    final instance = ScreenTimeApiIosPlatform.instance as MethodChannelScreenTimeApiIos;
    await instance.authorize();
  }

  Future<bool> isAuthorized() async {
    final instance = ScreenTimeApiIosPlatform.instance as MethodChannelScreenTimeApiIos;
    return await instance.isAuthorized();
  }

  Future openStatistics() async {
    final instance = ScreenTimeApiIosPlatform.instance as MethodChannelScreenTimeApiIos;
    await instance.openStatistics();
  }

  Future stopMonitoring() async {
    final instance = ScreenTimeApiIosPlatform.instance as MethodChannelScreenTimeApiIos;
    await instance.stopMonitoring();
  }

  Future startMonitoring() async {
    final instance = ScreenTimeApiIosPlatform.instance as MethodChannelScreenTimeApiIos;
    await instance.startMonitoring();
  }

  Future<Map<String, dynamic>> fetchActivityEvent() async {
    final instance = ScreenTimeApiIosPlatform.instance as MethodChannelScreenTimeApiIos;
    return jsonDecode(await instance.fetchActivityEvent());
  }
}
