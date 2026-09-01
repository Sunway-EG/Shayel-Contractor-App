import 'package:equatable/equatable.dart';

class Trip extends Equatable {
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
  final Driver? driver;
  final Contract? contract;
  final ContractVehicleType? contractVehicleType;
  final ContractDestination? contractDestination;
  final Company? company;
  final Contractor? contractor;
  final List<Waypoint>? waypoints;

  const Trip({
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

class Driver extends Equatable {
  final int? id;
  final String? fullName;
  final String? fullNameAr;
  final String? fullNameEn;
  final String? phone;
  final String? email;
  final String? nationalId;

  const Driver({
    this.id,
    this.fullName,
    this.fullNameAr,
    this.fullNameEn,
    this.phone,
    this.email,
    this.nationalId,
  });

  @override
  List<Object?> get props {
    return [id, fullName, fullNameAr, fullNameEn, phone, email, nationalId];
  }
}

class Contract extends Equatable {
  final int? id;
  final String? referenceNumber;
  final String? nameEn;
  final String? nameAr;
  final int? contractType;
  final String? contractTypeName;
  final int? consumptionType;
  final Company? company;

  const Contract({
    this.id,
    this.referenceNumber,
    this.nameEn,
    this.nameAr,
    this.contractType,
    this.contractTypeName,
    this.consumptionType,
    this.company,
  });

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

class ContractVehicleType extends Equatable {
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
  final VehicleType? vehicleType;

  const ContractVehicleType({
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

class VehicleType extends Equatable {
  final int? id;
  final String? name;
  final String? nameEn;
  final String? nameAr;
  final int? category;
  final int? vehicleUnitType;

  const VehicleType({
    this.id,
    this.name,
    this.nameEn,
    this.nameAr,
    this.category,
    this.vehicleUnitType,
  });


  @override
  List<Object?> get props {
    return [id, name, nameEn, nameAr, category, vehicleUnitType];
  }
}

class ContractDestination extends Equatable {
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

  const ContractDestination({
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

class Company extends Equatable {
  final int? id;
  final String? nameEn;
  final String? nameAr;
  final String? phone;
  final String? email;
  final String? registrationNumber;
  final String? fullName;

  const Company({
    this.id,
    this.nameEn,
    this.nameAr,
    this.phone,
    this.email,
    this.registrationNumber,
    this.fullName,
  });

  @override
  List<Object?> get props {
    return [id, nameEn, nameAr, phone, email, registrationNumber, fullName];
  }
}

class Contractor extends Equatable {
  final int? id;
  final String? fullName;
  final String? userName;
  final String? email;
  final String? phone;

  const Contractor({
    this.id,
    this.fullName,
    this.userName,
    this.email,
    this.phone,
  });


  @override
  List<Object?> get props => [id, fullName, userName, email, phone];
}
class Waypoint extends Equatable {
  final int? id;
  final int? sequence;
  final int? stopType;
  final int? status;
  final double? latitude;
  final double? longitude;
  final String? addressName;
  final String? googlePlaceId;
  final dynamic taskDetails;

  const Waypoint({
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