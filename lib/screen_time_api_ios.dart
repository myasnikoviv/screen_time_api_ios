import 'dart:async';
import 'dart:convert';

import 'screen_time_api_ios_method_channel.dart';
import 'screen_time_api_ios_platform_interface.dart';

class ScreenTimeApiIos {
  late final Stream<Map<String, dynamic>>? eventsStream;

  ScreenTimeApiIos() {
    listen();
  }

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

  Future fetchActivityEvent() async {
    final instance = ScreenTimeApiIosPlatform.instance as MethodChannelScreenTimeApiIos;
    await instance.fetchActivityEvent();
  }

  void listen() {
    final instance = ScreenTimeApiIosPlatform.instance as MethodChannelScreenTimeApiIos;

    eventsStream = instance.eventChannel.receiveBroadcastStream().transform<Map<String, dynamic>>(
          StreamTransformer.fromHandlers(
            handleData: (event, sink) {
              if (event is String) {
                try {
                  final Map<String, dynamic> parsedEvent = jsonDecode(event);
                  sink.add(parsedEvent);
                } catch (e) {
                  sink.addError("Error parsing JSON: $e");
                }
              } else {
                sink.addError("Unexpected event type: ${event.runtimeType}");
              }
            },
            handleError: (error, stackTrace, sink) {
              print("Error in stream: $error");
              sink.addError(error);
            },
            handleDone: (sink) {
              sink.close();
            },
          ),
        );
  }
}
