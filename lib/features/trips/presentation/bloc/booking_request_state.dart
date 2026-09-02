import '../../domain/entities/booking_request/booking_request.dart';

sealed class BookingRequestState {}

class BookingRequestInitial extends BookingRequestState {}

class BookingRequestLoading extends BookingRequestState {}

class BookingRequestLoaded extends BookingRequestState {
  BookingRequestLoaded(this.requests, {required this.totalCount});

  final List<BookingRequest> requests;
  final int totalCount;
}

class BookingRequestError extends BookingRequestState {
  BookingRequestError(this.message);

  final String message;
}
