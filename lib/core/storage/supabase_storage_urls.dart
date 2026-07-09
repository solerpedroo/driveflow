import 'package:supabase_flutter/supabase_flutter.dart';

/// Resolve URLs assinadas de curta duração a partir de paths no Storage.
abstract final class SupabaseStorageUrls {
  static const receiptsBucket = 'receipts';
  static const avatarsBucket = 'avatars';
  static const signedUrlTtlSeconds = 60 * 60;

  static bool isRemoteUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  static Future<String?> resolveReceiptUrl(String? stored) =>
      _resolve(receiptsBucket, stored);

  static Future<String?> resolveAvatarUrl(String? stored) =>
      _resolve(avatarsBucket, stored);

  static Future<String?> _resolve(String bucket, String? stored) async {
    if (stored == null || stored.isEmpty) return null;
    if (isRemoteUrl(stored)) return stored;

    try {
      return await Supabase.instance.client.storage
          .from(bucket)
          .createSignedUrl(stored, signedUrlTtlSeconds);
    } on Object {
      return null;
    }
  }
}
