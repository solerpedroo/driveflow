import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/driver_type.dart';
import 'package:driveflow/features/onboarding/domain/onboarding_catalog.dart';

void main() {
  group('OnboardingCatalog', () {
    test('ride share slides mention integrations', () {
      final slides = OnboardingCatalog.slidesFor(DriverType.rideShare);

      expect(slides, hasLength(4));
      expect(
        slides.any((s) => s.title.toLowerCase().contains('conecte')),
        isTrue,
      );
    });

    test('taxi slides focus on manual workflow', () {
      final slides = OnboardingCatalog.slidesFor(DriverType.taxi);

      expect(slides, hasLength(4));
      expect(slides.first.title, 'Feito para o taxista');
      expect(
        slides.any((s) => s.body.toLowerCase().contains('manual')),
        isTrue,
      );
    });
  });
}
