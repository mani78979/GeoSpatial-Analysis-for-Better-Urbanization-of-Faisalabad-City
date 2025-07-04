import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ModelHandler {
  Interpreter? _interpreter;

  Interpreter? get interpreter => _interpreter;


  // Load the model with retry mechanism
  Future<void> loadModel() async {
    try {
      final modelDownloader = FirebaseModelDownloader.instance;
      final conditions = FirebaseModelDownloadConditions();
      final customModel = await modelDownloader.getModel(
        'model1',
        FirebaseModelDownloadType.localModel,
        conditions,
      );
      _interpreter = await Interpreter.fromFile(customModel.file);
      print("Model loaded successfully.");
    } catch (e) {
      print("Model loading failed: $e");
      rethrow;  // Throw error to handle externally if needed
    }
  }

  // Preprocess the image and catch any processing errors
  List<List<List<double>>> preprocessImage(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes)!;
      final resizedImage = img.copyResize(image, width: 224, height: 224);
      List<List<List<double>>> inputImage = List.generate(
        224,
            (i) => List.generate(
          224,
              (j) {
            var pixel = resizedImage.getPixel(j, i);
            return [
              img.getRed(pixel) / 255.0,
              img.getGreen(pixel) / 255.0,
              img.getBlue(pixel) / 255.0,
            ];
          },
        ),
      );
      return inputImage;
    } catch (e) {
      print("Image preprocessing error: $e");
      rethrow;
    }
  }

  // Prediction function with additional exception handling
  Future<Map<String, dynamic>> getPredictions(Uint8List imageBytes) async {
    if (_interpreter == null) {
      throw Exception("Model is not loaded.");
    }

    try {
      _interpreter?.allocateTensors();  // Allocate tensors before inference
      List<List<List<List<double>>>> input = [preprocessImage(imageBytes)];
      List<List<double>> output = List.generate(1, (index) => List.filled(3, 0.0));

      _interpreter?.run(input, output);

      return {
        'land_type': output[0][0] == 1.0 ? 'Urban' : 'Rural',
        'population_density': output[0][1] == 2.0 ? 'High' : (output[0][1] == 1.0 ? 'Medium' : 'Low'),
        'development_sprawl': output[0][2] == 1.0 ? 'Developing' : 'Agricultural',
      };
    } catch (e, stacktrace) {
      print("Error during model inference: $e");
      print("Stacktrace: $stacktrace");
      throw Exception("Error during model inference");
    }
  }

  void close() {
    _interpreter?.close();
  }
}
