import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Bolha de mensagem do chat de IA.
class AiMessageBubble extends StatelessWidget {
  const AiMessageBubble({
    required this.text,
    required this.isUser,
    super.key,
  });

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isUser
        ? AppColors.electricTeal.withValues(alpha: 0.18)
        : AppColors.mutedSurface(theme);
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.electricTeal.withValues(alpha: 0.2),
              child: const Icon(Icons.auto_awesome, size: 16,
                  color: AppColors.electricTeal),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isUser
                          ? AppColors.electricTeal.withValues(alpha: 0.35)
                          : AppColors.glassBorderLight,
                    ),
                  ),
                  child: Text(text, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
