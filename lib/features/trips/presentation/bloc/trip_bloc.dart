import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_failure_mapper.dart';
import '../../domain/repositories/trip_repository.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  TripBloc(this._repository) : super(TripInitial()) {
    on<GetTrips>(_onGetTrips);
    on<BookTrip>(_onBookTrip);
  }

  final TripRepository _repository;

  Future<void> _onGetTrips(GetTrips event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trips = await _repository.getTrips(
        page: event.page,
        pageSize: event.pageSize,
        status: event.status,
      );
      emit(TripLoaded(trips));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onBookTrip(BookTrip event, Emitter<TripState> emit) async {
    emit(TripBooking());
    try {
      await _repository.bookTrip(tripId: event.tripId, driverId: event.driverId);
      emit(TripBooked());
    } catch (e) {
      if (e is DioException) {
        emit(
          TripBookError(
            mapDioExceptionToFailure(e).message ??
                e.error?.toString() ??
                e.message ??
                'Request failed',
          ),
        );
      } else {
        emit(TripBookError(e.toString()));
      }
    }
  }
}