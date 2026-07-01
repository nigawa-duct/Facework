import 'package:flutter/material.dart';

import '../models/attendance.dart';
import '../services/attendance_service.dart';
import '../services/database_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool loading = true;
  List<Attendance> history = [];
  Map<int, String> employeeNames = {};

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final attendanceList = await AttendanceService.instance.getHistory();
    final employees = await DatabaseService.instance.getEmployees();
    final nameMap = <int, String>{};

    for (final employee in employees) {
      if (employee.id != null) {
        nameMap[employee.id!] = employee.name;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      history = attendanceList;
      employeeNames = nameMap;
      loading = false;
    });
  }

  String buildEmployeeName(int employeeId) {
    return employeeNames[employeeId] ?? '社員ID:$employeeId';
  }

  String formatDateTime(String dateTime) {
    final parsed = DateTime.tryParse(dateTime);
    if (parsed == null) {
      return dateTime;
    }

    final year = parsed.year.toString().padLeft(4, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');

    return '$year/$month/$day $hour:$minute';
  }

  IconData getTypeIcon(String type) {
    if (type == '出勤') {
      return Icons.login;
    }
    if (type == '退勤') {
      return Icons.logout;
    }
    return Icons.history;
  }

  Color getTypeColor(String type) {
    if (type == '出勤') {
      return Colors.green;
    }
    if (type == '退勤') {
      return Colors.red;
    }
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打刻履歴'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : history.isEmpty
              ? const Center(
                  child: Text(
                    'まだ打刻履歴はありません',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final attendance = history[index];
                    final name = buildEmployeeName(attendance.employeeId);
                    final icon = getTypeIcon(attendance.type);
                    final color = getTypeColor(attendance.type);
                    final formattedDate = formatDateTime(attendance.dateTime);

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.1),
                          child: Icon(
                            icon,
                            color: color,
                          ),
                        ),
                        title: Text(name),
                        subtitle: Text(formattedDate),
                        trailing: Text(
                          attendance.type,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
