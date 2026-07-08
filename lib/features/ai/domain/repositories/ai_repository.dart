import '../entities/ai_message_entity.dart';
import '../entities/ai_forecast_message.dart';

abstract interface class AiRepository {
  Stream<List<AiMessageEntity>> watchHistory();

  Future<AiMessageEntity> ask(String question);

  Future<AiForecastMessage> forecast();
}
