# Plan de Implementación: Sistema de Registro y Acceso Facial Híbrido (Edge AI)

Este documento detalla la implementación de un sistema de reconocimiento facial optimizado para dispositivos móviles (Edge AI) utilizando Flutter, TFLite y Supabase. El objetivo es minimizar el uso de recursos del backend (Render) y aprovechar la potencia del dispositivo del usuario.

## 1. Arquitectura General

El sistema sigue un enfoque "Edge-First":
1.  **Captura (Flutter):** La app toma una foto o video.
2.  **Detección (On-Device):** ML Kit detecta rostros y recorta el área de interés.
3.  **Embedding (On-Device):** Un modelo TFLite (MobileFaceNet) convierte el rostro en un vector numérico (embedding) localmente.
4.  **Almacenamiento (Supabase):**
    *   La imagen se comprime a WebP (<100kb) y se sube a Supabase Storage.
    *   El vector y la URL de la imagen se guardan en PostgreSQL (con extensión `pgvector`).
5.  **Verificación (Híbrida):**
    *   Para comparar 1 a 1 (verificar si eres quien dices ser), se puede hacer localmente calculando la distancia entre el nuevo vector y el guardado localmente (si se tiene cacheado).
    *   Para buscar 1 a N (identificar quién es), se envía el vector generado a una función RPC en Supabase que usa índices eficientes para encontrar la coincidencia más cercana.

## 2. Configuración de Base de Datos (Supabase)

Debemos habilitar `pgvector` y modificar la tabla `cliente` existente.

### Script SQL

Ejecuta este script en el Editor SQL de tu dashboard de Supabase:

```sql
-- 1. Habilitar extensión para vectores
create extension if not exists vector schema extensions;

-- 2. Agregar columnas de biometría a la tabla existente 'gym.cliente'
-- Nota: Usamos el esquema 'gym' según tu configuración actual
alter table gym.cliente 
add column if not exists face_embedding vector(192), -- MobileFaceNet usa 192 dimensiones (o 512/128 según variante)
add column if not exists avatar_url varchar(500);

-- 3. Crear índice para búsquedas rápidas (HNSW)
-- Esto es crucial para la performance cuando tengas muchos usuarios
create index on gym.cliente using hnsw (face_embedding vector_l2_ops);

-- 4. Función RPC para buscar usuarios por similitud facial
-- Recibe un vector y devuelve el cliente más similar si supera el umbral
create or replace function gym.match_face_embedding(
  query_embedding vector(192),
  match_threshold float,
  match_count int
)
returns table (
  id uuid,
  nombre varchar,
  similarity float
)
language plpgsql
as $$
begin
  return query
  select
    gym.cliente.id,
    gym.cliente.nombre,
    1 - (gym.cliente.face_embedding <=> query_embedding) as similarity
  from gym.cliente
  where 1 - (gym.cliente.face_embedding <=> query_embedding) > match_threshold
  order by gym.cliente.face_embedding <=> query_embedding
  limit match_count;
end;
$$;
```

**Nota Importante sobre Dimensiones:** El modelo MobileFaceNet estándar suele generar vectores de 192 dimensiones. Si usas Facenet (512 o 128), debes ajustar el número `192` en el script SQL al tamaño exacto de salida de tu modelo `.tflite`.

## 3. Implementación en Flutter

### Dependencias (`pubspec.yaml`)

Agrega estas librerías para manejar cámara, ML, y compresión.

```yaml
dependencies:
  camera: ^0.10.5+9
  google_mlkit_face_detection: ^0.10.0
  tflite_flutter: ^0.10.4
  image: ^4.1.7 # Para pre-procesamiento de matrices
  flutter_image_compress: ^2.3.0
  supabase_flutter: ^2.5.0 # Ya la tienes
```

### Obtención del Modelo

