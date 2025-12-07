

// lib/services/supabase_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Admin client with service_role key (bypasses all policies)
  static final _adminClient = SupabaseClient(
    'https://umufrbjwcwrktdmtlrsw.supabase.co',  // Replace with new URL
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtdWZyYmp3Y3dya3RkbXRscnN3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDIzODYwMywiZXhwIjoyMDc5ODE0NjAzfQ.wiP1GFX6qji8rhQkXISw5vfoRxaoQzQEoVBQsPqOARY',  // Replace with new service_role key
  );

  // Public client (for getPublicUrl)
  static final _publicClient = Supabase.instance.client;

  /// Upload image to any bucket + folder
  static Future<String?> uploadImage({
    required File image,
    required String bucket,   // e.g. 'profiles', 'news', 'products'
    required String folder,   // e.g. user.uid or 'posts'
  }) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$folder/$fileName';

      // Upload using admin client (bypasses policies)
      await _adminClient.storage
          .from(bucket)
          .upload(filePath, image, fileOptions: const FileOptions(upsert: true));

      // Get public URL
      final publicUrl = _publicClient.storage.from(bucket).getPublicUrl(filePath);

      print('Uploaded to $bucket → $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  /// Delete image by full URL
  static Future<void> deleteFileByUrl(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      final path = uri.pathSegments.skipWhile((s) => s != 'object').skip(1).join('/');

      // Extract bucket from URL (default to 'profiles')
      final bucket = 'profiles';  // or parse from uri

      await _adminClient.storage.from(bucket).remove([path]);
      print('Deleted: $path from $bucket');
    } catch (e) {
      print('Delete failed: $e');
    }
  }
}