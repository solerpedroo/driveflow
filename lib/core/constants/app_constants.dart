import 'package:flutter/material.dart';

/// Categorias de despesa do motorista.
enum ExpenseCategory {
  fuel('fuel', 'Combustível', Icons.local_gas_station_rounded),
  toll('toll', 'Pedágio', Icons.toll_rounded),
  food('food', 'Alimentação', Icons.restaurant_rounded),
  wash('wash', 'Lavagem', Icons.local_car_wash_rounded),
  mechanic('mechanic', 'Mecânico', Icons.build_circle_rounded),
  parking('parking', 'Estacionamento', Icons.local_parking_rounded),
  fine('fine', 'Multas', Icons.gavel_rounded),
  insurance('insurance', 'Seguro', Icons.shield_rounded),
  ipva('ipva', 'IPVA', Icons.receipt_long_rounded),
  other('other', 'Outros', Icons.more_horiz_rounded);

  const ExpenseCategory(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  static ExpenseCategory fromValue(String value) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}

const kExpenseCategories = ExpenseCategory.values;

/// Tipos de combustível para veículo/abastecimento.
enum FuelType {
  gasoline('gasoline', 'Gasolina'),
  ethanol('ethanol', 'Etanol'),
  flex('flex', 'Flex'),
  diesel('diesel', 'Diesel'),
  gnv('gnv', 'GNV');

  const FuelType(this.value, this.label);

  final String value;
  final String label;
}

const kFuelTypes = FuelType.values;

/// Tipos de manutenção veicular.
enum MaintenanceType {
  oil('oil', 'Óleo', Icons.opacity_rounded),
  tires('tires', 'Pneus', Icons.tire_repair_rounded),
  revision('revision', 'Revisão', Icons.fact_check_outlined),
  filters('filters', 'Filtros', Icons.air_rounded),
  alignment('alignment', 'Alinhamento', Icons.straighten_rounded),
  battery('battery', 'Bateria', Icons.battery_charging_full_rounded),
  brakes('brakes', 'Freios', Icons.stop_circle_outlined);

  const MaintenanceType(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}

const kMaintenanceTypes = MaintenanceType.values;

/// Chaves de rotas GoRouter.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const vehicleOnboarding = '/onboarding/vehicle';
  static const addVehicle = '/vehicle/add';
  static const editVehicle = '/vehicle/edit';
  static const earningForm = '/earnings/form';
  static const expenseForm = '/expenses/form';
  static const fuelLog = '/fuel/log';
  static const fuelHistory = '/fuel/history';
  static const maintenanceForm = '/maintenance/form';
  static const maintenanceHistory = '/maintenance/history';
  static const goals = '/goals';
  static const analytics = '/analytics';
  static const aiChat = '/ai/chat';
}

/// Onda atual concluída (v1.5 — gráficos avançados e comparação).
const kCurrentWave = 12;

/// Deep link OAuth Supabase (Google).
const kOAuthRedirectUrl = 'io.supabase.driveflow://login-callback/';

/// Nome do app e versão foundation.
const kAppName = 'DriveFlow';
const kAppTagline = 'Lucro claro. Decisão inteligente.';
const kFoundationWave = 0;
