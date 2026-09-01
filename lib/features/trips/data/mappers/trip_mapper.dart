import '../../domain/entities/trip/trip.dart';
import '../models/trip_dto.dart';

extension TripDtoMapper on TripDto {
  Trip toEntity() {
    return Trip(
      id: id,
      referenceNumber: referenceNumber,
      contractId: contractId,
      contractDestinationId: contractDestinationId,
      contractVehicleTypeId: contractVehicleTypeId,
      vehicleTypeId: vehicleTypeId,
      vehicleId: vehicleId,
      driverId: driverId,
      startDate: startDate,
      endDate: endDate,
      status: status,
      tripStatusName: tripStatusName,
      currentDriverStatus: currentDriverStatus,
      currentDriverStatusName: currentDriverStatusName,
      tripDocumentStatus: tripDocumentStatus,
      tripDocumentStatusName: tripDocumentStatusName,
      contractDistanceKm: contractDistanceKm,
      actualDistanceKm: actualDistanceKm,
      actualCargoWeightTons: actualCargoWeightTons,
      cargoPrice: cargoPrice,
      spotPrice: spotPrice,
      numberOfDays: numberOfDays,
      totalAddonsCost: totalAddonsCost,
      totalTripCost: totalTripCost,
      tripCostWithoutAddon: tripCostWithoutAddon,
      isExtraTrip: isExtraTrip,
      isDailyExtraTrip: isDailyExtraTrip,
      contactPersonName: contactPersonName,
      contactPersonMobile: contactPersonMobile,
      helpersCount: helpersCount,
      cutoffDuration: cutoffDuration,
      createdAt: createdAt,
      updatedAt: updatedAt,
      driver: driver?.toEntity(),
      contract: contract?.toEntity(),
      contractVehicleType: contractVehicleType?.toEntity(),
      contractDestination: contractDestination?.toEntity(),
      company: company?.toEntity(),
      contractor: contractor?.toEntity(),
      waypoints: waypoints?.map((w) => w.toEntity()).toList(),
    );
  }
}

extension DriverDtoMapper on DriverDto {
  Driver toEntity() {
    return Driver(
      id: id,
      fullName: fullName,
      fullNameAr: fullNameAr,
      fullNameEn: fullNameEn,
      phone: phone,
      email: email,
      nationalId: nationalId,
    );
  }
}

extension ContractDtoMapper on ContractDto {
  Contract toEntity() {
    return Contract(
      id: id,
      referenceNumber: referenceNumber,
      nameEn: nameEn,
      nameAr: nameAr,
      contractType: contractType,
      contractTypeName: contractTypeName,
      consumptionType: consumptionType,
      company: company?.toEntity(),
    );
  }
}

extension ContractVehicleTypeDtoMapper on ContractVehicleTypeDto {
  ContractVehicleType toEntity() {
    return ContractVehicleType(
      id: id,
      contractId: contractId,
      vehicleTypeId: vehicleTypeId,
      consumptionRate: consumptionRate,
      tripsPerMonth: tripsPerMonth,
      tripsPerDay: tripsPerDay,
      maxKms: maxKms,
      monthlyRental: monthlyRental,
      dailyValue: dailyValue,
      overConsumption: overConsumption,
      quantity: quantity,
      minBillableWeightTons: minBillableWeightTons,
      maxPayloadTons: maxPayloadTons,
      overWeightPricePerTon: overWeightPricePerTon,
      extraWorkingDayFees: extraWorkingDayFees,
      addedBy: addedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      vehicleType: vehicleType?.toEntity(),
    );
  }
}

extension VehicleTypeDtoMapper on VehicleTypeDto {
  VehicleType toEntity() {
    return VehicleType(
      id: id,
      name: name,
      nameEn: nameEn,
      nameAr: nameAr,
      category: category,
      vehicleUnitType: vehicleUnitType,
    );
  }
}

extension ContractDestinationDtoMapper on ContractDestinationDto {
  ContractDestination toEntity() {
    return ContractDestination(
      id: id,
      start: start,
      end: end,
      nameAr: nameAr,
      nameEn: nameEn,
      expectedKms: expectedKms,
      numberOfDays: numberOfDays,
      pricePerTon: pricePerTon,
      fixedTripPrice: fixedTripPrice,
      description: description,
      status: status,
      statusName: statusName,
    );
  }
}

extension CompanyDtoMapper on CompanyDto {
  Company toEntity() {
    return Company(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      phone: phone,
      email: email,
      registrationNumber: registrationNumber,
      fullName: fullName,
    );
  }
}

extension ContractorDtoMapper on ContractorDto {
  Contractor toEntity() {
    return Contractor(
      id: id,
      fullName: fullName,
      userName: userName,
      email: email,
      phone: phone,
    );
  }
}

extension WaypointDtoMapper on WaypointDto {
  Waypoint toEntity() {
    return Waypoint(
      id: id,
      sequence: sequence,
      stopType: stopType,
      status: status,
      latitude: latitude,
      longitude: longitude,
      addressName: addressName,
      googlePlaceId: googlePlaceId,
      taskDetails: taskDetails,
    );
  }
}
