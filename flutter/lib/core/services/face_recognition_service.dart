import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FaceRecognitionService {
  late Interpreter _interpreter;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true,
    ),
  );

  bool _isInitialized = false;
  static const int inputSize = 112;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final options = InterpreterOptions();
      _interpreter = await Interpreter.fromAsset(
        'assets/models/mobile_face_net.tflite',
        options: options,
      );
      _isInitialized = true;
      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Failed to load model: $e');
    }
  }

  Future<Face?> detectFace(InputImage inputImage) async {
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;
    return faces.reduce(
      (a, b) =>
          (a.boundingBox.width * a.boundingBox.height) >
              (b.boundingBox.width * b.boundingBox.height)
          ? a
          : b,
    );
  }

  img.Image _cropFace(img.Image originalImage, Face face) {
    final x = face.boundingBox.left.toInt().clamp(0, originalImage.width);
    final y = face.boundingBox.top.toInt().clamp(0, originalImage.height);
    final w = face.boundingBox.width.toInt().clamp(0, originalImage.width - x);
    final h = face.boundingBox.height.toInt().clamp(
      0,
      originalImage.height - y,
    );

    img.Image cropped = img.copyCrop(
      originalImage,
      x: x,
      y: y,
      width: w,
      height: h,
    );
    return img.copyResize(cropped, width: inputSize, height: inputSize);
  }

  Future<List<double>> generateEmbedding(
    CameraImage cameraImage,
    Face face,
  ) async {
    if (!_isInitialized) await initialize();

    img.Image image = _convertYUV420ToImage(cameraImage);
    img.Image processedImage = _cropFace(image, face);

    // MobileFaceNet expects [1, 112, 112, 3] input
    var input = _imageToFloatList(processedImage);

    // Output: [1, 192]
    var output = List<double>.filled(192, 0).reshape([1, 192]);

    _interpreter.run(input, output);

    // Flatten output
    return List<double>.from(output[0]);
  }

  // Pre-process: [112, 112, 3] normalized
  List _imageToFloatList(img.Image image) {
    var floatList = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(floatList.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        // Normalized to included range [-1, 1]
        buffer[pixelIndex++] = (pixel.r - 128) / 128;
        buffer[pixelIndex++] = (pixel.g - 128) / 128;
        buffer[pixelIndex++] = (pixel.b - 128) / 128;
      }
    }
    return floatList.reshape([1, inputSize, inputSize, 3]);
  }

  Future<List<double>?> getEmbeddingFromFile(File file) async {
    if (!_isInitialized) await initialize();

    // 1. Detect Face
    final inputImage = InputImage.fromFile(file);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) return null;

    final face = faces.reduce(
      (a, b) =>
          (a.boundingBox.width * a.boundingBox.height) >
              (b.boundingBox.width * b.boundingBox.height)
          ? a
          : b,
    );

    // 2. Decode Image
    final bytes = await file.readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) return null;

    // Fix orientation if needed (important for mobile photos)
    image = img.bakeOrientation(image);

    final processedImage = _cropFace(image, face);

    // 3. Generate Embedding
    var input = _imageToFloatList(processedImage);
    var output = List<double>.filled(192, 0).reshape([1, 192]);
    _interpreter.run(input, output);

    return List<double>.from(output[0]);
  }

  img.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    // Proper YUV to RGB conversion
    final img.Image image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final yp = cameraImage.planes[0].bytes[index];
        final up = cameraImage.planes[1].bytes[uvIndex];
        final vp = cameraImage.planes[2].bytes[uvIndex];

        // YUV to RGB conversion formula
        int r = (yp + 1.402 * (vp - 128)).toInt().clamp(0, 255);
        int g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128))
            .toInt()
            .clamp(0, 255);
        int b = (yp + 1.772 * (up - 128)).toInt().clamp(0, 255);

        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }
    return image;
  }

  InputImage getInputImageFromCameraImage(
    CameraImage image,
    int sensorOrientation,
  ) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.yuv420;

    final inputImageData = InputImageMetadata(
      size: imageSize,
      rotation:
          InputImageRotationValue.fromRawValue(sensorOrientation) ??
          InputImageRotation.rotation90deg,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
  }

  void dispose() {
    _faceDetector.close();
    _interpreter.close();
  }
}
