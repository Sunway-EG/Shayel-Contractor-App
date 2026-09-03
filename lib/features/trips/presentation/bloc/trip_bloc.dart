// ignore_for_file: prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/trip/trip.dart';
import '../../domain/use_cases/book_trip_usecase.dart';
import '../../domain/use_cases/get_trips_usecase.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  TripBloc({
    required GetTripsUseCase getTripsUseCase,
    required BookTripUseCase bookTripUseCase,
  }) : _getTripsUseCase = getTripsUseCase,
       _bookTripUseCase = bookTripUseCase,
       super(TripInitial()) {
    on<GetTrips>(_onGetTrips);
    on<BookTrip>(_onBookTrip);
  }

  final GetTripsUseCase _getTripsUseCase;
  final BookTripUseCase _bookTripUseCase;
  final Set<int> _appliedTripIds = {};

  List<Trip> _withoutApplied(List<Trip> trips) {
    if (_appliedTripIds.isEmpty) return trips;
    return [
      for (final trip in trips)
        if (trip.id == null || !_appliedTripIds.contains(trip.id)) trip,
    ];
  }

  Future<void> _onGetTrips(GetTrips event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await _getTripsUseCase(
      GetTripsParams(
        page: event.page,
        pageSize: event.pageSize,
        status: event.status,
      ),
    );
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (data) {
        if (event.status != 1) {
          emit(TripLoaded(data.items, totalCount: data.totalCount));
          return;
        }
        final trips = _withoutApplied(data.items);
        final hidden = data.items.length - trips.length;
        final totalCount = data.totalCount - hidden;
        emit(
          TripLoaded(trips, totalCount: totalCount < 0 ? 0 : totalCount),
        );
      },
    );
  }

  Future<void> _onBookTrip(BookTrip event, Emitter<TripState> emit) async {
    emit(TripBooking());
    final result = await _bookTripUseCase(event.request);
    result.fold((failure) => emit(TripBookError(failure.message)), (_) {
      _appliedTripIds.add(event.request.tripId);
      emit(TripBooked());
    });
  }
}
