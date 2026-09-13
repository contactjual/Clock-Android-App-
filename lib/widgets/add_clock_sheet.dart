import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/world_clock.dart';

/// Bottom sheet used to add a new, custom-named world clock.
/// The timezone list is pulled straight from the tz database, so
/// every IANA zone is searchable (not just a curated shortlist).
class AddClockSheet extends StatefulWidget {
  final void Function(WorldClock) onAdd;
  const AddClockSheet({super.key, required this.onAdd});

  @override
  State<AddClockSheet> createState() => _AddClockSheetState();
}

class _AddClockSheetState extends State<AddClockSheet> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  String? _selectedTimezone;
  Color _selectedColor = const Color(0xFFFFFFFF);
  bool _showSeconds = true;
  late final List<String> _allTimezones;
  List<String> _filtered = [];

  static const _presetColors = [
    Color(0xFFFFFFFF),
    Color(0xFFFFD60A),
    Color(0xFFFF453A),
    Color(0xFF30D158),
    Color(0xFF0A84FF),
    Color(0xFFBF5AF2),
    Color(0xFFFF9F0A),
  ];

  @override
  void initState() {
    super.initState();
    _allTimezones = tz.timeZoneDatabase.locations.keys.toList()..sort();
    _filtered = _allTimezones;
  }

  void _filter(String query) {
    setState(() {
      _filtered = _allTimezones
          .where((z) => z.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty || _selectedTimezone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a name and pick a timezone')),
      );
      return;
    }
    final clock = WorldClock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      timezoneId: _selectedTimezone!,
      labelColorValue: 0xFF8E8E93,
      timeColorValue: _selectedColor.value,
      showSeconds: _showSeconds,
    );
    widget.onAdd(clock);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SizedBox(
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Clock',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Custom name (e.g. Tokyo Office)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Search timezone (e.g. Asia/Tokyo)'),
              onChanged: _filter,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final tzName = _filtered[index];
                  final selected = tzName == _selectedTimezone;
                  return ListTile(
                    dense: true,
                    title: Text(
                      tzName,
                      style: TextStyle(
                        color: selected ? const Color(0xFF30D158) : Colors.white70,
                      ),
                    ),
                    onTap: () => setState(() => _selectedTimezone = tzName),
                    trailing: selected
                        ? const Icon(Icons.check, color: Color(0xFF30D158))
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Color', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                ..._presetColors.map(
                  (c) => GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == c ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Text('Sec', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Switch(
                  value: _showSeconds,
                  activeColor: const Color(0xFF30D158),
                  onChanged: (v) => setState(() => _showSeconds = v),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30D158),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: const Text('Add Clock', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}
