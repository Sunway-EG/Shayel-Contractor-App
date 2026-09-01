class TripModel {
  final int id;
  final String referenceNumber;
  final DateTime startDate;
  final DateTime? endDate;
  final int status;
  final String tripStatusName;
  final int? vehicleTypeId;
  final double? cargoPrice;
  final double? spotPrice;
  final String? companyName;
  final String? fromLocation;
  final String? toLocation;
  final String? vehicleTypeName;

  TripModel({
    required this.id,
    required this.referenceNumber,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.tripStatusName,
    this.vehicleTypeId,
    this.cargoPrice,
    this.spotPrice,
    this.companyName,
    this.fromLocation,
    this.toLocation,
    this.vehicleTypeName,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as int,
      referenceNumber: json['referenceNumber'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      status: json['status'] as int,
      tripStatusName: json['tripStatusName'] as String? ?? '',
      vehicleTypeId: json['vehicleTypeId'] as int?,
      cargoPrice: (json['cargoPrice'] as num?)?.toDouble(),
      spotPrice: (json['spotPrice'] as num?)?.toDouble(),
      companyName: json['companyName'] as String?,
      fromLocation: json['fromLocation'] as String?,
      toLocation: json['toLocation'] as String?,
      vehicleTypeName: json['vehicleTypeName'] as String?,
    );
  }
}
