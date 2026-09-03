import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/paged_list.dart';
import '../entities/booking_request/booking_request.dart';
import '../repositories/trip_repository.dart';

class GetBookingRequestsParams {
  const GetBookingRequestsParams({this.page = 1, this.pageSize = 10});

  final int page;
  final int pageSize;
}

class GetBookingRequestsUseCase
    implements UseCase<PagedList<BookingRequest>, GetBookingRequestsParams> {
  GetBookingRequestsUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, PagedList<BookingRequest>>> call(
    GetBookingRequestsParams params,
  ) async {
    try {
      final result = await _repository.getBookingRequests(
        page: params.page,
        pageSize: params.pageSize,
      );
      return Right(result);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
