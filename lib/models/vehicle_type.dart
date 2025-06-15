enum VehicleType {
  car('Car'),
  motorbike('Motorbike');

  final String value;
  const VehicleType(this.value);

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (type) => type.value.toLowerCase() == value.toLowerCase(),
      orElse: () => VehicleType.car,
    );
  }
} 