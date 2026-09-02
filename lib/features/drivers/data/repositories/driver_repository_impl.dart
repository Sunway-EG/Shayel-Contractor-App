import '../../domain/entities/driver/driver.dart';
import '../../domain/entities/driver_document_type/driver_document_type.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_datasource.dart';
import '../mappers/driver_document_type_mapper.dart';
import '../mappers/driver_mapper.dart';
import '../models/driver_document_input.dart';
import '../models/driver_model.dart';

class DriverRepositoryImpl implements DriverRepository {
  DriverRepositoryImpl(this._remoteDataSource);

  final DriverRemoteDataSource _remoteDataSource;

  @override
  Future<List<Driver>> getDrivers({int page = 1, int pageSize = 10}) async {
    final result = await _remoteDataSource.getDrivers(
      page: page,
      pageSize: pageSize,
    );
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<DriverDocumentType>> getDocumentTypes({
    int page = 1,
    int pageSize = 15,
  }) async {
    final result = await _remoteDataSource.getDocumentTypes(
      page: page,
      pageSize: pageSize,
    );
    return result.map((e) => e.toEntity()).toList();
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
