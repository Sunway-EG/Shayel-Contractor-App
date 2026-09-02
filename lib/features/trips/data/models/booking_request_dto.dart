import '../models/trip_dto.dart';

class BookingRequestDto {
  const BookingRequestDto({
    this.id,
    this.status,
    this.statusName,
    this.note,
    this.createdAt,
    this.reviewedAt,
    this.reviewedByAdminId,
    this.tripId,
    this.trip,
    this.company,
  });

  final int? id;
  final int? status;
  final String? statusName;
  final String? note;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final int? reviewedByAdminId;
  final int? tripId;
  final TripDto? trip;
  final CompanyDto? company;

  factory BookingRequestDto.fromJson(Map<String, dynamic> json) {
    return BookingRequestDto(
      id: (json['id'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      statusName: json['statusName'] as String?,
      note: json['note'] as String?,
      createdAt: _parseDate(json['createdAt']),
      reviewedAt: _parseDate(json['reviewedAt']),
      reviewedByAdminId: (json['reviewedByAdminId'] as num?)?.toInt(),
      tripId: (json['tripId'] as num?)?.toInt(),
      trip: () {
        try {
          final map = _mapOf(json['trip']);
          if (map == null) return null;
          return TripDto.fromJson(map);
        } catch (_) {
          return null;
        }
      }(),
      company: () {
        try {
          final map = _mapOf(json['company']);
          if (map == null) return null;
          return CompanyDto.fromJson(map);
        } catch (_) {
          return null;
        }
      }(),
    );
  }
}

Map<String, dynamic>? _mapOf(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
