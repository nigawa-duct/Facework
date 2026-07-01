import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../models/employee.dart';
import '../services/attendance_service.dart';
import '../services/database_service.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  CameraController? controller;
  bool ready = false;
  bool faceDetected = false;
  bool processing = false;
  String statusMessage = '顔を検出して打刻してください';
  List<Employee> employees = [];
  Employee? selectedEmployee;

  @override
  void initState() {
    super.initState();
    initPage();
  }

  Future<void> initPage() async {
    await loadEmployees();
    await initCamera();
  }

  Future<void> loadEmployees() async {
    final list = await DatabaseService.instance.getEmployees();
    if (!mounted) return;

    setState(() {
      employees = list;
      if (selectedEmployee == null && employees.isNotEmpty) {
        selectedEmployee = employees.first;
      }
    });
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();
    } catch (e) {
      statusMessage = 'カメラの準備に失敗しました';
    }

    if (!mounted) return;

    setState(() {
      ready = controller?.value.isInitialized == true;
    });
  }

  Future<void> detectFace() async {
    if (controller == null || !controller!.value.isInitialized || processing) {
      return;
    }

    setState(() {
      processing = true;
      statusMessage = '顔検出中...';
    });

    try {
      final XFile photo = await controller!.takePicture();
      final inputImage = InputImage.fromFilePath(photo.path);
      final detector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
        ),
      );

      final faces = await detector.processImage(inputImage);
      await detector.close();

      if (!mounted) return;

      setState(() {
        faceDetected = faces.isNotEmpty;
        statusMessage = faces.isNotEmpty
            ? '顔を検出しました（${faces.length}人）'
            : '顔が検出できませんでした。もう一度撮影してください。';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(statusMessage),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          faceDetected = false;
          statusMessage = '顔検出に失敗しました';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('顔検出ができませんでした。'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          processing = false;
        });
      }
    }
  }

  Future<void> recordAttendance(String type) async {
    if (selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('社員を選択してください')), 
      );
      return;
    }

    if (!faceDetected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先に顔を検出してください')), 
      );
      return;
    }

    final id = selectedEmployee!.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('社員情報が正しくありません')), 
      );
      return;
    }

    await (type == '出勤'
        ? AttendanceService.instance.clockIn(id)
        : AttendanceService.instance.clockOut(id));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedEmployee!.name} さんの$typeを記録しました'),
      ),
    );

    setState(() {
      faceDetected = false;
      statusMessage = '顔を検出して打刻してください';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打刻'),
      ),
      body: ready
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: controller!.value.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CameraPreview(controller!),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          statusMessage,
                          style: TextStyle(
                            color: faceDetected ? Colors.green : Colors.black87,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: processing ? null : detectFace,
                        icon: const Icon(Icons.face),
                        label: const Text('顔検出'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (employees.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('顔登録済み社員がいません。顔登録ページから登録してください。'),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButtonFormField<Employee>(
                          initialValue: selectedEmployee,
                          decoration: const InputDecoration(
                            labelText: '社員を選択',
                            border: OutlineInputBorder(),
                          ),
                          items: employees.map((employee) {
                            return DropdownMenuItem(
                              value: employee,
                              child: Text(employee.name),
                            );
                          }).toList(),
                          onChanged: (employee) {
                            setState(() {
                              selectedEmployee = employee;
                            });
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: processing ? null : () => recordAttendance('出勤'),
                          child: const Text('出勤'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: processing ? null : () => recordAttendance('退勤'),
                          child: const Text('退勤'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
