import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/design_system/df_skeleton.dart';
import '../../../../shared/widgets/design_system/df_subpage_scaffold.dart';
import '../providers/ai_providers.dart';
import '../widgets/ai_chat_composer.dart';
import '../widgets/ai_chat_story_hero.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/ai_suggestion_chips.dart';

/// Chat contextual com assistente DriveFlow — DfSubpageScaffold + composer fixo.
class AiChatScreen extends HookConsumerWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(aiHistoryStreamProvider);
    final mutation = ref.watch(aiChatControllerProvider);
    final controller = useTextEditingController();
    final scrollController = useScrollController();

    Future<void> submit([String? text]) async {
      final question = (text ?? controller.text).trim();
      if (question.isEmpty || mutation.isLoading) return;

      controller.clear();
      FocusScope.of(context).unfocus();

      final saved = await ref.read(aiChatControllerProvider.notifier).ask(question);
      if (saved == null && context.mounted) {
        final error = ref.read(aiChatControllerProvider).error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        }
      }
      if (scrollController.hasClients) {
        await scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }

    return DfSubpageScaffold(
      title: 'Assistente DriveFlow',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: AiSuggestionChips(onSelected: submit),
          ),
          Expanded(
            child: historyAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: DfSkeleton(itemCount: 3),
              ),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (history) {
                if (history.isEmpty && !mutation.isLoading) {
                  return const AiChatStoryHero();
                }

                return ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: history.length + (mutation.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (mutation.isLoading && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Analisando seus dados...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondaryLabel(theme),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final itemIndex = mutation.isLoading ? index - 1 : index;
                    final message = history[itemIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AiMessageBubble(text: message.question, isUser: true),
                        AiMessageBubble(text: message.answer, isUser: false),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          AiChatComposer(
            controller: controller,
            isLoading: mutation.isLoading,
            onSubmit: () => submit(),
          ),
        ],
      ),
    );
  }
}
