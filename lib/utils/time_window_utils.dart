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
    //     TimeWindow(
    //   start: today.add(const Duration(hours: 7, minutes: 45)),
    //   end: today.add(const Duration(hours: 9, minutes: 15)),
    //   label: '9:30 – 9:45 AM',
    // ),
    TimeWindow(
      start: today.add(const Duration(hours: 9, minutes: 30)),
      end: today.add(const Duration(hours: 9, minutes: 45)),
      label: '9:30 – 9:45 AM',
    ),
    TimeWindow(
      start: today.add(const Duration(hours: 12, minutes: 45)),
      end: today.add(const Duration(hours: 13)),
      label: '12:45 – 1:00 PM',
    ),
    TimeWindow(
      start: today.add(const Duration(hours: 14, minutes: 15)),
      end: today.add(const Duration(hours: 14, minutes: 30)),
      label: '2:15 – 2:30 PM',
    ),
    // TimeWindow(
    //   start: today.add(const Duration(hours: 17, minutes: 45)),
    //   end: today.add(const Duration(hours: 18)),
    //   label: '5:45 – 6:00 PM',
    // ),
    // TimeWindow(
    //   start: today.add(const Duration(hours: 16, minutes: 40)),
    //   end: today.add(const Duration(hours: 18)),
    //   label: '5:45 – 6:00 PM',
    // ),
        TimeWindow(
      start: today.add(const Duration(hours: 16, minutes: 40)),
      end: today.add(const Duration(hours: 19, minutes: 45)),
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
