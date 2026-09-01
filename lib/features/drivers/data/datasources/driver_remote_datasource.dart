import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_response_parser.dart';
import '../models/driver_document_input.dart';
import '../models/driver_model.dart';

abstract interface class DriverRemoteDataSource {
  Future<List<DriverModel>> getDrivers({int page = 1, int pageSize = 10});

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
  Future<List<DriverModel>> getDrivers({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.drivers,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );

    final envelope = requireEnvelope(response);
    final data = envelope['data'];

    if (data is! List) {
      throw Exception('Invalid drivers response');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(DriverModel.fromJson)
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
    throwIfEnvelopeFailed(response, fallbackMessage: 'Failed to create driver');

    final data = response.data?['data'];
    if (data is Map<String, dynamic> && data['id'] is int) {
      return DriverModel.fromJson(data);
    }
    return null;
  }
}
