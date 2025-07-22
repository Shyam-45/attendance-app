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
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late Timer _timer;
  List<UploadEntry> _entries = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _initializeEntries();
    _startAutoRefresh();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _fadeController.dispose();
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

    await _loadEntries();
  }

  Future<void> _loadEntries() async {
    final db = UploadEntryDB();
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);
    final entries = await db.getEntriesForDate(todayKey);

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
    Color sectionColor;
    IconData sectionIcon;

    if (title.contains('Active')) {
      sectionColor = const Color(0xFF10B981);
      sectionIcon = Icons.play_circle_filled;
    } else if (title.contains('Upcoming')) {
      sectionColor = const Color(0xFFF59E0B);
      sectionIcon = Icons.schedule_rounded;
    } else {
      sectionColor = const Color(0xFF6B7280);
      sectionIcon = Icons.history_rounded;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  sectionColor.withOpacity(0.1),
                  sectionColor.withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sectionColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: sectionColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(sectionIcon, color: sectionColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: sectionColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: sectionColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${entries.length}',
                    style: TextStyle(
                      color: sectionColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (entries.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No entries available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Entries will appear here when available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...entries.asMap().entries.map(
              (entry) => AnimatedContainer(
                duration: Duration(milliseconds: 300 + (entry.key * 100)),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isActive
                        ? () async {
                            final result = await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        UploadDetailsScreen(entry: entry.value),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                              ),
                            );

                            if (result == true) {
                              await _loadEntries();
                            }
                          }
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF3B82F6).withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getStatusColor(
                                    entry.value.status,
                                  ).withOpacity(0.2),
                                  _getStatusColor(
                                    entry.value.status,
                                  ).withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getStatusColor(
                                  entry.value.status,
                                ).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              _getStatusIcon(entry.value.status),
                              color: _getStatusColor(entry.value.status),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.value.slotLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _statusSubtitle(entry.value),
                              ],
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Color(0xFF3B82F6),
                                size: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'done':
        return const Color(0xFF10B981);
      case 'missed':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'done':
        return Icons.check_circle_rounded;
      case 'missed':
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  Widget _statusSubtitle(UploadEntry entry) {
    Color statusColor = _getStatusColor(entry.status);
    String statusText;

    switch (entry.status) {
      case 'done':
        statusText = 'Completed Successfully';
        break;
      case 'missed':
        statusText = 'Window Expired';
        break;
      default:
        statusText = 'Awaiting Upload';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final active = _entries
        .where(
          (e) =>
              now.isAfter(e.slotStart) &&
              now.isBefore(e.slotEnd) &&
              e.status == 'pending',
        )
        .toList();

    final upcoming = _entries
        .where(
          (e) =>
              e.status == 'pending' &&
              now.isBefore(e.slotStart) &&
              now.isBefore(e.slotEnd),
        )
        .toList();

    final past = _entries
        .where((e) => e.status == 'done' || e.status == 'missed')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.cloud_upload_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Center',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage your attendance entries',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection('Active Entry', active, isActive: true),
                        const SizedBox(height: 16),
                        _buildSection('Upcoming Entries', upcoming),
                        const SizedBox(height: 16),
                        _buildSection('Past Entries', past),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
