import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_failure_mapper.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/driver_document_input.dart';
import '../../data/models/driver_model.dart';
import '../repositories/driver_repository.dart';

class CreateDriverParams {
  const CreateDriverParams({
    required this.fullNameEn,
    required this.fullNameAr,
    required this.phone,
    required this.nationalId,
    required this.documents,
  });

  final String fullNameEn;
  final String fullNameAr;
  final String phone;
  final String nationalId;
  final List<DriverDocumentInput> documents;
}

class CreateDriverUseCase implements UseCase<DriverModel?, CreateDriverParams> {
  CreateDriverUseCase(this._repository);

  final DriverRepository _repository;

  @override
  Future<Either<Failure, DriverModel?>> call(CreateDriverParams params) async {
    try {
      final driver = await _repository.createDriver(
        fullNameEn: params.fullNameEn,
        fullNameAr: params.fullNameAr,
        phone: params.phone,
        nationalId: params.nationalId,
        documents: params.documents,
      );
      if (driver == null) {
        return const Left(Failure('Failed to create driver'));
      }
      return Right(driver);
    } on DioException catch (e) {
      return Left(
        Failure(
          mapDioExceptionToFailure(e).message ??
              e.error?.toString() ??
              e.message ??
              'Request failed',
        ),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
