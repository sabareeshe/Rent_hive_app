import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class OwnerCalendarScreen extends StatefulWidget {
  const OwnerCalendarScreen({super.key});

  @override
  State<OwnerCalendarScreen> createState() => _OwnerCalendarScreenState();
}

class _OwnerCalendarScreenState extends State<OwnerCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock booked dates
  final List<DateTime> _bookedDates = [
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 3)),
    DateTime.now().add(const Duration(days: 7)),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (_bookedDates.any((d) => _isSameDay(d, date))) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 6.0,
                      height: 6.0,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Schedule for selected day:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                if (_bookedDates.any((d) => _selectedDay != null && _isSameDay(d, _selectedDay!)))
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.shade200)),
                    color: Colors.red.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.event_busy, color: Colors.red),
                      title: const Text('Booked: Sony A7III Camera', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      subtitle: const Text('Rented to Alice Smith'),
                      trailing: TextButton(onPressed: () {}, child: const Text('Details')),
                    ),
                  )
                else
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No bookings for this date. Items are available.', style: TextStyle(color: Colors.grey)),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
