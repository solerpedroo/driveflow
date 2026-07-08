abstract final class AiHistorySchema {
  static const table = 'ai_history';

  static const id = 'id';
  static const userId = 'user_id';
  static const question = 'question';
  static const answer = 'answer';
  static const createdAt = 'created_at';
  static const type = 'type';
}

abstract final class AiFunctions {
  static const aiChat = 'ai-chat';
  static const aiForecast = 'ai-forecast';
}
