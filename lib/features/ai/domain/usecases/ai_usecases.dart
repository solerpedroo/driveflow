import '../entities/ai_message_entity.dart';
import '../repositories/ai_repository.dart';

class WatchAiHistory {
  const WatchAiHistory(this._repository);

  final AiRepository _repository;

  Stream<List<AiMessageEntity>> call() => _repository.watchHistory();
}

class AskAiAssistant {
  const AskAiAssistant(this._repository);

  final AiRepository _repository;

  Future<AiMessageEntity> call(String question) => _repository.ask(question);
}
