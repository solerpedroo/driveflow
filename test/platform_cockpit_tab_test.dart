import 'package:driveflow/features/integrations/domain/entities/platform_cockpit_tab.dart';
import 'package:driveflow/features/integrations/presentation/platform_cockpit_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromQuery resolves cockpit tabs', () {
    expect(PlatformCockpitTab.fromQuery('today'), PlatformCockpitTab.today);
    expect(PlatformCockpitTab.fromQuery('turno'), PlatformCockpitTab.shift);
    expect(PlatformCockpitTab.fromQuery('compare'), PlatformCockpitTab.compare);
    expect(PlatformCockpitTab.fromQuery(null), PlatformCockpitTab.today);
  });

  test('hub route encodes cockpit tab query', () {
    expect(
      PlatformCockpitRoutes.hub(tab: PlatformCockpitTab.shift),
      '/integrations/platforms?cockpit=shift',
    );
  });
}
