import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/services/face_recognition_service.dart';
import '../../core/providers/clientes_provider.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';

class AccessControlScreen extends StatefulWidget {
  const AccessControlScreen({super.key});

  @override
  State<AccessControlScreen> createState() => _AccessControlScreenState();
}

class _AccessControlScreenState extends State<AccessControlScreen> {
  CameraController? _controller;
  final FaceRecognitionService _faceService = FaceRecognitionService();
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _status = 'Iniciando cámara...';

  Cliente? _matchedCliente;
  bool _accessGranted = false;
  Timer? _clearTimer;

  @override
  void initState() {
    super.initState();
    _startEverything();
  }

  Future<void> _startEverything() async {
    await _faceService.initialize();
    final cameras = await availableCameras();
    final frontCam = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCam,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _controller!.initialize();
      _isInitialized = true;
      _status = 'Buscando rostro...';
      if (mounted) setState(() {});

      _startStreaming();
    } catch (e) {
      debugPrint('Error camera: $e');
      setState(() => _status = 'Error al iniciar cámara');
    }
  }

  void _startStreaming() {
    _controller?.startImageStream((CameraImage image) async {
      if (_isProcessing || _matchedCliente != null) return;

      _isProcessing = true;
      try {
        // 1. Detect Face in frame
        // Note: For streaming we might want a faster detection mode or throttle
        final inputImage = _faceService.getInputImageFromCameraImage(
          image,
          _controller!.description.sensorOrientation,
        );
        final face = await _faceService.detectFace(inputImage);

        if (face != null) {
          setState(() => _status = 'Identificando...');

          // 2. Generate Embedding
          final embedding = await _faceService.generateEmbedding(image, face);

          // 3. Search in DB
          if (!mounted) return;
          final cliente = await context
              .read<ClientesProvider>()
              .identificarCliente(embedding);

          if (cliente != null && mounted) {
            _handleMatch(cliente);
          } else {
            // Optional: Show "Desconocido" briefly
          }
        }
      } catch (e) {
        debugPrint('Stream error: $e');
      } finally {
        _isProcessing = false;
        if (_matchedCliente == null && mounted) {
          setState(() => _status = 'Buscando rostro...');
        }
      }
    });
  }

  void _handleMatch(Cliente cliente) {
    setState(() {
      _matchedCliente = cliente;
      _accessGranted = cliente.estado == 'ACTIVO';
      _status = _accessGranted ? '¡Bienvenido!' : 'Acceso Denegado';
    });

    // Clear after 3 seconds to allow next person
    _clearTimer?.cancel();
    _clearTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _matchedCliente = null;
          _status = 'Buscando rostro...';
        });
      }
    });
  }

  @override
  void dispose() {
    _clearTimer?.cancel();
    _controller?.dispose();
    _faceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: 1 / _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Overlay Guide
          Center(
            child: Container(
              width: 280,
              height: 350,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _matchedCliente != null
                      ? (_accessGranted
                            ? AppColors.activeGreen
                            : AppColors.expiredRed)
                      : Colors.white.withValues(alpha: 0.3),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(140),
              ),
            ),
          ),

          // Status & Info Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _status,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _matchedCliente != null
                          ? (_accessGranted
                                ? AppColors.activeGreen
                                : AppColors.expiredRed)
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (_matchedCliente != null) ...[
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _matchedCliente!.fotoUrl != null
                          ? NetworkImage(_matchedCliente!.fotoUrl!)
                          : null,
                      child: _matchedCliente!.fotoUrl == null
                          ? Text(
                              _matchedCliente!.nombre[0],
                              style: const TextStyle(fontSize: 32),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _matchedCliente!.nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _accessGranted
                          ? 'Membresía Activa'
                          : 'Membresía Vencida o Inactiva',
                      style: TextStyle(
                        color: _accessGranted
                            ? AppColors.activeGreen
                            : AppColors.expiredRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_matchedCliente == null)
                    const Text(
                      'Posicione su rostro dentro del marco',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 48,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
