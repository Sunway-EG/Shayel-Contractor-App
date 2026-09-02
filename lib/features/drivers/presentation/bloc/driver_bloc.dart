import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_failure_mapper.dart';
import '../../domain/entities/driver/driver.dart';
import '../../domain/entities/driver_document_type/driver_document_type.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_event.dart';
import 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  DriverBloc(this._repository) : super(DriverInitial()) {
    on<GetDrivers>(_onGetDrivers);
    on<GetDriverDocumentTypes>(_onGetDriverDocumentTypes);
    on<CreateDriver>(_onCreateDriver);
  }

  final DriverRepository _repository;

  List<Driver> _drivers = const [];
  List<DriverDocumentType> _documentTypes = const [];

  DriverLoaded _loaded({
    bool loadingDrivers = false,
    bool loadingDocuments = false,
    String? documentsError,
  }) {
    return DriverLoaded(
      drivers: _drivers,
      documentTypes: _documentTypes,
      loadingDrivers: loadingDrivers,
      loadingDocuments: loadingDocuments,
      documentsError: documentsError,
    );
  }

  Future<void> _onGetDrivers(
    GetDrivers event,
    Emitter<DriverState> emit,
  ) async {
    emit(_loaded(loadingDrivers: true));
    try {
      _drivers = await _repository.getDrivers(
        page: event.page,
        pageSize: event.pageSize,
      );
      emit(_loaded());
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onGetDriverDocumentTypes(
    GetDriverDocumentTypes event,
    Emitter<DriverState> emit,
  ) async {
    emit(_loaded(loadingDocuments: true));
    try {
      _documentTypes = await _repository.getDocumentTypes(
        page: event.page,
        pageSize: event.pageSize,
      );
      emit(_loaded());
    } catch (e) {
      emit(_loaded(documentsError: e.toString()));
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
      emit(_loaded());
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
      emit(_loaded());
    }
  }
}
