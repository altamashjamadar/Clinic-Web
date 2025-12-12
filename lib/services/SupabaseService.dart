import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final _adminClient = SupabaseClient(
    'https://umufrbjwcwrktdmtlrsw.supabase.co',  
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtdWZyYmp3Y3dya3RkbXRscnN3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDIzODYwMywiZXhwIjoyMDc5ODE0NjAzfQ.wiP1GFX6qji8rhQkXISw5vfoRxaoQzQEoVBQsPqOARY',  // Replace with new service_role key
  );

  static final _publicClient = Supabase.instance.client;

  static Future<String?> uploadImage({
    required File image,
    required String bucket,   
    required String folder,   
  }) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$folder/$fileName';

      await _adminClient.storage
          .from(bucket)
          .upload(filePath, image, fileOptions: const FileOptions(upsert: true));

      final publicUrl = _publicClient.storage.from(bucket).getPublicUrl(filePath);

      print('Uploaded to $bucket → $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  static Future<void> deleteFileByUrl(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      final path = uri.pathSegments.skipWhile((s) => s != 'object').skip(1).join('/');

      final bucket = 'profiles';  

      await _adminClient.storage.from(bucket).remove([path]);
      print('Deleted: $path from $bucket');
    } catch (e) {
      print('Delete failed: $e');
    }
  }
}