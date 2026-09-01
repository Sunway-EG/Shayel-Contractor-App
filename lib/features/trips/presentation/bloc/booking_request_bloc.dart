import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/trip_repository.dart';
import 'booking_request_event.dart';
import 'booking_request_state.dart';

class BookingRequestBloc
    extends Bloc<BookingRequestEvent, BookingRequestState> {
  BookingRequestBloc(this._repository) : super(BookingRequestInitial()) {
    on<GetBookingRequests>(_onGetBookingRequests);
  }

  final TripRepository _repository;

  Future<void> _onGetBookingRequests(
    GetBookingRequests event,
    Emitter<BookingRequestState> emit,
  ) async {
    emit(BookingRequestLoading());
    try {
      final result = await _repository.getBookingRequests(
        page: event.page,
        pageSize: event.pageSize,
      );
      emit(BookingRequestLoaded(result.items, totalCount: result.totalCount));
    } catch (e) {
      emit(BookingRequestError(e.toString()));
    }
  }
}
