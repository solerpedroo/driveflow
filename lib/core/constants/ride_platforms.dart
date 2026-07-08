/// Plataformas de transporte suportadas para registro de ganhos.
enum RidePlatform {
  uber('uber', 'Uber'),
  ninetyNine('99', '99'),
  inDrive('indrive', 'InDrive'),
  privateRide('private', 'Particular'),
  other('other', 'Outro');

  const RidePlatform(this.value, this.label);

  final String value;
  final String label;

  static RidePlatform fromValue(String value) {
    return RidePlatform.values.firstWhere(
      (p) => p.value == value,
      orElse: () => RidePlatform.other,
    );
  }
}

const kRidePlatforms = RidePlatform.values;
