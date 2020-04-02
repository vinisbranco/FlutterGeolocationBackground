import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

//use an async method so we can await
void maybeStartFGS() async {
  if (!(await ForegroundService.foregroundServiceIsStarted())) {
    await ForegroundService.setServiceIntervalSeconds(5);

    // //necessity of editMode is dubious (see function comments)
    // await ForegroundService.notification.startEditMode();

    // await ForegroundService.notification
    //     .setTitle("Example Title: ${DateTime.now()}");
    // await ForegroundService.notification
    //     .setText("Example Text: ${DateTime.now()}");

    // await ForegroundService.notification.finishEditMode();

    await ForegroundService.startForegroundService(foregroundServiceFunction);
    await ForegroundService.getWakeLock();
  }
}

Future<void> foregroundServiceFunction() async {
  Geolocator()
    ..getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    ).then((position) {
      print("Current position: ${position.latitude}, ${position.longitude}");
    }).catchError((e) {
      debugPrint("ERRO! ${e.toString()}");
    });
  //ForegroundService.notification.setText("The time was: ${DateTime.now()}");
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key key,

    /// If set, enable the FusedLocationProvider on Android
    @required this.androidFusedLocation,
  }) : super(key: key);

  final bool androidFusedLocation;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _appMessage = "";

  @override
  void initState() {
    super.initState();
  }

  void _toggleForegroundServiceOnOff() async {
    final fgsIsRunning = await ForegroundService.foregroundServiceIsStarted();
    String appMessage;

    Geolocator()
      ..getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).then((position) {
        print("Current position: ${position.latitude}, ${position.longitude}");
      }).catchError((e) {
        debugPrint("ERRO! ${e.toString()}");
      });

    if (fgsIsRunning) {
      await ForegroundService.stopForegroundService();
      appMessage = "Stopped foreground service.";
    } else {
      maybeStartFGS();
      appMessage = "Started foreground service.";
    }

    setState(() {
      _appMessage = appMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            Text('Foreground Service Example',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(padding: EdgeInsets.all(8.0)),
            Text(_appMessage, style: TextStyle(fontStyle: FontStyle.italic))
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )),
        floatingActionButton: Column(
          children: <Widget>[
            FloatingActionButton(
              child: Text("F"),
              onPressed: _toggleForegroundServiceOnOff,
              tooltip: "Toggle Foreground Service On/Off",
            )
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ),
    );
  }
}
