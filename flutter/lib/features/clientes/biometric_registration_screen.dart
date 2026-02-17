import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/services/face_recognition_service.dart';
import '../../core/providers/clientes_provider.dart';
import '../../core/services/image_service.dart';

class BiometricRegistrationScreen extends StatefulWidget {
  final String clienteId;
  final String clienteNombre;

  const BiometricRegistrationScreen({
    super.key,
    required this.clienteId,
    required this.clienteNombre,
  });

  @override
  State<BiometricRegistrationScreen> createState() =>
      _BiometricRegistrationScreenState();
}

class _BiometricRegistrationScreenState
    extends State<BiometricRegistrationScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isProcessing = false;
  String? _statusMessage;

  final FaceRecognitionService _faceService = FaceRecognitionService();
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    _initCamera();
    _faceService.initialize();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceService.dispose();
    super.dispose();
  }

  Future<void> _captureAndRegister() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Capturando rostro...';
    });

    try {
      final image = await _controller!.takePicture();
      final file = File(image.path);

      setState(() => _statusMessage = 'Analizando biometría...');

      // 1. Detect and Embed
      // Note: In a real app we would stream frames.
      // For simplicity/MVP we take a picture.
      // We need to convert File to CameraImage or use a method that accepts File.
      // Current FaceRecognitionService expects CameraImage for stream.
      // Let's assume we update FaceRecognitionService to accept File or InputImage.
      // ACTUALLY: ML Kit's InputImage can be created from File.

      // We need to verify if FaceRecognitionService has a method for File or InputImage.
      // Looking at previous context, it has `processImage(CameraImage image)`.
      // We should probably add `processFile(File file)` or similar to service.
      // Or we implement a method here to bridge.
      // For now, let's assume we add `getEmbeddingFromFile(File file)` to service.

      // WAIT. FaceRecognitionService was implemented to work with CameraImage stream.
      // Using `InputImage.fromFilePath(file.path)` is easier for static images.

      final embedding = await _faceService.getEmbeddingFromFile(file);

      if (embedding == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se detectó un rostro claro. Intente de nuevo.'),
          ),
        );
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
        return;
      }

      setState(() => _statusMessage = 'Subiendo foto...');

      // 2. Compress & Upload
      final compressed = await _imageService.compressImage(file);
      if (compressed == null) throw Exception('Error comprimiendo imagen');

      final publicUrl = await _imageService.uploadImage(
        compressed,
        'clientes/${widget.clienteId}',
      );

      setState(() => _statusMessage = 'Guardando perfil...');

      if (!mounted) return;
      // 3. Register in Backend
      final success = await context.read<ClientesProvider>().registrarBiometria(
        clienteId: widget.clienteId,
        embedding: embedding,
        publicFotoUrl: publicUrl,
      );

      if (!mounted) return;
      if (success) {
        Navigator.pop(context, true); // Success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar datos biométricos.')),
        );
      }
    } catch (e) {
      debugPrint('Error en registro biométrico: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro Biométrico')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    fit: StackFit.loose,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: CameraPreview(_controller!),
                      ),
                      // Face overlay guide
                      Center(
                        child: Container(
                          width: 250,
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(150),
                          ),
                        ),
                      ),
                      if (_isProcessing)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _statusMessage ?? 'Procesando...',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _captureAndRegister,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capturar y Registrar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
