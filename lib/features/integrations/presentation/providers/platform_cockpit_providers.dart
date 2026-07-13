import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/platform_cockpit_tab.dart';

/// Aba ativa do cockpit multi-app.
final platformCockpitTabProvider =
    StateProvider<PlatformCockpitTab>((ref) => PlatformCockpitTab.today);
