import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_failure_mapper.dart';
import '../../../../../core/network/api_response_parser.dart';
import '../models/driver_document_input.dart';
import '../models/driver_document_type_dto.dart';
import '../models/driver_dto.dart';
import '../models/driver_model.dart';

abstract interface class DriverRemoteDataSource {
  Future<List<DriverDto>> getDrivers({int page = 1, int pageSize = 10});

  Future<List<DriverDocumentTypeDto>> getDocumentTypes({
    int page = 1,
    int pageSize = 15,
  });

  Future<DriverModel?> createDriver({
    required String fullNameEn,
    required String fullNameAr,
    required String phone,
    required String nationalId,
    required List<DriverDocumentInput> documents,
  });
}

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  DriverRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<DriverDto>> getDrivers({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.drivers,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );

    final envelope = requireEnvelope(response);
    final items = _mapList(envelope['data'] ?? envelope['Data']);

    if (items == null) {
      throw Exception('Invalid drivers response');
    }

    return items.map(DriverDto.fromJson).toList();
  }

  @override
  Future<List<DriverDocumentTypeDto>> getDocumentTypes({
    int page = 1,
    int pageSize = 15,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.documents,
      queryParameters: {
        'Page': page,
        'PageSize': pageSize,
        'Search': '',
        'Status': 1,
        'entityId': ApiEndpoints.driverDocumentsEntityId,
      },
    );

    final envelope = requireEnvelope(response);
    final items = _mapList(envelope['data'] ?? envelope['Data']);

    if (items == null) {
      throw Exception('Invalid driver documents response');
    }

    return items
        .map(DriverDocumentTypeDto.fromJson)
        .where((item) => item.id != 0)
        .toList();
  }

  @override
  Future<DriverModel?> createDriver({
    required String fullNameEn,
    required String fullNameAr,
    required String phone,
    required String nationalId,
    required List<DriverDocumentInput> documents,
  }) async {
    final formData = FormData();

    formData.fields.add(MapEntry('FullNameEn', fullNameEn));
    formData.fields.add(MapEntry('FullNameAr', fullNameAr));
    formData.fields.add(MapEntry('Phone', phone));
    formData.fields.add(MapEntry('NationalId', nationalId));

    for (var i = 0; i < documents.length; i++) {
      final document = documents[i];
      formData.fields.add(
        MapEntry('Documents[$i].DocumentId', document.documentId.toString()),
      );
      formData.fields.add(
        MapEntry(
          'Documents[$i].ExpiryDate',
          document.expiryDate.toIso8601String().split('T').first,
        ),
      );
      formData.fields.add(
        MapEntry('Documents[$i].Status', document.status.toString()),
      );
      formData.files.add(
        MapEntry(
          'Documents[$i].File',
          await MultipartFile.fromFile(
            document.filePath,
            filename: p.basename(document.filePath),
          ),
        ),
      );
    }

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.drivers,
      data: formData,
    );
    final envelope = requireEnvelope(response);
    final success = envelope['success'] ?? envelope['Success'];
    if (success == false) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: extractApiMessage(envelope) ?? 'Failed to create driver',
      );
    }

    final raw = envelope['data'] ?? envelope['Data'] ?? envelope;
    if (raw is num) {
      return DriverModel(
        id: raw.toInt(),
        fullNameEn: fullNameEn,
        fullNameAr: fullNameAr,
        nationalId: nationalId,
        phone: phone,
        status: 0,
      );
    }

    final map = _asMap(raw);
    if (map == null) return null;

    final dto = DriverDto.fromJson(map);
    if (dto.id == null) return null;

    return DriverModel(
      id: dto.id!,
      fullNameEn: dto.fullNameEn ?? fullNameEn,
      fullNameAr: dto.fullNameAr ?? fullNameAr,
      nationalId: dto.nationalId ?? nationalId,
      userName: dto.userName,
      email: dto.email,
      phone: dto.phone ?? phone,
      status: dto.status ?? 0,
      workingStatus: dto.workingStatus,
    );
  }
}

List<Map<String, dynamic>>? _mapList(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  if (data is Map) {
    final nested = data['items'] ?? data['Items'] ?? data['data'] ?? data['Data'];
    if (nested is List) {
      return nested
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
  }
  return null;
}

Map<String, dynamic>? _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  if (data is List && data.isNotEmpty) {
    final first = data.first;
    if (first is Map) return Map<String, dynamic>.from(first);
  }
  return null;
}
