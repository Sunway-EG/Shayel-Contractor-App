import '../../domain/entities/book_trip/book_trip_request.dart';
import '../models/book_trip_request_dto.dart';

extension BookTripRequestMapper on BookTripRequest {
  BookTripRequestDto toDto() {
    return BookTripRequestDto(
      note: note,
      driverId: driverId,
      driver: driver?.toDto(),
    );
  }
}

extension BookTripDriverMapper on BookTripDriver {
  ApplyDriverDto toDto() {
    return ApplyDriverDto(
      fullNameEn: fullNameEn,
      fullNameAr: fullNameAr,
      phone: phone,
      nationalId: nationalId,
      documents: documents.map((document) => document.toDto()).toList(),
    );
  }
}

extension BookTripDriverDocumentMapper on BookTripDriverDocument {
  ApplyDriverDocumentDto toDto() {
    return ApplyDriverDocumentDto(
      documentId: documentId,
      filePath: filePath,
      expiryDate: expiryDate,
      status: status,
    );
  }
}
