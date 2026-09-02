import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_response_parser.dart';
import '../models/book_trip_request_dto.dart';
import '../models/booking_request_dto.dart';
import '../models/paged_list.dart';
import '../models/trip_dto.dart';
import '../models/trip_model.dart';

abstract interface class TripRemoteDataSource {
  Future<PagedList<TripDto>> getTrips({
    int page = 1,
    int pageSize = 10,
    int? status,
  });

  Future<TripModel> getTrip(int tripId);

  Future<PagedList<BookingRequestDto>> getBookingRequests({
    int page = 1,
    int pageSize = 10,
  });

  Future<void> bookTrip({
    required int tripId,
    required BookTripRequestDto request,
  });
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  TripRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PagedList<TripDto>> getTrips({
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

    if (kDebugMode && data.isNotEmpty) {
      debugPrint('TRIP_RAW ${jsonEncode(data.first)}');
    }

    final items = <TripDto>[];
    for (final item in data) {
      if (item is Map) {
        items.add(TripDto.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return PagedList(
      items: items,
      totalCount: totalCountFromEnvelope(envelope, items.length),
    );
  }

  @override
  Future<TripModel> getTrip(int tripId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.tripById(tripId),
    );
    final envelope = requireEnvelope(response);
    final data = envelope['data'] ?? envelope['Data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map<String, dynamic>) return TripModel.fromJson(first);
      if (first is Map) {
        return TripModel.fromJson(Map<String, dynamic>.from(first));
      }
    }
    if (data is Map<String, dynamic>) {
      return TripModel.fromJson(data);
    }
    if (data is Map) {
      return TripModel.fromJson(Map<String, dynamic>.from(data));
    }
    if (envelope['id'] != null || envelope['referenceNumber'] != null) {
      return TripModel.fromJson(envelope);
    }
    throw Exception('Invalid trip response');
  }

  @override
  Future<PagedList<BookingRequestDto>> getBookingRequests({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.bookingRequests,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );

    final envelope = requireEnvelope(response);
    final data = envelope['data'];

    if (data is! List) {
      throw Exception('Invalid booking requests response');
    }

    final items = <BookingRequestDto>[];
    for (final item in data) {
      if (item is Map) {
        items.add(BookingRequestDto.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return PagedList(
      items: items,
      totalCount: totalCountFromEnvelope(envelope, items.length),
    );
  }

  @override
  Future<void> bookTrip({
    required int tripId,
    required BookTripRequestDto request,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.bookTrip(tripId),
      data: await request.toFormData(),
    );
    throwIfEnvelopeFailed(response, fallbackMessage: 'Failed to book trip');
  }
}
