import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/core/deep_links/app_deep_link_action.dart';
import 'package:driveflow/core/deep_links/app_deep_link_parser.dart';

void main() {
  test('parses shift start deep link', () {
    final intent = AppDeepLinkParser.parse(
      Uri.parse('driveflow://shift/start'),
    );

    expect(intent, isNotNull);
    expect(intent!.action, AppDeepLinkAction.shiftStart);
  });

  test('parses quick earning and platform open links', () {
    final earning = AppDeepLinkParser.parse(
      Uri.parse('driveflow://earning/quick'),
    );
    expect(earning?.action, AppDeepLinkAction.quickEarning);

    final platform = AppDeepLinkParser.parse(
      Uri.parse('driveflow://platform/open?app=uber'),
    );
    expect(platform?.action, AppDeepLinkAction.openPlatform);
    expect(platform?.platform, RidePlatform.uber);
  });

  test('ignores non-driveflow schemes', () {
    expect(
      AppDeepLinkParser.parse(Uri.parse('https://example.com')),
      isNull,
    );
  });
}
