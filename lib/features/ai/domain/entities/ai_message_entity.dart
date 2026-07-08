/// Mensagem persistida no histórico de IA.
class AiMessageEntity {
  const AiMessageEntity({
    required this.id,
    required this.userId,
    required this.question,
    required this.answer,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String question;
  final String answer;
  final DateTime createdAt;
}

/// Sugestões rápidas exibidas no chat.
abstract final class AiQuickSuggestions {
  static const items = [
    'Quanto lucrei este mês?',
    'Vale abastecer agora?',
    'Como está minha meta diária?',
    'Quais foram meus maiores gastos?',
    'Preciso fazer alguma manutenção?',
  ];
}
