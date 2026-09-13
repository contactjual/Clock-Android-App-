import 'package:flutter/material.dart';

/// A swipeable, infinite month calendar. Each page is a month; swiping
/// left/right moves a month at a time, matching the "slide to view
/// next/previous month" requirement. Only the visible page rebuilds
/// on swipe — the grid for a month is otherwise static, so this is
/// cheap to render.
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  // Large starting index so the user can swipe many years in either
  // direction without hitting an edge.
  static const _initialPage = 6000;
  late final PageController _controller =
      PageController(initialPage: _initialPage);
  int _currentPage = _initialPage;
  final DateTime _anchor = DateTime.now();

  static const _monthNames = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
  ];
  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  DateTime _monthForPage(int page) {
    final offset = page - _initialPage;
    return DateTime(_anchor.year, _anchor.month + offset, 1);
  }

  void _goTo(int delta) {
    _controller.animateToPage(
      _currentPage + delta,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthDate = _monthForPage(_currentPage);
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Color(0xFF8E8E93)),
              onPressed: () => _goTo(-1),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                '${_monthNames[monthDate.month - 1]} ${monthDate.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF453A), // red, matches .cal-header
                  letterSpacing: 1,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF8E8E93)),
              onPressed: () => _goTo(1),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: _weekdayLabels
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, page) => _MonthGrid(month: _monthForPage(page)),
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  const _MonthGrid({required this.month});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // DateTime.weekday: Mon=1..Sun=7. Convert so Sunday=0 to match "S M T W T F S".
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final totalDays = DateTime(month.year, month.month + 1, 0).day;
    final isCurrentMonth = now.year == month.year && now.month == month.month;

    final cells = <Widget>[];
    for (int i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (int day = 1; day <= totalDays; day++) {
      final isToday = isCurrentMonth && day == now.day;
      cells.add(Center(
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: isToday
              ? const BoxDecoration(
                  color: Color(0xFFFF453A), // red today circle
                  shape: BoxShape.circle,
                )
              : null,
          child: Text(
            '$day',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }
}
