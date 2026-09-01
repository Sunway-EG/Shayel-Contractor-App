import '../../data/models/booking_request_model.dart';
import '../../data/models/paged_list.dart';
import '../../data/models/trip_model.dart';
import '../entities/trip/trip.dart';

abstract interface class TripRepository {
  Future<PagedList<Trip>> getTrips({
    int page = 1,
    int pageSize = 10,
    int? status,
  });

  Future<TripModel> getTrip(int tripId);

  Future<PagedList<BookingRequestModel>> getBookingRequests({
    int page = 1,
    int pageSize = 10,
  });

  Future<void> bookTrip({required int tripId, required int driverId});
}
