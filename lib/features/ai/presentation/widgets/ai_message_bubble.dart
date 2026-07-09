import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// Bolha premium com glass depth para chat IA.
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
    final isDark = theme.brightness == Brightness.dark;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.skyBlue.withValues(alpha: 0.25),
                    AppColors.skyBlue.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: AppRadius.mdAll,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: AppColors.skyBlue,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 6),
                    bottomRight: Radius.circular(isUser ? 6 : 18),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.skyBlue.withValues(alpha: 0.22)
                            : (isDark
                                ? AppColors.slate.withValues(alpha: 0.55)
                                : Colors.white.withValues(alpha: 0.75)),
                        border: Border.all(
                          color: isUser
                              ? AppColors.skyBlue.withValues(alpha: 0.35)
                              : AppColors.glassBorderLight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        child: Text(
                          text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                  ),
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
