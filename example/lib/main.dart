import 'package:flutter/material.dart';
import 'package:screen_time_api_ios/screen_time_api_ios.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _screenTimeApiIosPlugin = ScreenTimeApiIos();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  _screenTimeApiIosPlugin.authorize();
                },
                child: const Text("authorize"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _screenTimeApiIosPlugin.stopMonitoring();
                },
                child: const Text("stopMonitoring"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _screenTimeApiIosPlugin.startMonitoring();
                },
                child: const Text("startMonitoringForPackages: instagram, youtube"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _screenTimeApiIosPlugin.fetchActivityEvent();
                },
                child: const Text("fetchActivityEvent"),
              ),
              const SizedBox(height: 20),
              const Text('Events:'),
              const SizedBox(height: 10),
              StreamBuilder(
                  stream: _screenTimeApiIosPlugin.eventsStream,
                  builder: (context, snapshot) {
                    return Text(snapshot.hasData && snapshot.data != null ? snapshot.data!.toString() : '');
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
