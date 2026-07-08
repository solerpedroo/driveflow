import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/main_shell_screen.dart';
import '../../features/earnings/domain/entities/earning_entity.dart';
import '../../features/earnings/presentation/screens/earning_form_screen.dart';
import '../../features/expenses/domain/entities/expense_entity.dart';
import '../../features/expenses/presentation/screens/expense_form_screen.dart';
import '../../features/fuel/domain/entities/fuel_log_entity.dart';
import '../../features/fuel/presentation/screens/fuel_history_screen.dart';
import '../../features/fuel/presentation/screens/fuel_log_screen.dart';
import '../../features/ai/presentation/screens/ai_chat_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/maintenance/domain/entities/maintenance_entity.dart';
import '../../features/maintenance/presentation/screens/maintenance_form_screen.dart';
import '../../features/maintenance/presentation/screens/maintenance_history_screen.dart';
import '../../features/vehicle/presentation/providers/vehicle_providers.dart';
import '../../features/vehicle/presentation/screens/vehicle_onboarding_screen.dart';

/// Notifica GoRouter quando auth ou veículos mudam.
class AppRouterRefresh extends ChangeNotifier {
  AppRouterRefresh(this._ref) {
    _authSub = _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _vehicleSub =
        _ref.listen(vehiclesStreamProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<dynamic>> _authSub;
  late final ProviderSubscription<AsyncValue<dynamic>> _vehicleSub;

  @override
  void dispose() {
    _authSub.close();
    _vehicleSub.close();
    super.dispose();
  }
}

CustomTransitionPage<void> _fadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(opacity: curved, child: child);
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = AppRouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      final vehiclesAsync = ref.read(vehiclesStreamProvider);
      final location = state.matchedLocation;

      final isSplash = location == AppRoutes.splash;
      final isLogin = location == AppRoutes.login;
      final isRegister = location == AppRoutes.register;
      final isAuthRoute = isLogin || isRegister;
      final isOnboarding = location == AppRoutes.vehicleOnboarding;
      final isEditVehicle = location == AppRoutes.editVehicle;

      if (authAsync.isLoading) {
        return isSplash ? null : AppRoutes.splash;
      }

      final user = authAsync.valueOrNull;
      if (user == null) {
        if (isAuthRoute) return null;
        return AppRoutes.login;
      }

      if (vehiclesAsync.isLoading) {
        return isSplash ? null : AppRoutes.splash;
      }

      final hasVehicle = vehiclesAsync.valueOrNull?.isNotEmpty ?? false;

      if (isAuthRoute || isSplash) {
        return hasVehicle ? AppRoutes.home : AppRoutes.vehicleOnboarding;
      }

      if (!hasVehicle && !isOnboarding) {
        return AppRoutes.vehicleOnboarding;
      }

      if (hasVehicle && isOnboarding) {
        return AppRoutes.home;
      }

      if (!hasVehicle && isEditVehicle) {
        return AppRoutes.vehicleOnboarding;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.vehicleOnboarding,
        name: 'vehicleOnboarding',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const VehicleOnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const MainShellScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editVehicle,
        name: 'editVehicle',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const EditVehicleScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.earningForm,
        name: 'earningForm',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: EarningFormScreen(
            earning: state.extra as EarningEntity?,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.expenseForm,
        name: 'expenseForm',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: ExpenseFormScreen(
            expense: state.extra as ExpenseEntity?,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.fuelLog,
        name: 'fuelLog',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: FuelLogScreen(
            fuelLog: state.extra as FuelLogEntity?,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.fuelHistory,
        name: 'fuelHistory',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const FuelHistoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.maintenanceForm,
        name: 'maintenanceForm',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: MaintenanceFormScreen(
            record: state.extra as MaintenanceEntity?,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.maintenanceHistory,
        name: 'maintenanceHistory',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const MaintenanceHistoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.goals,
        name: 'goals',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const GoalsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiChat,
        name: 'aiChat',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const AiChatScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Rota não encontrada: ${state.uri}'),
      ),
    ),
  );
});
