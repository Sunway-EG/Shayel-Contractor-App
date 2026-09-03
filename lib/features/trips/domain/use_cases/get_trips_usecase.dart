import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/paged_list.dart';
import '../entities/trip/trip.dart';
import '../repositories/trip_repository.dart';

class GetTripsParams {
  const GetTripsParams({this.page = 1, this.pageSize = 10, this.status});

  final int page;
  final int pageSize;
  final int? status;
}

class GetTripsUseCase implements UseCase<PagedList<Trip>, GetTripsParams> {
  GetTripsUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, PagedList<Trip>>> call(GetTripsParams params) async {
    try {
      final result = await _repository.getTrips(
        page: params.page,
        pageSize: params.pageSize,
        status: params.status,
      );
      return Right(result);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
