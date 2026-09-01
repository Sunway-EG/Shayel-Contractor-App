import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trip_dto.g.dart';

@JsonSerializable()
class TripDto extends Equatable {
  final int? id;
  final String? referenceNumber;
  final int? contractId;
  final int? contractDestinationId;
  final int? contractVehicleTypeId;
  final int? vehicleTypeId;
  final int? vehicleId;
  final int? driverId;
  final String? startDate;
  final String? endDate;
  final int? status;
  final String? tripStatusName;
  final int? currentDriverStatus;
  final String? currentDriverStatusName;
  final int? tripDocumentStatus;
  final String? tripDocumentStatusName;
  final int? contractDistanceKm;
  final double? actualDistanceKm;
  final double? actualCargoWeightTons;
  final double? cargoPrice;
  final double? spotPrice;
  final int? numberOfDays;
  final double? totalAddonsCost;
  final double? totalTripCost;
  final double? tripCostWithoutAddon;
  final bool? isExtraTrip;
  final bool? isDailyExtraTrip;
  final String? contactPersonName;
  final String? contactPersonMobile;
  final int? helpersCount;
  final int? cutoffDuration;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DriverDto? driver;
  final ContractDto? contract;
  final ContractVehicleTypeDto? contractVehicleType;
  final ContractDestinationDto? contractDestination;
  final CompanyDto? company;
  final ContractorDto? contractor;
  final List<WaypointDto>? waypoints;

  const TripDto({
    this.id,
    this.referenceNumber,
    this.contractId,
    this.contractDestinationId,
    this.contractVehicleTypeId,
    this.vehicleTypeId,
    this.vehicleId,
    this.driverId,
    this.startDate,
    this.endDate,
    this.status,
    this.tripStatusName,
    this.currentDriverStatus,
    this.currentDriverStatusName,
    this.tripDocumentStatus,
    this.tripDocumentStatusName,
    this.contractDistanceKm,
    this.actualDistanceKm,
    this.actualCargoWeightTons,
    this.cargoPrice,
    this.spotPrice,
    this.numberOfDays,
    this.totalAddonsCost,
    this.totalTripCost,
    this.tripCostWithoutAddon,
    this.isExtraTrip,
    this.isDailyExtraTrip,
    this.contactPersonName,
    this.contactPersonMobile,
    this.helpersCount,
    this.cutoffDuration,
    this.createdAt,
    this.updatedAt,
    this.driver,
    this.contract,
    this.contractVehicleType,
    this.contractDestination,
    this.company,
    this.contractor,
    this.waypoints,
  });

  factory TripDto.fromJson(Map<String, dynamic> json) => _$TripDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TripDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      referenceNumber,
      contractId,
      contractDestinationId,
      contractVehicleTypeId,
      vehicleTypeId,
      vehicleId,
      driverId,
      startDate,
      endDate,
      status,
      tripStatusName,
      currentDriverStatus,
      currentDriverStatusName,
      tripDocumentStatus,
      tripDocumentStatusName,
      contractDistanceKm,
      actualDistanceKm,
      actualCargoWeightTons,
      cargoPrice,
      spotPrice,
      numberOfDays,
      totalAddonsCost,
      totalTripCost,
      tripCostWithoutAddon,
      isExtraTrip,
      isDailyExtraTrip,
      contactPersonName,
      contactPersonMobile,
      helpersCount,
      cutoffDuration,
      createdAt,
      updatedAt,
      driver,
      contract,
      contractVehicleType,
      contractDestination,
      company,
      contractor,
      waypoints,
    ];
  }
}

@JsonSerializable()
class DriverDto extends Equatable {
  final int? id;
  final String? fullName;
  final String? fullNameAr;
  final String? fullNameEn;
  final String? phone;
  final String? email;
  final String? nationalId;

  const DriverDto({
    this.id,
    this.fullName,
    this.fullNameAr,
    this.fullNameEn,
    this.phone,
    this.email,
    this.nationalId,
  });

  factory DriverDto.fromJson(Map<String, dynamic> json) => _$DriverDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverDtoToJson(this);

  @override
  List<Object?> get props {
    return [id, fullName, fullNameAr, fullNameEn, phone, email, nationalId];
  }
}

@JsonSerializable()
class ContractDto extends Equatable {
  final int? id;
  final String? referenceNumber;
  final String? nameEn;
  final String? nameAr;
  final int? contractType;
  final String? contractTypeName;
  final int? consumptionType;
  final CompanyDto? company;

  const ContractDto({
    this.id,
    this.referenceNumber,
    this.nameEn,
    this.nameAr,
    this.contractType,
    this.contractTypeName,
    this.consumptionType,
    this.company,
  });

  factory ContractDto.fromJson(Map<String, dynamic> json) => _$ContractDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ContractDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      referenceNumber,
      nameEn,
      nameAr,
      contractType,
      contractTypeName,
      consumptionType,
      company,
    ];
  }
}

@JsonSerializable()
class ContractVehicleTypeDto extends Equatable {
  final int? id;
  final int? contractId;
  final int? vehicleTypeId;
  final dynamic consumptionRate;
  final dynamic tripsPerMonth;
  final dynamic tripsPerDay;
  final int? maxKms;
  final int? monthlyRental;
  final double? dailyValue;
  final int? overConsumption;
  final int? quantity;
  final dynamic minBillableWeightTons;
  final dynamic maxPayloadTons;
  final dynamic overWeightPricePerTon;
  final int? extraWorkingDayFees;
  final int? addedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VehicleTypeDto? vehicleType;

