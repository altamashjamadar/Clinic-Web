// // lib/services/supabase_service.dart
// import 'dart:io';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SupabaseService {
//   // Use the client initialized in your app (in main.dart)
//   static final _client = Supabase.instance.client;

//   /// Uploads [image] to `bucket/folder` and returns a public URL (cache buster).
//   /// NOTE: bucket must be PUBLIC for the returned URL to be accessible from mobile.
//   static Future<String?> uploadImage({
    
//     required File image,
//     required String bucket,
//     required String folder,
//   }) async {
//     print('Uploading to Supabase: bucket=$bucket, folder=$folder');
//     try {
//       print('Uploading file: ${image.path}');
//       final fileExt = image.path.split('.').last;
//       final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
//       final filePath = '$folder/$fileName';

//       await _client.storage.from(bucket).upload(filePath, image, fileOptions: const FileOptions(upsert: true));

//       // getPublicUrl returns a String in current SDKs
//       final publicUrl = _client.storage.from(bucket).getPublicUrl(filePath);
//       final url = (publicUrl is String ? publicUrl : publicUrl.toString());
//       return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
//     } catch (e) {
      
//       print('Supabase upload failed: $e');
//       return null;
//     }

//   }

//   /// Remove a file by storage path (not by full HTTP URL).
//   /// Use remove(['folder/filename.jpg'])
//   static Future<bool> removeFile({required String bucket, required String path}) async {
//     try {
      
//       final response = await _client.storage.from(bucket).remove([path]);
//       // some SDK versions return null on success; treat as success
//       return true;
//     } catch (e) {
//       print('Supabase remove failed: $e');
//       return false;
//     }
//   }
// }

// class StorageError {
// }
