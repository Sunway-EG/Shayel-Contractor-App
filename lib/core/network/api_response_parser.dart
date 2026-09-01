import 'package:dio/dio.dart';

import 'api_failure_mapper.dart';

Map<String, dynamic> requireEnvelope(Response<Map<String, dynamic>> response) {
  final data = response.data;
  if (data == null) {
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: 'Empty response body',
    );
  }
  return data;
}

int totalCountFromEnvelope(Map<String, dynamic> envelope, int fallback) {
  for (final key in [
    'totalCount',
    'TotalCount',
    'total',
    'count',
    'recordsTotal',
  ]) {
    final value = envelope[key];
    if (value is num) return value.toInt();
  }

  final pagination = envelope['pagination'];
  if (pagination is Map) {
    final value = pagination['totalCount'] ?? pagination['total'];
    if (value is num) return value.toInt();
  }

  final meta = envelope['meta'];
  if (meta is Map) {
    final value = meta['totalCount'] ?? meta['total'];
    if (value is num) return value.toInt();
  }

  return fallback;
}

void throwIfEnvelopeFailed(
  Response<Map<String, dynamic>> response, {
  String fallbackMessage = 'Request failed',
}) {
  final envelope = requireEnvelope(response);
  final success = envelope['success'] as bool? ?? false;
  if (success) return;

  final message = extractApiMessage(envelope) ?? fallbackMessage;
  throw DioException(
    requestOptions: response.requestOptions,
    response: response,
    type: DioExceptionType.badResponse,
    error: message,
  );
}

Map<String, dynamic> requireEnvelopeDataMap(
  Response<Map<String, dynamic>> response, {
  String missingDataMessage = 'Missing data in response',
}) {
  final envelope = requireEnvelope(response);
  final success = envelope['success'] as bool? ?? false;
  if (!success) {
    final message = extractApiMessage(envelope) ?? 'Request failed';
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: message,
    );
  }

  final data = envelope['data'];
  if (data is Map<String, dynamic>) return data;

  throw DioException(
    requestOptions: response.requestOptions,
    response: response,
    type: DioExceptionType.badResponse,
    error: missingDataMessage,
  );
}
