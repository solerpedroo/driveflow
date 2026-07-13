import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/quick_earning_storage.dart';
import '../../domain/entities/quick_earning_entry.dart';

final quickEarningHistoryProvider = Provider<List<QuickEarningEntry>>((ref) {
  ref.watch(quickEarningHistoryVersionProvider);
  return QuickEarningStorage.readHistory();
});

final quickEarningHistoryVersionProvider = StateProvider<int>((ref) => 0);
