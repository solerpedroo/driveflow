import 'package:url_launcher/url_launcher.dart';

import 'ride_platforms.dart';

/// Deep links para abrir apps de corrida a partir do modo turno.
abstract final class PlatformAppLauncher {
  static Uri? launchUriFor(RidePlatform platform) {
    return switch (platform) {
      RidePlatform.uber => Uri.parse('uber://'),
      RidePlatform.ninetyNine => Uri.parse('ninetyninepassageiro://'),
      RidePlatform.inDrive => Uri.parse('indrive://'),
      _ => null,
    };
  }

  static Future<bool> open(RidePlatform platform) async {
    final uri = launchUriFor(platform);
    if (uri == null) return false;

    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
