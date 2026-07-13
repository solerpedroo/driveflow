import 'package:driveflow/core/constants/app_constants.dart';
import 'package:driveflow/features/integrations/domain/entities/platform_cockpit_tab.dart';

/// Rotas do cockpit multi-app.
abstract final class PlatformCockpitRoutes {
  static String hub({PlatformCockpitTab tab = PlatformCockpitTab.today}) =>
      '${AppRoutes.platformIntegrations}?cockpit=${tab.queryParam}';
}
