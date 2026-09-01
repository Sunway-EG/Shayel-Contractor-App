import '../../domain/entities/trip/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_datasource.dart';
import '../mappers/trip_mapper.dart';
import '../models/booking_request_model.dart';
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
  Future<PagedList<BookingRequestModel>> getBookingRequests({
    int page = 1,
    int pageSize = 10,
  }) {
    return _remoteDataSource.getBookingRequests(page: page, pageSize: pageSize);
  }

  @override
  Future<void> bookTrip({required int tripId, required int driverId}) {
    return _remoteDataSource.bookTrip(tripId: tripId, driverId: driverId);
  }
}
