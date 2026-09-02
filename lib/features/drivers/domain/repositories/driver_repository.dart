import '../../data/models/driver_document_input.dart';
import '../../data/models/driver_model.dart';
import '../entities/driver/driver.dart';
import '../entities/driver_document_type/driver_document_type.dart';

abstract interface class DriverRepository {
  Future<List<Driver>> getDrivers({int page = 1, int pageSize = 10});

  Future<List<DriverDocumentType>> getDocumentTypes({
    int page = 1,
    int pageSize = 15,
  });

  Future<DriverModel?> createDriver({
    required String fullNameEn,
    required String fullNameAr,
    required String phone,
    required String nationalId,
    required List<DriverDocumentInput> documents,
  });
}
