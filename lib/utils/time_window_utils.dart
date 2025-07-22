import 'package:attendance_app/models/time_window.dart';

List<TimeWindow> getTimeWindowsForToday() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return [
    TimeWindow(
      start: today.add(const Duration(hours: 6)),
      end: today.add(const Duration(hours: 6, minutes: 15)),
      label: '6:00 – 6:15 AM',
    ),
    TimeWindow(
      start: today.add(const Duration(hours: 8, minutes: 30)),
      end: today.add(const Duration(hours: 8, minutes: 45)),
      label: '8:30 – 8:45 AM',
    ),
    TimeWindow(
      start: today.add(const Duration(hours: 11)),
      end: today.add(const Duration(hours: 11, minutes: 15)),
      label: '11:00 – 11:15 AM',
    ),
    TimeWindow(
      start: today.add(const Duration(hours: 14)),
      end: today.add(const Duration(hours: 14, minutes: 15)),
      label: '2:15 – 2:15 PM',
    ),
    TimeWindow(
      start: today.add(const Duration(hours: 17, minutes: 45)),
      end: today.add(const Duration(hours: 18)),
      label: '5:45 – 6:00 PM',
    ),
  ];
}

TimeWindow? getCurrentAllowedWindow(List<TimeWindow> windows) {
  final now = DateTime.now();
  for (final slot in windows) {
    if (now.isAfter(slot.start) && now.isBefore(slot.end)) {
      return slot;
    }
  }
  return null;
}