  const ContractVehicleTypeDto({
    this.id,
    this.contractId,
    this.vehicleTypeId,
    this.consumptionRate,
    this.tripsPerMonth,
    this.tripsPerDay,
    this.maxKms,
    this.monthlyRental,
    this.dailyValue,
    this.overConsumption,
    this.quantity,
    this.minBillableWeightTons,
    this.maxPayloadTons,
    this.overWeightPricePerTon,
    this.extraWorkingDayFees,
    this.addedBy,
    this.createdAt,
    this.updatedAt,
    this.vehicleType,
  });

  factory ContractVehicleTypeDto.fromJson(Map<String, dynamic> json) => _$ContractVehicleTypeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ContractVehicleTypeDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      contractId,
      vehicleTypeId,
      consumptionRate,
      tripsPerMonth,
      tripsPerDay,
      maxKms,
      monthlyRental,
      dailyValue,
      overConsumption,
      quantity,
      minBillableWeightTons,
      maxPayloadTons,
      overWeightPricePerTon,
      extraWorkingDayFees,
      addedBy,
      createdAt,
      updatedAt,
      vehicleType,
    ];
  }
}

@JsonSerializable()
class VehicleTypeDto extends Equatable {
  final int? id;
  final String? name;
  final String? nameEn;
  final String? nameAr;
  final int? category;
  final int? vehicleUnitType;

  const VehicleTypeDto({
    this.id,
    this.name,
    this.nameEn,
    this.nameAr,
    this.category,
    this.vehicleUnitType,
  });

  factory VehicleTypeDto.fromJson(Map<String, dynamic> json) => _$VehicleTypeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleTypeDtoToJson(this);

  @override
  List<Object?> get props {
    return [id, name, nameEn, nameAr, category, vehicleUnitType];
  }
}

@JsonSerializable()
class ContractDestinationDto extends Equatable {
  final int? id;
  final dynamic start;
  final dynamic end;
  final String? nameAr;
  final String? nameEn;
  final int? expectedKms;
  final int? numberOfDays;
  final dynamic pricePerTon;
  final dynamic fixedTripPrice;
  final dynamic description;
  final int? status;
  final String? statusName;

  const ContractDestinationDto({
    this.id,
    this.start,
    this.end,
    this.nameAr,
    this.nameEn,
    this.expectedKms,
    this.numberOfDays,
    this.pricePerTon,
    this.fixedTripPrice,
    this.description,
    this.status,
    this.statusName,
  });

  factory ContractDestinationDto.fromJson(Map<String, dynamic> json) => _$ContractDestinationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ContractDestinationDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      start,
      end,
      nameAr,
      nameEn,
      expectedKms,
      numberOfDays,
      pricePerTon,
      fixedTripPrice,
      description,
      status,
      statusName,
    ];
  }
}

@JsonSerializable()
class CompanyDto extends Equatable {
  final int? id;
  final String? nameEn;
  final String? nameAr;
  final String? phone;
  final String? email;
  final String? registrationNumber;
  final String? fullName;

  const CompanyDto({
    this.id,
    this.nameEn,
    this.nameAr,
    this.phone,
    this.email,
    this.registrationNumber,
    this.fullName,
  });

  factory CompanyDto.fromJson(Map<String, dynamic> json) => _$CompanyDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyDtoToJson(this);

  @override
  List<Object?> get props {
    return [id, nameEn, nameAr, phone, email, registrationNumber, fullName];
  }
}

@JsonSerializable()
class ContractorDto extends Equatable {
  final int? id;
  final String? fullName;
  final String? userName;
  final String? email;
  final String? phone;

  const ContractorDto({
    this.id,
    this.fullName,
    this.userName,
    this.email,
    this.phone,
  });

  factory ContractorDto.fromJson(Map<String, dynamic> json) => _$ContractorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ContractorDtoToJson(this);

  @override
  List<Object?> get props => [id, fullName, userName, email, phone];
}

@JsonSerializable()
class WaypointDto extends Equatable {
  final int? id;
  final int? sequence;
  final int? stopType;
  final int? status;
  final double? latitude;
  final double? longitude;
  final String? addressName;
  final String? googlePlaceId;
  final dynamic taskDetails;

  const WaypointDto({
    this.id,
    this.sequence,
    this.stopType,
    this.status,
    this.latitude,
    this.longitude,
    this.addressName,
    this.googlePlaceId,
    this.taskDetails,
  });

  factory WaypointDto.fromJson(Map<String, dynamic> json) => _$WaypointDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WaypointDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      sequence,
      stopType,
      status,
      latitude,
      longitude,
      addressName,
      googlePlaceId,
      taskDetails,
    ];
  }
}

@JsonSerializable()
class TripsListResponseDto {
  const TripsListResponseDto({
    required this.trips,
    this.total,
    this.page,
    this.limit,
  });

  final List<TripDto> trips;
  final int? total;
  final int? page;
  final int? limit;

  factory TripsListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TripsListResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TripsListResponseDtoToJson(this);
}