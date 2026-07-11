import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/design_system/df_button.dart';
import '../../../../shared/widgets/design_system/df_staggered_entrance.dart';
import '../../../../shared/widgets/design_system/df_text_field.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_benefits_strip.dart';
import '../widgets/auth_hero_layout.dart';

/// Login — tipografia limpa, CTA com profundidade, Google mark oficial.
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({
    super.key,
    this.authRepositoryForTesting,
  });

  final Object? authRepositoryForTesting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(
        theme.brightness == Brightness.dark
            ? AppColors.darkOverlay
            : AppColors.lightOverlay,
      );
      return null;
    }, [theme.brightness]);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final message = error is AuthFailure
            ? error.message
            : AuthFailure.messageForError(error ?? 'Erro desconhecido');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      await ref.read(authControllerProvider.notifier).signInWithEmail(
            email: emailController.text.trim(),
            password: passwordController.text,
          );
    }

    return AuthHeroLayout(
      headline: 'Controle seu\nlucro diário',
      subtitle:
          'Ganhos, despesas e metas em um painel feito para a rotina do motorista.',
      middleChild: const AuthBenefitsStrip(),
      formChild: Form(
        key: formKey,
        child: DfStaggeredEntrance(
          children: [
            DfTextField(
              controller: emailController,
              label: 'E-mail',
              hint: 'seu@email.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.mail_outline_rounded,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.lg),
            DfTextField(
              controller: passwordController,
              label: 'Senha',
              hint: '••••••••',
              obscureText: obscurePassword.value,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline_rounded,
              autofillHints: const [AutofillHints.password],
              validator: Validators.password,
              onFieldSubmitted: (_) => submit(),
              suffixIcon: IconButton(
                icon: AnimatedSwitcher(
                  duration: DriveFlowMotion.fast,
                  child: Icon(
                    obscurePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    key: ValueKey(obscurePassword.value),
                    size: 22,
                  ),
                ),
                onPressed: () =>
                    obscurePassword.value = !obscurePassword.value,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            DfButton(
              label: 'Entrar',
              icon: Icons.login_rounded,
              isLoading: isLoading,
              variant: DfButtonVariant.gradient,
              onPressed: submit,
            ),
            const SizedBox(height: AppSpacing.md),
            DfButton(
              label: 'Continuar com Google',
              isLoading: isLoading,
              leading: const _GoogleMark(),
              variant: DfButtonVariant.outlined,
              onPressed: () => ref
                  .read(authControllerProvider.notifier)
                  .signInWithGoogle(),
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Novo por aqui?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
          TextButton(
            onPressed:
                isLoading ? null : () => context.go(AppRoutes.register),
            child: const Text('Criar conta'),
          ),
        ],
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

/// Marca Google simplificada com cores oficiais (não “G” tipográfico).
class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.4, 1.6, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.2, 1.2, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.4, 0.9, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.3, 1.0, false, paint);

    final bar = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.48,
        size.height * 0.42,
        size.width * 0.42,
        stroke,
      ),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
