// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'dart:math';

import 'painter.dart' as painter;

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _hour = new DateFormat.j().format(DateTime.now()).substring(0, new DateFormat.j().format(DateTime.now()).indexOf(" "));
  var _clockPeriod = new DateFormat.j().format(DateTime.now()).substring(new DateFormat.j().format(DateTime.now()).indexOf(" "), new DateFormat.j().format(DateTime.now()).length);
  var _day = DateFormat('E').format(DateTime.now());
  Timer _timer;

  @override
  void initState() {
    super.initState();
    // Set the initial values.
    _updateTime();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      _hour = new DateFormat.j().format(DateTime.now()).substring(0, new DateFormat.j().format(DateTime.now()).indexOf(" "));
      _clockPeriod = new DateFormat.j().format(DateTime.now()).substring(new DateFormat.j().format(DateTime.now()).indexOf(" "), new DateFormat.j().format(DateTime.now()).length);
      _day = DateFormat('E').format(DateTime.now());
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double tmpHeight = 0;
    double tmpWidth = 0;
    if (MediaQuery.of(context).size.height > MediaQuery.of(context).size.width) {
      tmpHeight = 0;
      tmpWidth = MediaQuery.of(context).size.width;
    } else {
      tmpHeight = MediaQuery.of(context).size.height;
      tmpWidth = 0;
    }

    double radiansMinute = _now.minute * radiansPerTick;
    //double radiansHour = int.parse(_hour) * radiansPerHour + (_now.minute / 60) * radiansPerHour;
    double radiansHour = int.parse(_hour) * radiansPerHour;

    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].

    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF4285F4),
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Color(0xFF669DF6),
            backgroundColor: Color(0xFFD2E3FC),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF3C4043),
          );

    final time = DateFormat.Hms().format(DateTime.now());

    final dayOfWeek = buildTextStyle(customTheme, _day);

    final amPm = buildTextStyle(customTheme, _clockPeriod);

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: Stack(
          children: [
            //Seconds
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: CustomPaint(
                  foregroundPainter: painter.Painter(completeColor: Color(0xFFea5656), radians: _now.second * radiansPerTick, width: 10.0),
                ),
              ),
            ),

            // Solid color
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height - (tmpHeight * 0.1),
                width: MediaQuery.of(context).size.width - (tmpWidth * 0.43),
                child: CustomPaint(
                  foregroundPainter: painter.Painter(completeColor: customTheme.backgroundColor, radians: 60 * radiansPerTick, width: 8.0),
                ),
              ),
            ),

            //Minute
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height - (tmpHeight * 0.1),
                width: MediaQuery.of(context).size.width - (tmpWidth * 0.43),
                child: CustomPaint(
                  foregroundPainter: painter.Painter(completeColor: Color(0xFF8bdefc), radians: radiansMinute, width: 8.0),
                ),
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: customTheme.backgroundColor,
                  boxShadow: [
                    new BoxShadow(
                      offset: new Offset(0.0, 3.0),
                      blurRadius: 5.0,
                    )
                  ],
                ),
              ),
            ),

            //Hour
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height - (tmpHeight * 0.5),
                width: MediaQuery.of(context).size.width - (tmpWidth * 0.7),
                child: CustomPaint(
                  foregroundPainter: painter.Painter(completeColor: Color(0xFFa788ff), radians: radiansHour, width: 8.0),
                ),
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: customTheme.backgroundColor,
                  boxShadow: [
                    new BoxShadow(
                      offset: new Offset(0.0, 8.0),
                      blurRadius: 5.0,
                    )
                  ],
                ),
              ),
            ),

            //AmPm
            Positioned(
              right: min(MediaQuery.of(context).size.height / 8, MediaQuery.of(context).size.width / 64),
              bottom: min(MediaQuery.of(context).size.height / 2, MediaQuery.of(context).size.width / 4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: RotatedBox(quarterTurns: 1, child: amPm),
              ),
            ),

            //Day
            Positioned(
              left: min(MediaQuery.of(context).size.height / 8, MediaQuery.of(context).size.width / 64),
              bottom: min(MediaQuery.of(context).size.height / 2, MediaQuery.of(context).size.width / 4),
              child: Padding(padding: const EdgeInsets.all(8), child: RotatedBox(quarterTurns: 3, child: dayOfWeek)),
            ),
          ],
        ),
      ),
    );
  }

  DefaultTextStyle buildTextStyle(ThemeData customTheme, String txt) {
    return DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            txt,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 5.0,
              shadows: [
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.blueGrey,
                  offset: Offset(4.0, 4.0),
                ),
//
              ],
            ),
          ),
        ],
      ),
    );
  }
}
