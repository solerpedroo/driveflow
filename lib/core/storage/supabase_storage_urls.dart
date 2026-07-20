import 'package:supabase_flutter/supabase_flutter.dart';

import '../../supabase_dev_setup.dart';

/// Resolve URLs assinadas de curta duração a partir de paths no Storage.
abstract final class SupabaseStorageUrls {
  static const receiptsBucket = 'receipts';
  static const avatarsBucket = 'avatars';
  static const signedUrlTtlSeconds = 60 * 60;

  static bool isRemoteUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  static bool isAllowedRemoteUrl(String value) {
    if (!isRemoteUrl(value)) return false;
    final uri = Uri.tryParse(value);
    if (uri == null) return false;

    final supabaseHost = Uri.tryParse(SupabaseConfig.url)?.host;
    if (supabaseHost == null || uri.host != supabaseHost) return false;

    return uri.path.contains('/storage/v1/object/');
  }

  static Future<String?> resolveReceiptUrl(String? stored) =>
      _resolve(receiptsBucket, stored);

  static Future<String?> resolveAvatarUrl(String? stored) =>
      _resolve(avatarsBucket, stored);

  static Future<String?> _resolve(String bucket, String? stored) async {
    if (stored == null || stored.isEmpty) return null;
    if (isRemoteUrl(stored)) {
      return isAllowedRemoteUrl(stored) ? stored : null;
    }

    try {
      return await Supabase.instance.client.storage
          .from(bucket)
          .createSignedUrl(stored, signedUrlTtlSeconds);
    } on Object {
      return null;
    }
  }
}
