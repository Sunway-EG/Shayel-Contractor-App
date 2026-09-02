import 'package:equatable/equatable.dart';

import '../trip/trip.dart';

class BookingRequest extends Equatable {
  const BookingRequest({
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
  final Trip? trip;
  final Company? company;

  @override
  List<Object?> get props => [
    id,
    status,
    statusName,
    note,
    createdAt,
    reviewedAt,
    reviewedByAdminId,
    tripId,
    trip,
    company,
  ];
}
