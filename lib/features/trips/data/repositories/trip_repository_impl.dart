import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_datasource.dart';
import '../models/booking_request_model.dart';
import '../models/paged_list.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl(this._remoteDataSource);

  final TripRemoteDataSource _remoteDataSource;

  @override
  Future<PagedList<TripModel>> getTrips({
    int page = 1,
    int pageSize = 10,
    int? status,
  }) {
    return _remoteDataSource.getTrips(
      page: page,
      pageSize: pageSize,
      status: status,
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
    return _remoteDataSource.getBookingRequests(
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<void> bookTrip({required int tripId, required int driverId}) {
    return _remoteDataSource.bookTrip(tripId: tripId, driverId: driverId);
  }
}
