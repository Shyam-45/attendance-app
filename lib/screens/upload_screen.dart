import 'dart:async';
import 'package:flutter/material.dart';
import 'package:attendance_app/models/upload_entry.dart';
import 'package:attendance_app/utils/time_window_utils.dart';
import 'package:attendance_app/database/upload_entry_db.dart';
import 'upload_details_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with WidgetsBindingObserver {
  late Timer _timer;
  List<UploadEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeEntries();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadEntries();
      _startAutoRefresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _timer.cancel();
    }
  }

  bool _isWithinUploadHours() {
    final now = DateTime.now();
    final windows = getTimeWindowsForToday();
    return windows.any((w) => now.isBefore(w.end));
  }

  void _startAutoRefresh() {
    _timer = Timer(Duration.zero, () async {
      if (!_isWithinUploadHours()) return;

      await _loadEntries();

      final now = DateTime.now();
      final secondsUntilNextMinute = 60 - now.second;

      Future.delayed(Duration(seconds: secondsUntilNextMinute), () {
        _timer = Timer.periodic(const Duration(minutes: 1), (_) {
          if (_isWithinUploadHours()) {
            _loadEntries();
          }
        });
      });
    });
  }

  Future<void> _initializeEntries() async {
    final db = UploadEntryDB();
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);
    final existing = await db.getEntriesForDate(todayKey);

    if (existing.isEmpty) {
      final windows = getTimeWindowsForToday();
      for (final window in windows) {
        final status = now.isAfter(window.end) ? 'missed' : 'pending';
        final newEntry = UploadEntry(
          date: todayKey,
          slotLabel: window.label,
          slotStart: window.start,
          slotEnd: window.end,
          status: status,
        );
        await db.insertEntry(newEntry);
      }
    }

    await _loadEntries(); // this also double-checks missed updates
  }

  Future<void> _loadEntries() async {
    final db = UploadEntryDB();
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);
    final entries = await db.getEntriesForDate(todayKey);

    // Fix any pending → missed
    for (final e in entries) {
      if (e.status == 'pending' && now.isAfter(e.slotEnd)) {
        final updated = e.copyWith(status: 'missed');
        await db.updateEntry(updated);
      }
    }

    final updated = await db.getEntriesForDate(todayKey);

    if (!mounted) return;
    setState(() {
      _entries = updated;
    });
  }

  Widget _buildSection(
    String title,
    List<UploadEntry> entries, {
    bool isActive = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text('No entries available.'),
          )
        else
          ...entries.map(
            (entry) => ListTile(
              title: Text(entry.slotLabel),
              subtitle: _statusSubtitle(entry),
              trailing: isActive ? const Icon(Icons.arrow_forward_ios) : null,
              onTap: isActive
                  ? () async {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => UploadDetailsScreen(
                      //       entry: entry,
                      //       token: "YOUR_TOKEN_HERE", // Pass actual token here
                      //       final token = ref.read(appStateProvider).authToken;
                      //     ),
                      //   ),
                      // );
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UploadDetailsScreen(
                            entry: entry,
                            // token: ref.read(appStateProvider).authToken, // Or read from Riverpod if needed
                          ),
                        ),
                      );

                      if (result == true) {
                        await _loadEntries(); // ⬅️ Refresh your entries manually
                      }
                    }
                  : null,
            ),
          ),
      ],
    );
  }

  Widget _statusSubtitle(UploadEntry entry) {
    switch (entry.status) {
      case 'done':
        return const Text(
          'Uploaded',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        );
      case 'missed':
        return const Text(
          'Missed',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        );
      default:
        return const Text(
          'Pending',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

final active = _entries
    .where((e) =>
        now.isAfter(e.slotStart) &&
        now.isBefore(e.slotEnd) &&
        e.status == 'pending')
    .toList();

final upcoming = _entries
    .where((e) =>
        e.status == 'pending' &&
        now.isBefore(e.slotStart) &&
        now.isBefore(e.slotEnd))
    .toList();

final past = _entries
    .where((e) => e.status == 'done' || e.status == 'missed')
    .toList();

    // final now = DateTime.now();

    // final active = _entries
    //     .where(
    //       (e) =>
    //           e.status == 'pending' &&
    //           now.isAfter(e.slotStart) &&
    //           now.isBefore(e.slotEnd),
    //     )
    //     .toList();

    // final upcoming = _entries
    //     .where((e) => e.status == 'pending' && now.isBefore(e.slotStart))
    //     .toList();

    // final past = _entries
    //     .where((e) => e.status == 'done' || e.status == 'missed')
    //     .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Entries')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Active Entry', active, isActive: true),
            _buildSection('Upcoming Entries', upcoming),
            _buildSection('Past Entries', past),
          ],
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:attendance_app/models/upload_entry.dart';
// import 'package:attendance_app/utils/time_window_utils.dart';
// import 'package:attendance_app/database/upload_entry_db.dart';
// import 'upload_details_screen.dart';

// class UploadScreen extends StatefulWidget {
//   const UploadScreen({super.key});

//   @override
//   State<UploadScreen> createState() => _UploadScreenState();
// }

// class _UploadScreenState extends State<UploadScreen> with WidgetsBindingObserver {
//   late Timer _timer;
//   List<UploadEntry> _entries = [];

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeEntries();
//     _startAutoRefresh();
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _loadEntries();
//       _startAutoRefresh();
//     } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
//       _timer.cancel();
//     }
//   }

//   bool _isWithinUploadHours() {
//     final now = DateTime.now();
//     final windows = getTimeWindowsForToday();
//     return windows.any((w) => now.isBefore(w.end));
//   }

//   void _startAutoRefresh() {
//     _timer = Timer(Duration.zero, () async {
//       if (!_isWithinUploadHours()) return;

//       await _loadEntries();

//       final now = DateTime.now();
//       final secondsUntilNextMinute = 60 - now.second;

//       Future.delayed(Duration(seconds: secondsUntilNextMinute), () {
//         _timer = Timer.periodic(const Duration(minutes: 1), (_) {
//           if (_isWithinUploadHours()) {
//             _loadEntries();
//           }
//         });
//       });
//     });
//   }

//   Future<void> _initializeEntries() async {
//     final db = UploadEntryDB();
//     final now = DateTime.now();
//     final todayKey = DateTime(now.year, now.month, now.day);

//     final existing = await db.getEntriesForDate(todayKey);
//     if (existing.isEmpty) {
//       final windows = getTimeWindowsForToday();
//       for (final window in windows) {
//         final newEntry = UploadEntry(
//           id: 0,
//           date: todayKey,
//           slotLabel: window.label,
//           slotStart: window.start,
//           slotEnd: window.end,
//           status: 'pending',
//         );
//         await db.insertEntry(newEntry);
//       }
//     }

//     await _loadEntries();
//   }

//   Future<void> _loadEntries() async {
//     final db = UploadEntryDB();
//     final now = DateTime.now();
//     final todayKey = DateTime(now.year, now.month, now.day);

//     final entries = await db.getEntriesForDate(todayKey);

//     for (final e in entries) {
//       if (e.status == 'pending' && now.isAfter(e.slotEnd)) {
//         final updated = e.copyWith(status: 'missed');
//         await db.updateEntry(updated);
//       }
//     }

//     final updatedEntries = await db.getEntriesForDate(todayKey);
//     setState(() {
//       _entries = updatedEntries;
//     });
//   }

//   Widget _buildSection(String title, List<UploadEntry> entries, {bool isActive = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
//           child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         ),
//         if (entries.isEmpty)
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             child: Text('No entries available.'),
//           )
//         else
//           ...entries.map((entry) => ListTile(
//                 title: Text(entry.slotLabel),
//                 subtitle: _statusSubtitle(entry),
//                 trailing: isActive
//                     ? const Icon(Icons.arrow_forward_ios)
//                     : null,
//                 onTap: isActive
//                     ? () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => UploadDetailsScreen(timeSlotLabel: entry.slotLabel),
//                           ),
//                         );
//                       }
//                     : null,
//               )),
//       ],
//     );
//   }

//   Widget _statusSubtitle(UploadEntry entry) {
//     switch (entry.status) {
//       case 'done':
//         return const Text('Uploaded',
//             style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
//       case 'missed':
//         return const Text('Missed',
//             style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
//       case 'pending':
//       default:
//         return const Text('Pending',
//             style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();

//     final active = _entries.where((e) =>
//         e.status == 'pending' &&
//         now.isAfter(e.slotStart) &&
//         now.isBefore(e.slotEnd)).toList();

//     final upcoming = _entries.where((e) =>
//         e.status == 'pending' &&
//         now.isBefore(e.slotStart)).toList();

//     final past = _entries.where((e) =>
//         e.status == 'done' || e.status == 'missed').toList();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Upload Entries')),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSection('Active Entry', active, isActive: true),
//             _buildSection('Upcoming Entries', upcoming),
//             _buildSection('Past Entries', past),
//           ],
//         ),
//       ),
//     );
//   }
// }


// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:attendance_app/models/upload_entry.dart';
// // import 'package:attendance_app/utils/time_window_utils.dart';
// // import 'package:attendance_app/database/upload_entry_db.dart';
// // import 'upload_details_screen.dart';

// // class UploadScreen extends StatefulWidget {
// //   const UploadScreen({super.key});

// //   @override
// //   State<UploadScreen> createState() => _UploadScreenState();
// // }

// // class _UploadScreenState extends State<UploadScreen> with WidgetsBindingObserver {
// //   late Timer _timer;
// //   List<UploadEntry> _entries = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
// //     _initializeEntries();
// //     _startAutoRefresh();
// //   }

// //   @override
// //   void dispose() {
// //     _timer.cancel();
// //     WidgetsBinding.instance.removeObserver(this);
// //     super.dispose();
// //   }

// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     if (state == AppLifecycleState.resumed) {
// //       _loadEntries(); // reload on resume
// //       _startAutoRefresh();
// //     } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
// //       _timer.cancel();
// //     }
// //   }

// //   bool _isWithinUploadHours() {
// //     final now = DateTime.now();
// //     final windows = getTimeWindowsForToday();
// //     return windows.any((w) => now.isBefore(w.end));
// //   }

// //   void _startAutoRefresh() async {
// //     _timer = Timer(Duration.zero, () async {
// //       if (!_isWithinUploadHours()) return;

// //       await _loadEntries();

// //       final now = DateTime.now();
// //       final secondsToNextMinute = 60 - now.second;

// //       Future.delayed(Duration(seconds: secondsToNextMinute), () {
// //         _timer = Timer.periodic(const Duration(minutes: 1), (_) {
// //           if (_isWithinUploadHours()) {
// //             _loadEntries();
// //           }
// //         });
// //       });
// //     });
// //   }

// //   Future<void> _initializeEntries() async {
// //     final db = UploadEntryDB();
// //     final today = DateTime.now();
// //     final todayKey = DateTime(today.year, today.month, today.day);

// //     final existing = await db.getEntriesForDate(todayKey);

// //     if (existing.isEmpty) {
// //       final windows = getTimeWindowsForToday();
// //       for (final window in windows) {
// //         final newEntry = UploadEntry(
// //           id: 0,
// //           date: todayKey,
// //           slotLabel: window.label,
// //           slotStart: window.start,
// //           slotEnd: window.end,
// //           status: 'pending',
// //         );
// //         await db.insertEntry(newEntry);
// //       }
// //     }

// //     await _loadEntries();
// //   }

// //   Future<void> _loadEntries() async {
// //     final db = UploadEntryDB();
// //     final now = DateTime.now();
// //     final todayKey = DateTime(now.year, now.month, now.day);

// //     final entries = await db.getEntriesForDate(todayKey);

// //     for (final e in entries) {
// //       if (e.status == 'pending' && now.isAfter(e.slotEnd)) {
// //         final updated = UploadEntry(
// //           id: e.id,
// //           date: e.date,
// //           slotLabel: e.slotLabel,
// //           slotStart: e.slotStart,
// //           slotEnd: e.slotEnd,
// //           status: 'missed',
// //           imagePath: e.imagePath,
// //           latitude: e.latitude,
// //           longitude: e.longitude,
// //           isSynced: e.isSynced,
// //         );
// //         await db.updateEntry(updated);
// //       }
// //     }

// //     final updatedEntries = await db.getEntriesForDate(todayKey);

// //     setState(() {
// //       _entries = updatedEntries;
// //     });
// //   }

// //   Widget _buildSection(String title, List<UploadEntry> entries, {bool isActive = false}) {
// //     if (entries.isEmpty) {
// //       return Padding(
// //         padding: const EdgeInsets.all(12.0),
// //         child: Text('No $title available.'),
// //       );
// //     }

// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
// //           child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //         ),
// //         ...entries.map((entry) => ListTile(
// //               title: Text(entry.slotLabel),
// //               subtitle: Text(entry.status == 'done'
// //                   ? 'Uploaded'
// //                   : entry.status == 'missed'
// //                       ? 'Missed'
// //                       : 'Pending'),
// //               trailing: isActive ? const Icon(Icons.arrow_forward_ios) : null,
// //               onTap: isActive
// //                   ? () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (_) =>
// //                               UploadDetailsScreen(timeSlotLabel: entry.slotLabel),
// //                         ),
// //                       );
// //                     }
// //                   : null,
// //             )),
// //       ],
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final now = DateTime.now();

// //     final active = _entries.where((e) {
// //       return e.status == 'pending' &&
// //           now.isAfter(e.slotStart) &&
// //           now.isBefore(e.slotEnd);
// //     }).toList();

// //     final upcoming = _entries.where((e) {
// //       return e.status == 'pending' && now.isBefore(e.slotStart);
// //     }).toList();

// //     final past = _entries.where((e) {
// //       return e.status == 'done' || e.status == 'missed';
// //     }).toList();

// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Upload Entries')),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             _buildSection('Active Entry', active, isActive: true),
// //             _buildSection('Upcoming Entries', upcoming),
// //             _buildSection('Past Entries', past),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // import 'dart:async';
// // // import 'package:flutter/material.dart';
// // // // import 'package:attendance_app/models/time_window.dart';
// // // import 'package:attendance_app/models/upload_entry.dart';
// // // import 'package:attendance_app/utils/time_window_utils.dart';
// // // import 'package:attendance_app/database/upload_entry_db.dart';
// // // import 'upload_details_screen.dart';

// // // class UploadScreen extends StatefulWidget {
// // //   const UploadScreen({super.key});

// // //   @override
// // //   State<UploadScreen> createState() => _UploadScreenState();
// // // }

// // // class _UploadScreenState extends State<UploadScreen> {
// // //   late Timer _timer;
// // //   List<UploadEntry> _entries = [];

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _initializeEntries();
// // //     _startAutoRefresh();
// // //   }

// // //   Future<void> _initializeEntries() async {
// // //     final db = UploadEntryDB();
// // //     final today = DateTime.now();
// // //     final todayKey = DateTime(today.year, today.month, today.day);

// // //     final existing = await db.getEntriesForDate(todayKey);

// // //     if (existing.isEmpty) {
// // //       final windows = getTimeWindowsForToday();
// // //       for (final window in windows) {
// // //         final newEntry = UploadEntry(
// // //           id: 0,
// // //           date: todayKey,
// // //           slotLabel: window.label,
// // //           slotStart: window.start,
// // //           slotEnd: window.end,
// // //           status: 'pending',
// // //         );
// // //         await db.insertEntry(newEntry);
// // //       }
// // //     }

// // //     await _loadEntries();
// // //   }

// // //   Future<void> _loadEntries() async {
// // //     final db = UploadEntryDB();
// // //     final today = DateTime.now();
// // //     final todayKey = DateTime(today.year, today.month, today.day);
// // //     final now = DateTime.now();

// // //     final entries = await db.getEntriesForDate(todayKey);

// // //     // Auto-update status to missed if slot passed
// // //     for (final e in entries) {
// // //       if (e.status == 'pending' && now.isAfter(e.slotEnd)) {
// // //         final updated = UploadEntry(
// // //           id: e.id,
// // //           date: e.date,
// // //           slotLabel: e.slotLabel,
// // //           slotStart: e.slotStart,
// // //           slotEnd: e.slotEnd,
// // //           status: 'missed',
// // //           imagePath: e.imagePath,
// // //           latitude: e.latitude,
// // //           longitude: e.longitude,
// // //           isSynced: e.isSynced,
// // //         );
// // //         await db.updateEntry(updated);
// // //       }
// // //     }

// // //     final updatedEntries = await db.getEntriesForDate(todayKey);

// // //     setState(() {
// // //       _entries = updatedEntries;
// // //     });
// // //   }

// // //   void _startAutoRefresh() {
// // //     _timer = Timer.periodic(const Duration(seconds: 60), (_) {
// // //       _loadEntries();
// // //     });
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _timer.cancel();
// // //     super.dispose();
// // //   }

// // //   Widget _buildSection(String title, List<UploadEntry> entries, {bool isActive = false}) {
// // //     if (entries.isEmpty) {
// // //       return Padding(
// // //         padding: const EdgeInsets.all(12.0),
// // //         child: Text('No $title available.'),
// // //       );
// // //     }

// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Padding(
// // //           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
// // //           child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // //         ),
// // //         ...entries.map((entry) => ListTile(
// // //               title: Text(entry.slotLabel),
// // //               subtitle: Text(entry.status == 'done'
// // //                   ? 'Uploaded'
// // //                   : entry.status == 'missed'
// // //                       ? 'Missed'
// // //                       : 'Pending'),
// // //               trailing: isActive ? const Icon(Icons.arrow_forward_ios) : null,
// // //               onTap: isActive
// // //                   ? () {
// // //                       Navigator.push(
// // //                         context,
// // //                         MaterialPageRoute(
// // //                           builder: (_) =>
// // //                               UploadDetailsScreen(timeSlotLabel: entry.slotLabel),
// // //                         ),
// // //                       );
// // //                     }
// // //                   : null,
// // //             )),
// // //       ],
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final now = DateTime.now();

// // //     final active = _entries.where((e) {
// // //       return e.status == 'pending' &&
// // //           now.isAfter(e.slotStart) &&
// // //           now.isBefore(e.slotEnd);
// // //     }).toList();

// // //     final upcoming = _entries.where((e) {
// // //       return e.status == 'pending' && now.isBefore(e.slotStart);
// // //     }).toList();

// // //     final past = _entries.where((e) {
// // //       return e.status == 'done' || e.status == 'missed';
// // //     }).toList();

// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text('Upload Entries')),
// // //       body: SingleChildScrollView(
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             _buildSection('Active Entry', active, isActive: true),
// // //             _buildSection('Upcoming Entries', upcoming),
// // //             _buildSection('Past Entries', past),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }


// // // // import 'dart:async';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:attendance_app/models/time_window.dart';
// // // // import 'package:attendance_app/utils/time_window_utils.dart';
// // // // import 'upload_details_screen.dart';

// // // // class UploadScreen extends StatefulWidget {
// // // //   const UploadScreen({super.key});

// // // //   @override
// // // //   State<UploadScreen> createState() => _UploadScreenState();
// // // // }

// // // // class _UploadScreenState extends State<UploadScreen> {
// // // //   late List<TimeWindow> _allWindows;
// // // //   late Timer _timer;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _loadWindows();
// // // //     _startAutoRefresh();
// // // //   }

// // // //   void _loadWindows() {
// // // //     setState(() {
// // // //       _allWindows = getTimeWindowsForToday();
// // // //     });
// // // //   }

// // // //   void _startAutoRefresh() {
// // // //     _timer = Timer.periodic(const Duration(seconds: 60), (_) {
// // // //       _loadWindows();
// // // //     });
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _timer.cancel();
// // // //     super.dispose();
// // // //   }

// // // //   Widget _buildSection(String title, List<TimeWindow> windows, {bool isActive = false}) {
// // // //     if (windows.isEmpty) {
// // // //       return Padding(
// // // //         padding: const EdgeInsets.all(12.0),
// // // //         child: Text('No $title available.'),
// // // //       );
// // // //     }

// // // //     return Column(
// // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // //       children: [
// // // //         Padding(
// // // //           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
// // // //           child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // //         ),
// // // //         ...windows.map((slot) => ListTile(
// // // //               title: Text(slot.label),
// // // //               trailing: isActive ? const Icon(Icons.arrow_forward_ios) : null,
// // // //               onTap: isActive
// // // //                   ? () {
// // // //                       Navigator.push(
// // // //                         context,
// // // //                         MaterialPageRoute(
// // // //                           builder: (_) => UploadDetailsScreen(timeSlotLabel: slot.label),
// // // //                         ),
// // // //                       );
// // // //                     }
// // // //                   : null,
// // // //             )),
// // // //       ],
// // // //     );
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final now = DateTime.now();

// // // //     final active = _allWindows.where((slot) => now.isAfter(slot.start) && now.isBefore(slot.end)).toList();
// // // //     final upcoming = _allWindows.where((slot) => now.isBefore(slot.start)).toList();
// // // //     final past = _allWindows.where((slot) => now.isAfter(slot.end)).toList();

// // // //     return Scaffold(
// // // //       appBar: AppBar(title: const Text('Upload Entries')),
// // // //       body: SingleChildScrollView(
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             _buildSection('Active Entry', active, isActive: true),
// // // //             _buildSection('Upcoming Entries', upcoming),
// // // //             _buildSection('Past Entries', past),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
