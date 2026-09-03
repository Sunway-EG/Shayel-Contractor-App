// ignore_for_file: prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/mappers/driver_mapper.dart';
import '../../domain/entities/driver/driver.dart';
import '../../domain/entities/driver_document_type/driver_document_type.dart';
import '../../domain/use_cases/create_driver_usecase.dart';
import '../../domain/use_cases/get_driver_document_types_usecase.dart';
import '../../domain/use_cases/get_drivers_usecase.dart';
import 'driver_event.dart';
import 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  DriverBloc({
    required GetDriversUseCase getDriversUseCase,
    required GetDriverDocumentTypesUseCase getDriverDocumentTypesUseCase,
    required CreateDriverUseCase createDriverUseCase,
  }) : _getDriversUseCase = getDriversUseCase,
       _getDriverDocumentTypesUseCase = getDriverDocumentTypesUseCase,
       _createDriverUseCase = createDriverUseCase,
       super(DriverInitial()) {
    on<GetDrivers>(_onGetDrivers);
    on<GetDriverDocumentTypes>(_onGetDriverDocumentTypes);
    on<CreateDriver>(_onCreateDriver);
  }

  final GetDriversUseCase _getDriversUseCase;
  final GetDriverDocumentTypesUseCase _getDriverDocumentTypesUseCase;
  final CreateDriverUseCase _createDriverUseCase;

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
    final result = await _getDriversUseCase(
      GetDriversParams(page: event.page, pageSize: event.pageSize),
    );
    result.fold(
      (failure) => emit(DriverError(failure.message)),
      (drivers) {
        _drivers = drivers;
        emit(_loaded());
      },
    );
  }

  Future<void> _onGetDriverDocumentTypes(
    GetDriverDocumentTypes event,
    Emitter<DriverState> emit,
  ) async {
    emit(_loaded(loadingDocuments: true));
    final result = await _getDriverDocumentTypesUseCase(
      GetDriverDocumentTypesParams(page: event.page, pageSize: event.pageSize),
    );
    result.fold(
      (failure) => emit(_loaded(documentsError: failure.message)),
      (documentTypes) {
        _documentTypes = documentTypes;
        emit(_loaded());
      },
    );
  }

  Future<void> _onCreateDriver(
    CreateDriver event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverCreating());
    final result = await _createDriverUseCase(
      CreateDriverParams(
        fullNameEn: event.fullNameEn,
        fullNameAr: event.fullNameAr,
        phone: event.phone,
        nationalId: event.nationalId,
        documents: event.documents,
      ),
    );
    result.fold(
      (failure) {
        emit(DriverCreateError(failure.message));
        emit(_loaded());
      },
      (driver) {
        if (driver == null) {
          emit(DriverCreateError('Failed to create driver'));
          emit(_loaded());
          return;
        }
        final created = driver.toEntity();
        _drivers = [
          created,
          ..._drivers.where((item) => item.id != created.id),
        ];
        emit(DriverCreated(created));
      },
    );
  }
}
