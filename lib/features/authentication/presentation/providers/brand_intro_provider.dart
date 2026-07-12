import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Libera o redirect do splash após a intro de marca (minHold).
final brandIntroCompleteProvider = StateProvider<bool>((ref) => false);
