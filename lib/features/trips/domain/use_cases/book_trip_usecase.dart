import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_failure_mapper.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/book_trip/book_trip_request.dart';
import '../repositories/trip_repository.dart';

class BookTripUseCase implements UseCase<void, BookTripRequest> {
  BookTripUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, void>> call(BookTripRequest params) async {
    try {
      await _repository.bookTrip(params);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        Failure(
          userFacingDioMessage(e) ??
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
