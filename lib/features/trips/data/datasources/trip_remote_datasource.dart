import 'package:dio/dio.dart';

import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_response_parser.dart';
import '../models/trip_model.dart';

abstract interface class TripRemoteDataSource {
  Future<List<TripModel>> getTrips({
    int page = 1,
    int pageSize = 10,
    int? status,
  });

  Future<void> bookTrip({required int tripId, required int driverId});
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  TripRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TripModel>> getTrips({
    int page = 1,
    int pageSize = 10,
    int? status,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.trips,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        'Status': status?.toString() ?? '',
        'StartDateFrom': '',
        'StartDateTo': '',
      },
    );

    final envelope = requireEnvelope(response);
    final data = envelope['data'];

    if (data is! List) {
      throw Exception('Invalid trips response');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(TripModel.fromJson)
        .toList();
  }

  @override
  Future<void> bookTrip({required int tripId, required int driverId}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.bookTrip(tripId),
      data: {'driverId': driverId},
    );
    throwIfEnvelopeFailed(response, fallbackMessage: 'Failed to book trip');
  }
}
