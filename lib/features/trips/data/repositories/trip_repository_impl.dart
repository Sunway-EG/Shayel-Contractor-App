import '../../domain/entities/book_trip/book_trip_request.dart';
import '../../domain/entities/booking_request/booking_request.dart';
import '../../domain/entities/trip/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_datasource.dart';
import '../mappers/book_trip_request_mapper.dart';
import '../mappers/booking_request_mapper.dart';
import '../mappers/trip_mapper.dart';
import '../models/paged_list.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl(this._remoteDataSource);

  final TripRemoteDataSource _remoteDataSource;

  @override
  Future<PagedList<Trip>> getTrips({
    int page = 1,
    int pageSize = 10,
    int? status,
  }) async {
    final result = await _remoteDataSource.getTrips(
      page: page,
      pageSize: pageSize,
      status: status,
    );
    return PagedList(
      items: result.items.map((e) => e.toEntity()).toList(),
      totalCount: result.totalCount,
    );
  }

  @override
  Future<TripModel> getTrip(int tripId) {
    return _remoteDataSource.getTrip(tripId);
  }

  @override
  Future<PagedList<BookingRequest>> getBookingRequests({
    int page = 1,
    int pageSize = 10,
  }) async {
    final result = await _remoteDataSource.getBookingRequests(
      page: page,
      pageSize: pageSize,
    );
    return PagedList(
      items: result.items.map((e) => e.toEntity()).toList(),
      totalCount: result.totalCount,
    );
  }

  @override
  Future<void> bookTrip(BookTripRequest request) {
    return _remoteDataSource.bookTrip(
      tripId: request.tripId,
      request: request.toDto(),
    );
  }
}
