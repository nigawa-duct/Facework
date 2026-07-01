import '../models/employee.dart';
import '../services/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  CameraController? controller;
  bool ready = false;

  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();

    if (!mounted) return;

    setState(() {
      ready = true;
    });
  }

  Future<void> capture() async {
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }

    final XFile photo = await controller!.takePicture();
    final appDir = await getApplicationDocumentsDirectory();
    final imagePath =
    '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    await photo.saveTo(imagePath);
    
    final inputImage = InputImage.fromFilePath(photo.path);

    final detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    final faces = await detector.processImage(inputImage);

    await detector.close();
    if (faces.isEmpty) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("顔が検出できませんでした"),
            ),
    );
    return;
}

await DatabaseService.instance.insertEmployee(
  Employee(
    name: nameController.text.trim(),
    faceData: imagePath,
  ),
);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text("${nameController.text} さんを登録しました"),
  ),
);

nameController.clear();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "検出した顔：${faces.length}人",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("顔登録"),
      ),
            body: ready
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "名前",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: CameraPreview(controller!),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: capture,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("撮影して登録"),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    nameController.dispose();
    super.dispose();
  }
}