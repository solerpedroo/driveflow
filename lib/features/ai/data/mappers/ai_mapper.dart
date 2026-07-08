import '../../domain/entities/ai_message_entity.dart';
import '../schema/ai_history_schema.dart';

abstract final class AiMapper {
  static AiMessageEntity fromRow(Map<String, dynamic> row) {
    return AiMessageEntity(
      id: row[AiHistorySchema.id] as String,
      userId: row[AiHistorySchema.userId] as String,
      question: row[AiHistorySchema.question] as String,
      answer: row[AiHistorySchema.answer] as String,
      createdAt: _toDateTime(row[AiHistorySchema.createdAt]) ?? DateTime.now(),
    );
  }

  static DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}
