import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> initService() async {
  final service = FlutterBackgroundService();
  service.configure(
    iosConfiguration: IosConfiguration(
        autoStart: true, onForeground: onStart, onBackground: onBackground),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance serviceInstance) async {
  DartPluginRegistrant.ensureInitialized();
  if (serviceInstance is AndroidServiceInstance) {
    serviceInstance.on('setAsForeGround').listen((event) {
      serviceInstance.setAsForegroundService();
    });
    serviceInstance.on('setAsBackGround').listen((event) {
      serviceInstance.setAsBackgroundService();
    });
  }

  serviceInstance.on('stopServiceValue').listen((event) {
    serviceInstance.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (serviceInstance is AndroidServiceInstance) {
      if (await serviceInstance.isForegroundService()) {
        serviceInstance.setForegroundNotificationInfo(
          title: 'Y4CN',
          content: 'forGround Service',
        );
      }
    }
    print('backGroundService');
    serviceInstance.invoke('update');
  });
}

@pragma('vm:entry-point')
Future<bool> onBackground(ServiceInstance serviceInstance) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
