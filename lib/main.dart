import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'models/world_clock.dart';
import 'services/clock_storage.dart';
import 'widgets/add_clock_sheet.dart';
import 'widgets/calendar_view.dart';
import 'widgets/clock_tile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();

  // App is designed for landscape use (matches the original layout's
  // side-by-side clocks + calendar).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // Edge-to-edge true-black immersive UI — good for AMOLED power saving.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const WorldClockApp());
}

class WorldClockApp extends StatelessWidget {
  const WorldClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(surface: Colors.black),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Shared ticker: updated once per second. Individual ClockTile widgets
  // listen to this directly, so only their text repaints each second —
  // the FAB, calendar, and scaffold never rebuild from the timer.
  final ValueNotifier<DateTime> _ticker = ValueNotifier(DateTime.now());
  Timer? _timer;

  List<WorldClock> _clocks = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadClocks();
    _startTimer();
  }

  void _startTimer() {
    // Align the first tick to the next whole second, then tick every
    // second exactly — avoids drift and avoids extra wakeups.
    final now = DateTime.now();
    final msToNextSecond = 1000 - now.millisecond;
    Future.delayed(Duration(milliseconds: msToNextSecond), () {
      if (!mounted) return;
      _ticker.value = DateTime.now();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _ticker.value = DateTime.now();
      });
    });
  }

  Future<void> _loadClocks() async {
    final stored = await ClockStorage.loadClocks();
    final clocks = stored ?? WorldClock.defaults();
    if (!mounted) return;
    setState(() {
      _clocks = clocks;
      _loaded = true;
    });
    if (stored == null) {
      await ClockStorage.saveClocks(_clocks);
    }
  }

  Future<void> _addClock(WorldClock clock) async {
    setState(() => _clocks.add(clock));
    await ClockStorage.saveClocks(_clocks);
  }

  Future<void> _removeClock(String id) async {
    setState(() => _clocks.removeWhere((c) => c.id == id));
    await ClockStorage.saveClocks(_clocks);
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddClockSheet(onAdd: _addClock),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white24)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        onPressed: _openAddSheet,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth >= constraints.maxHeight;

            final clocksList = ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: _clocks.length,
              itemBuilder: (context, index) {
                final clock = _clocks[index];
                return Dismissible(
                  key: ValueKey(clock.id),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Color(0xFFFF453A)),
                  ),
                  onDismissed: (_) => _removeClock(clock.id),
                  child: ClockTile(clock: clock, ticker: _ticker),
                );
              },
            );

            const calendar = CalendarView();

            if (isLandscape) {
              return Row(
                children: [
                  Expanded(flex: 5, child: clocksList),
                  Container(width: 1, color: const Color(0xFF2C2C2E)),
                  Expanded(
                    flex: 4,
                    child: Padding(padding: const EdgeInsets.all(12), child: calendar),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  Expanded(flex: 5, child: clocksList),
                  Container(height: 1, color: const Color(0xFF2C2C2E)),
                  Expanded(
                    flex: 5,
                    child: Padding(padding: const EdgeInsets.all(12), child: calendar),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
