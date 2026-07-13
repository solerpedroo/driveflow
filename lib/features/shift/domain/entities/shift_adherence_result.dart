/// Resultado da análise de aderência ao plano de turno.
class ShiftAdherenceResult {
  const ShiftAdherenceResult({
    required this.score,
    required this.matchedBlocks,
    required this.totalBlocks,
  });

  final double score;
  final int matchedBlocks;
  final int totalBlocks;

  static const perfect = ShiftAdherenceResult(
    score: 100,
    matchedBlocks: 0,
    totalBlocks: 0,
  );
}
