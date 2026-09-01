import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_failure_mapper.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_event.dart';
import 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  DriverBloc(this._repository) : super(DriverInitial()) {
    on<GetDrivers>(_onGetDrivers);
    on<CreateDriver>(_onCreateDriver);
  }

  final DriverRepository _repository;

  Future<void> _onGetDrivers(
    GetDrivers event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    try {
      final drivers = await _repository.getDrivers(
        page: event.page,
        pageSize: event.pageSize,
      );
      emit(DriverLoaded(drivers));
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onCreateDriver(
    CreateDriver event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverCreating());
    try {
      final driver = await _repository.createDriver(
        fullNameEn: event.fullNameEn,
        fullNameAr: event.fullNameAr,
        phone: event.phone,
        nationalId: event.nationalId,
        documents: event.documents,
      );
      emit(DriverCreated(driver));
    } catch (e) {
      if (e is DioException) {
        emit(
          DriverCreateError(
            mapDioExceptionToFailure(e).message ??
                e.error?.toString() ??
                e.message ??
                'Request failed',
          ),
        );
      } else {
        emit(DriverCreateError(e.toString()));
      }
    }
  }
}