Debes descargar el modelo **MobileFaceNet** cuantizado (para menor peso y rapidez) en formato `.tflite`.
*   **Fuente recomendada:** [Repositorio de Modelos TFLite](https://github.com/shubham0204/Face-Recognition-TFLite-Android/tree/master/app/src/main/assets) (Busca `mobile_face_net.tflite`).
*   Coloca el archivo en `assets/models/mobile_face_net.tflite`.
*   Regístralo en `pubspec.yaml`.

### Servicio de Reconocimiento (`FaceRecognitionService`)

Este servicio encapsula la lógica compleja de IA.

```dart
// lib/core/services/face_recognition_service.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FaceRecognitionService {
  late Interpreter _interpreter;
  late IsolateInterpreter _isolateInterpreter;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true, 
    ),
  );

  bool _isInitialized = false;

  // Dimensiones de entrada del modelo (ajustar según tu .tflite)
  static const int inputSize = 112; 
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final options = InterpreterOptions();
      // Usar GPU si es posible (opcional, CPU suele bastar para MobileFaceNet)
      // options.addDelegate(GpuDelegateV2()); 
      
      _interpreter = await Interpreter.fromAsset('assets/models/mobile_face_net.tflite', options: options);
      // _isolateInterpreter = await IsolateInterpreter.create(address: _interpreter.address);
      _isInitialized = true;
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  /// Paso 1: Detectar rostro en una imagen de cámara
  Future<Face?> detectFace(InputImage inputImage) async {
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;
    // Retornamos el rostro más prominente/grande
    return faces.reduce((a, b) => (a.boundingBox.width * a.boundingBox.height) > (b.boundingBox.width * b.boundingBox.height) ? a : b);
  }

  /// Paso 2: Recortar y Preprocesar imagen para el modelo
  img.Image _cropFace(img.Image originalImage, Face face) {
    final x = face.boundingBox.left.toInt().clamp(0, originalImage.width);
    final y = face.boundingBox.top.toInt().clamp(0, originalImage.height);
    final w = face.boundingBox.width.toInt().clamp(0, originalImage.width - x);
    final h = face.boundingBox.height.toInt().clamp(0, originalImage.height - y);
    
    img.Image cropped = img.copyCrop(originalImage, x: x, y: y, width: w, height: h);
    return img.copyResize(cropped, width: inputSize, height: inputSize);
  }

  /// Paso 3: Generar Embedding (Vector)
  /// Retorna lista de doubles para pgvector
  Future<List<double>> generateEmbedding(CameraImage cameraImage, Face face) async {
    if (!_isInitialized) await initialize();

    // Conversión YUV420 a RGB (simplificada, usar librería externa es mejor para performance)
    // Aquí asumimos que ya tienes una img.Image convertida desde CameraImage
    // TODO: Implementar conversión eficiente YUV -> RGB
    img.Image image = _convertYUV420ToImage(cameraImage);

    // Recortar
    img.Image processedImage = _cropFace(image, face);

    // Normalizar datos [0, 255] -> [-1, 1] o [0, 1] según requiera el modelo
    // MobileFaceNet suele requerir normalización estándar
    List input = _imageToFloatList(processedImage);
    
    // Output buffer (192 floats)
    var output = List<double>.filled(192, 0).reshape([1, 192]);

    // Inferencia
    _interpreter.run(input, output);

    return List<double>.from(output[0]);
  }

  // Helper: Convertir imagen a lista de floats normalizada
  List _imageToFloatList(img.Image image) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        // Normalización típica: (pixel - 128) / 128
        buffer[pixelIndex++] = (img.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (img.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (img.getBlue(pixel) - 128) / 128;
      }
    }
    return convertedBytes.reshape([1, inputSize, inputSize, 3]);
  }

  // Helper placeholder
  img.Image _convertYUV420ToImage(CameraImage cameraImage) {
    // Implementación estándar de conversion YUV a RGB
    // Se recomienda usar paquete `image` o hacerlo nativo para velocidad
    return img.Image(width: cameraImage.width, height: cameraImage.height); // Dummy
  }
  
  void dispose() {
    _faceDetector.close();
    _interpreter.close();
  }
}
```

## 4. Almacenamiento (Supabase Storage)

1.  Crear un bucket público llamado `avatars`.
2.  Configurar política RLS para permitir `INSERT` a usuarios autenticados.

### Servicio de Imagen (`ImageService`)

```dart
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class ImageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<File?> compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out.webp";

    return await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, 
      outPath,
      quality: 70, // Calidad media balanceada
      format: CompressFormat.webp,
    );
  }

  Future<String?> uploadAvatar(File imageFile, String userId) async {
    try {
      final ext = p.extension(imageFile.path);
      final path = '$userId/avatar$ext';
      
      await _supabase.storage.from('avatars').upload(
        path,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      return _supabase.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }
}
```

## 5. Lógica de Registro (Enrollment Flow)

En tu `ClientesProvider` o ViewModel:

```dart
Future<void> registrarClienteConBiometria(Cliente cliente, File? fotoOriginal) async {
  
  String? avatarUrl;
  List<double>? faceEmbedding;

  if (fotoOriginal != null) {
    // 1. Detección y Embedding (si el usuario acepta)
    if (usuarioAceptaBiometria) {
       // Convertir File a InputImage/CameraImage y procesar
       // faceEmbedding = await _faceRecognitionService.generateEmbedding(...);
    }

    // 2. Compresión
    final compressed = await _imageService.compressImage(fotoOriginal);
    
    // 3. Subida
    if (compressed != null) {
      avatarUrl = await _imageService.uploadAvatar(compressed, cliente.id);
    }
  }

  // 4. Guardar en Base de Datos
  final data = {
    ...cliente.toJson(),
    'face_embedding': faceEmbedding, // pgvector lo maneja como array
    'foto_url': avatarUrl,
  };

  await _supabase.from('cliente').insert(data);
}
```

## 6. Lógica de Acceso Facial

Para verificar acceso:

1.  Cámara captura rostro.
2.  Service genera vector `v_input`.
3.  Llamar a RPC:
    ```dart
    final response = await _supabase.rpc('match_face_embedding', params: {
      'query_embedding': v_input,
      'match_threshold': 0.6, // Ajustar según pruebas (0.5 - 0.7)
      'match_count': 1
    });

    if (response.isNotEmpty) {
       final clienteId = response[0]['id'];
       final similitud = response[0]['similarity'];
       print("Cliente identificado: $clienteId con confianza $similitud");
       // Registrar Asistencia
    } else {
       print("Rostro no reconocido");
    }
    ```

---
Este plan prioriza el procesamiento local (Edge) y el almacenamiento eficiente, cumpliendo estrictamente con los requisitos de bajo costo y alta optimización.
