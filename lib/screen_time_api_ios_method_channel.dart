import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'screen_time_api_ios_platform_interface.dart';

/// An implementation of [ScreenTimeApiIosPlatform] that uses method channels.
class MethodChannelScreenTimeApiIos extends ScreenTimeApiIosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('screen_time_api_ios');
  final eventChannel = const EventChannel('screen_time_api_ios/events');

  Future authorize() async {
    await methodChannel.invokeMethod('authorize');
  }

  Future openStatistics() async {
    await methodChannel.invokeMethod('openStatistics');
  }

  Future stopMonitoring() async {
    await methodChannel.invokeMethod('stopMonitoring');
  }

  Future startMonitoring() async {
    await methodChannel.invokeMethod('startMonitoring');
  }

  Future fetchActivityEvent() async {
    await methodChannel.invokeMethod('fetchActivityEvent');
  }
}
