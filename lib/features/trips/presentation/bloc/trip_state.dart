import '../../data/models/trip_model.dart';

sealed class TripState {}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripLoaded extends TripState {
  TripLoaded(this.trips);

  final List<TripModel> trips;
}

class TripError extends TripState {
  TripError(this.message);

  final String message;
}

class TripBooking extends TripState {}

class TripBooked extends TripState {}

class TripBookError extends TripState {
  TripBookError(this.message);

  final String message;
}