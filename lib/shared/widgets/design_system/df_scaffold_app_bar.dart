import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// AppBar compartilhado — gradiente transparente, título e voltar unificados.
class DfScaffoldAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DfScaffoldAppBar({
    required this.title,
    super.key,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: leading ??
          (automaticallyImplyLeading && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                )
              : null),
      title: Text(
        title,
        style: AppTypography.iosHeadline(brightness).copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      actions: actions,
    );
  }
}
