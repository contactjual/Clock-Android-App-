import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/world_clock.dart';

/// Renders one clock. Only the time text inside the
/// ValueListenableBuilder rebuilds on each tick — the label, colors,
/// and surrounding layout are built once. This is what keeps the
/// per-second update cheap (battery-friendly on OLED/AMOLED screens
/// combined with the pure-black background using zero-emission pixels).
class ClockTile extends StatelessWidget {
  final WorldClock clock;
  final ValueListenable<DateTime> ticker;

  const ClockTile({super.key, required this.clock, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            clock.name.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: clock.labelColor,
            ),
          ),
          const SizedBox(height: 4),
          ValueListenableBuilder<DateTime>(
            valueListenable: ticker,
            builder: (context, now, _) {
              tz.TZDateTime local;
              try {
                final location = tz.getLocation(clock.timezoneId);
                local = tz.TZDateTime.from(now, location);
              } catch (_) {
                local = tz.TZDateTime.from(now, tz.UTC);
              }
              final hh = local.hour.toString().padLeft(2, '0');
              final mm = local.minute.toString().padLeft(2, '0');
              final ss = local.second.toString().padLeft(2, '0');

              return RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$hh:$mm',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                        color: clock.timeColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (clock.showSeconds)
                      TextSpan(
                        text: ' $ss',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFF8E8E93), // gray seconds
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
