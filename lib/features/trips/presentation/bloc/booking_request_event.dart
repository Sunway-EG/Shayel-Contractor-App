sealed class BookingRequestEvent {}

class GetBookingRequests extends BookingRequestEvent {
  GetBookingRequests({this.page = 1, this.pageSize = 10});

  final int page;
  final int pageSize;
}
