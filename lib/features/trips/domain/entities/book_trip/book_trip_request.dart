import 'package:equatable/equatable.dart';

class BookTripRequest extends Equatable {
  const BookTripRequest({
    required this.tripId,
    this.driverId,
    this.driver,
    this.note,
  });

  final int tripId;
  final int? driverId;
  final BookTripDriver? driver;
  final String? note;

  @override
  List<Object?> get props => [tripId, driverId, driver, note];
}

class BookTripDriver extends Equatable {
  const BookTripDriver({
    required this.fullNameEn,
    required this.fullNameAr,
    required this.phone,
    required this.nationalId,
    this.documents = const [],
  });

  final String fullNameEn;
  final String fullNameAr;
  final String phone;
  final String nationalId;
  final List<BookTripDriverDocument> documents;

  @override
  List<Object?> get props => [
    fullNameEn,
    fullNameAr,
    phone,
    nationalId,
    documents,
  ];
}

class BookTripDriverDocument extends Equatable {
  const BookTripDriverDocument({
    required this.documentId,
    required this.filePath,
    required this.expiryDate,
    this.status = 0,
  });

  final int documentId;
  final String filePath;
  final DateTime expiryDate;
  final int status;

  @override
  List<Object?> get props => [documentId, filePath, expiryDate, status];
}
