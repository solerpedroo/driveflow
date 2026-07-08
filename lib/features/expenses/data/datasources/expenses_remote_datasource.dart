import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/expense_entity.dart';
import '../mappers/expenses_mapper.dart';
import '../schema/expenses_schema.dart';

class ExpensesRemoteDataSource {
  ExpensesRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const _receiptsBucket = 'receipts';

  String? get _userId => _client.auth.currentUser?.id;

  String? get currentUserId => _userId;

  Stream<List<Map<String, dynamic>>> watchExpenses() {
    final userId = _userId;
    if (userId == null) return Stream.value(const []);

    return _client
        .from(ExpensesSchema.table)
        .stream(primaryKey: [ExpensesSchema.id])
        .eq(ExpensesSchema.userId, userId)
        .order(ExpensesSchema.date, ascending: false);
  }

  Future<List<Map<String, dynamic>>> fetchExpenses() async {
    final userId = _userId;
    if (userId == null) return const [];

    final rows = await _client
        .from(ExpensesSchema.table)
        .select()
        .eq(ExpensesSchema.userId, userId)
        .order(ExpensesSchema.date, ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<String?> uploadReceipt(File file) async {
    final userId = _userId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    final extension = file.path.split('.').last.toLowerCase();
    final objectPath = '$userId/${DateTime.now().microsecondsSinceEpoch}.$extension';

    try {
      await _client.storage.from(_receiptsBucket).upload(
            objectPath,
            file,
            fileOptions: const FileOptions(upsert: false),
          );

      return await _client.storage
          .from(_receiptsBucket)
          .createSignedUrl(objectPath, 60 * 60 * 24 * 365);
    } on StorageException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }

  Future<Map<String, dynamic>> createExpense({
    required ExpenseDraft draft,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    try {
      return await _client
          .from(ExpensesSchema.table)
          .insert(ExpensesMapper.toInsert(userId: userId, draft: draft))
          .select()
          .single();
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }

  Future<Map<String, dynamic>> updateExpense({
    required String id,
    required ExpenseDraft draft,
  }) async {
    try {
      return await _client
          .from(ExpensesSchema.table)
          .update(ExpensesMapper.toUpdate(draft))
          .eq(ExpensesSchema.id, id)
          .select()
          .single();
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _client.from(ExpensesSchema.table).delete().eq(ExpensesSchema.id, id);
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }

  Future<Map<String, dynamic>?> findByDescriptionContains(String needle) async {
    final userId = _userId;
    if (userId == null) return null;

    final rows = await _client
        .from(ExpensesSchema.table)
        .select()
        .eq(ExpensesSchema.userId, userId)
        .ilike(ExpensesSchema.description, '%$needle%')
        .limit(1);

    if (rows.isEmpty) return null;
    return rows.first as Map<String, dynamic>;
  }

  Future<void> deleteByDescriptionContains(String needle) async {
    final row = await findByDescriptionContains(needle);
    if (row == null) return;
    await deleteExpense(row[ExpensesSchema.id] as String);
  }

  Future<void> updateByDescriptionContains(
    String needle, {
    required Map<String, dynamic> values,
  }) async {
    final row = await findByDescriptionContains(needle);
    if (row == null) return;

    await _client
        .from(ExpensesSchema.table)
        .update(values)
        .eq(ExpensesSchema.id, row[ExpensesSchema.id] as String);
  }
}
