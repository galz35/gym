import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<File?> compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'\.'));
    final split = lastIndex != -1 ? filePath.substring(0, lastIndex) : filePath;
    final outPath = '${split}_out.webp';

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 70,
      format: CompressFormat.webp,
    );

    return result != null ? File(result.path) : null;
  }

  Future<String?> uploadImage(File file, String folder) async {
    try {
      final fileName = '${const Uuid().v4()}.webp';
      final path = '$folder/$fileName';

      await _supabase.storage
          .from('gym_assets')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = _supabase.storage.from('gym_assets').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
