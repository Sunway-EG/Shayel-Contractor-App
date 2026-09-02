import '../../data/models/paged_list.dart';
import '../../data/models/trip_model.dart';
import '../entities/book_trip/book_trip_request.dart';
import '../entities/booking_request/booking_request.dart';
import '../entities/trip/trip.dart';

abstract interface class TripRepository {
  Future<PagedList<Trip>> getTrips({
    int page = 1,
    int pageSize = 10,
    int? status,
  });

  Future<TripModel> getTrip(int tripId);

  Future<PagedList<BookingRequest>> getBookingRequests({
    int page = 1,
    int pageSize = 10,
  });

  Future<void> bookTrip(BookTripRequest request);
}
