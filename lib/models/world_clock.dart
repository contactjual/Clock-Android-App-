import 'package:flutter/material.dart';

/// A single clock entry: a name, an IANA timezone id, and the colors
/// used to render it (so custom clocks can be styled just like the
/// original Bangladesh/USA clocks).
class WorldClock {
  final String id;
  String name;
  String timezoneId;
  int labelColorValue;
  int timeColorValue;
  bool showSeconds;

  WorldClock({
    required this.id,
    required this.name,
    required this.timezoneId,
    required this.labelColorValue,
    required this.timeColorValue,
    this.showSeconds = true,
  });

  Color get labelColor => Color(labelColorValue);
  Color get timeColor => Color(timeColorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'timezoneId': timezoneId,
        'labelColorValue': labelColorValue,
        'timeColorValue': timeColorValue,
        'showSeconds': showSeconds,
      };

  factory WorldClock.fromJson(Map<String, dynamic> json) => WorldClock(
        id: json['id'] as String,
        name: json['name'] as String,
        timezoneId: json['timezoneId'] as String,
        labelColorValue: json['labelColorValue'] as int,
        timeColorValue: json['timeColorValue'] as int,
        showSeconds: json['showSeconds'] as bool? ?? true,
      );

  /// The two clocks from the original HTML design, with identical colors:
  /// yellow BD label, red USA label, green USA time, gray seconds.
  static List<WorldClock> defaults() => [
        WorldClock(
          id: 'default-bd',
          name: 'Bangladesh (BST)',
          timezoneId: 'Asia/Dhaka',
          labelColorValue: 0xFFFFD60A, // yellow
          timeColorValue: 0xFFFFFFFF, // white
          showSeconds: true,
        ),
        WorldClock(
          id: 'default-usa',
          name: 'USA (New York)',
          timezoneId: 'America/New_York',
          labelColorValue: 0xFFFF453A, // red
          timeColorValue: 0xFF30D158, // green
          showSeconds: false,
        ),
      ];
}
