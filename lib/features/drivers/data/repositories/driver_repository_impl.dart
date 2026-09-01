import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_datasource.dart';
import '../models/driver_document_input.dart';
import '../models/driver_model.dart';

class DriverRepositoryImpl implements DriverRepository {
  DriverRepositoryImpl(this._remoteDataSource);

  final DriverRemoteDataSource _remoteDataSource;

  @override
  Future<List<DriverModel>> getDrivers({
    int page = 1,
    int pageSize = 10,
  }) {
    return _remoteDataSource.getDrivers(
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<DriverModel?> createDriver({
    required String fullNameEn,
    required String fullNameAr,
    required String phone,
    required String nationalId,
    required List<DriverDocumentInput> documents,
  }) {
    return _remoteDataSource.createDriver(
      fullNameEn: fullNameEn,
      fullNameAr: fullNameAr,
      phone: phone,
      nationalId: nationalId,
      documents: documents,
    );
  }
}