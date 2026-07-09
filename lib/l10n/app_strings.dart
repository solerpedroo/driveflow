/// Acesso leve às strings localizadas (prep i18n — pt-BR).
abstract final class AppStrings {
  static const appName = 'DriveFlow';
  static const appTagline = 'Lucro claro. Decisão inteligente.';
  static const earningsTitle = 'Ganhos';
  static const expensesTitle = 'Despesas';
  static const reportsTitle = 'Relatórios';
  static const analyticsTitle = 'Análises';
  static const insightsTitle = 'Insights';
  static const importStatementTitle = 'Importar extrato';
  static const emptyEarnings = 'Nenhum ganho neste período';
  static const emptyExpenses = 'Nenhuma despesa neste período';
  static const errorGeneric = 'Algo deu errado. Tente novamente.';
  static const sessionExpired = 'Sessão expirada. Entre novamente.';
  static const cancel = 'Cancelar';
  static const save = 'Salvar';
  static const delete = 'Excluir';

  static String dashboardGreeting(String name) => 'Olá, $name!';
}
