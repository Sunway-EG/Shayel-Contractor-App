import '../../domain/entities/driver/driver.dart';
import '../models/driver_dto.dart';

extension DriverDtoMapper on DriverDto {
  Driver toEntity() {
    return Driver(
      id: id,
      fullNameEn: fullNameEn,
      fullNameAr: fullNameAr,
      phone: phone,
      nationalId: nationalId,
      email: email,
      userName: userName,
      status: status,
      workingStatus: workingStatus,
    );
  }
}
