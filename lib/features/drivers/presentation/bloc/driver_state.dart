import '../../data/models/driver_model.dart';

sealed class DriverState {}

class DriverInitial extends DriverState {}

class DriverLoading extends DriverState {}

class DriverLoaded extends DriverState {
  DriverLoaded(this.drivers);

  final List<DriverModel> drivers;
}

class DriverError extends DriverState {
  DriverError(this.message);

  final String message;
}

class DriverCreating extends DriverState {}

class DriverCreated extends DriverState {
  DriverCreated(this.driver);

  final DriverModel? driver;
}

class DriverCreateError extends DriverState {
  DriverCreateError(this.message);

  final String message;
}