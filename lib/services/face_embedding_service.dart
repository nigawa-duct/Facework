import 'dart:math';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEmbeddingService {
  FaceEmbeddingService._();

  static final FaceEmbeddingService instance = FaceEmbeddingService._();

  static const String modelAssetPath = 'assets/models/mobilefacenet.tflite';
  static const int inputSize = 112;
  static const int embeddingSize = 192;

  Interpreter? _interpreter;

  Future<void> _loadModel() async {
    if (_interpreter != null) {
      return;
    }

    final options = InterpreterOptions()..threads = 4;
    try {
      _interpreter = await Interpreter.fromAsset(modelAssetPath, options: options);
    } on Exception catch (e) {
      throw Exception('assets/models/mobilefacenet.tflite が見つかりません: ${e.toString()}');
    }
  }

  Future<List<double>> createEmbedding(img.Image faceImage) async {
    await _loadModel();

    final input = _preprocess(faceImage);
    final output = List.generate(
      1,
      (_) => List<double>.filled(embeddingSize, 0.0),
    );

    _interpreter!.run(input, output);

    return _l2Normalize(output[0]);
  }

  List<List<List<List<double>>>> _preprocess(img.Image faceImage) {
    final resizedImage = img.copyResize(faceImage, width: inputSize, height: inputSize);

    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (_) => List.generate(
          inputSize,
          (_) => List<double>.filled(3, 0.0),
        ),
      ),
    );

    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        final r = img.getRed(pixel) / 255.0;
        final g = img.getGreen(pixel) / 255.0;
        final b = img.getBlue(pixel) / 255.0;

        input[0][y][x][0] = (r - 0.5) / 0.5;
        input[0][y][x][1] = (g - 0.5) / 0.5;
        input[0][y][x][2] = (b - 0.5) / 0.5;
      }
    }

    return input;
  }

  List<double> _l2Normalize(List<double> embedding) {
    var sum = 0.0;
    for (final value in embedding) {
      sum += value * value;
    }

    final norm = sum > 0 ? sqrt(sum) : 1.0;
    return embedding.map((value) => value / norm).toList();
  }

  Future<void> close() async {
    _interpreter?.close();
    _interpreter = null;
  }
}
