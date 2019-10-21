import 'dart:async';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'xkcd clock',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'xkcd script'),
        home: Clock(),
      );
}

class Clock extends StatefulWidget {
  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  final _utcMidnightRadiansOffset = radiansFromDegrees(-64);
  static const _secondsInDay = 86400;
  DateTime _localTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (_) => setState(() => _localTime = DateTime.now()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text('xkcd clock')),
        body: Column(
          children: [
            Stack(
              children: [
                Image.asset('assets/face.png'),
                Transform.rotate(
                  angle: -(radiansFromTime(_localTime.toUtc()) + _utcMidnightRadiansOffset),
                  child: ClipOval(
                    clipper: InnerFaceClipper(),
                    child: Image.asset('assets/face.png'),
                  ),
                ),
              ],
            ),
            Text(DateFormat.EEEE().format(_localTime), style: TextStyle(fontSize: 48)),
            Text(DateFormat.yMMMMd().format(_localTime), style: TextStyle(fontSize: 20)),
            Text(DateFormat.jm().format(_localTime), style: TextStyle(fontSize: 42)),
          ],
        ),
      );

  static double radiansFromDegrees(double degrees) => degrees * math.pi / 180;
  static double radiansFromTime(DateTime time) {
    final midnightToday = DateTime(time.year, time.month, time.day);
    final secondsSinceMidnight = midnightToday.difference(time).inSeconds;
    final percent = secondsSinceMidnight / _secondsInDay;
    final degrees = percent * 360;
    return radiansFromDegrees(degrees);
  }
}

class InnerFaceClipper extends CustomClipper<Rect> {
  final percent = 0.85;

  @override
  Rect getClip(Size size) => Rect.fromCenter(
        center: size.center(Offset(0, 0)),
        width: size.width * percent,
        height: size.height * percent,
      );

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}
