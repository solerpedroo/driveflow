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
    'Qual meu melhor horário?',
    'Vale mais Uber ou 99 hoje?',
    'Qual minha taxa média por app?',
    'Qual a previsão de lucro para este mês?',
  ];
}
