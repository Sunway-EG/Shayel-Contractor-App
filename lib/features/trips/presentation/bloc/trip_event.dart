import '../../domain/entities/book_trip/book_trip_request.dart';

sealed class TripEvent {}

class GetTrips extends TripEvent {
  GetTrips({this.page = 1, this.pageSize = 10, this.status});

  final int page;
  final int pageSize;
  final int? status;
}

class BookTrip extends TripEvent {
  BookTrip(this.request);

  final BookTripRequest request;
}
