import '../../data/models/driver_document_input.dart';
import '../../data/models/driver_model.dart';

abstract interface class DriverRepository {
  Future<List<DriverModel>> getDrivers({
    int page = 1,
    int pageSize = 10,
  });

  Future<DriverModel?> createDriver({
    required String fullNameEn,
    required String fullNameAr,
    required String phone,
    required String nationalId,
    required List<DriverDocumentInput> documents,
  });
}