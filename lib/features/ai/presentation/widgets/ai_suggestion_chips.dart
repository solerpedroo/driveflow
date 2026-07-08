import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ai_message_entity.dart';

/// Chips de sugestões rápidas para o chat de IA.
class AiSuggestionChips extends StatelessWidget {
  const AiSuggestionChips({
    required this.onSelected,
    super.key,
  });

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AiQuickSuggestions.items.map((suggestion) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(suggestion),
              backgroundColor: AppColors.electricTeal.withValues(alpha: 0.12),
              side: BorderSide(
                color: AppColors.electricTeal.withValues(alpha: 0.3),
              ),
              onPressed: () => onSelected(suggestion),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}
