import '../models/attendance.dart';
import 'database_service.dart';

class AttendanceService {
  AttendanceService._();

  static final AttendanceService instance = AttendanceService._();

  /// 出勤
  Future<void> clockIn(int employeeId) async {
    final attendance = Attendance(
      employeeId: employeeId,
      type: '出勤',
      dateTime: DateTime.now().toIso8601String(),
    );

    await DatabaseService.instance.insertAttendance(attendance);
  }

  /// 退勤
  Future<void> clockOut(int employeeId) async {
    final attendance = Attendance(
      employeeId: employeeId,
      type: '退勤',
      dateTime: DateTime.now().toIso8601String(),
    );

    await DatabaseService.instance.insertAttendance(attendance);
  }

  /// 履歴取得
  Future<List<Attendance>> getHistory() async {
    return DatabaseService.instance.getAttendance();
  }
}