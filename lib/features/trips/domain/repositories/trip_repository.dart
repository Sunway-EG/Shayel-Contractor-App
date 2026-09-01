import '../../data/models/trip_model.dart';

abstract interface class TripRepository {
  Future<List<TripModel>> getTrips({
    int page = 1,
    int pageSize = 10,
    int? status,
  });

  Future<void> bookTrip({required int tripId, required int driverId});
}