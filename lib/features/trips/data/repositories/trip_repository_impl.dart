import '../../domain/repositories/trip_repository.dart';
import '../../data/datasources/trip_remote_datasource.dart';
import '../../data/models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl(this._remoteDataSource);

  final TripRemoteDataSource _remoteDataSource;

  @override
  Future<List<TripModel>> getTrips({
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
  Future<void> bookTrip({required int tripId, required int driverId}) {
    return _remoteDataSource.bookTrip(tripId: tripId, driverId: driverId);
  }
}