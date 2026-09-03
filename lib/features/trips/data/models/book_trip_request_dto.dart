import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class BookTripRequestDto {
  const BookTripRequestDto({this.note, this.driverId, this.driver});

  final String? note;
  final int? driverId;
  final ApplyDriverDto? driver;

  Future<FormData> toFormData() async {
    final formData = FormData();
    final applyDriver = driver;

    if (note != null && note!.isNotEmpty) {
      formData.fields.add(MapEntry('Note', note!));
    }

    if (applyDriver == null) {
      if (driverId != null) {
        formData.fields.add(MapEntry('DriverId', driverId.toString()));
      }
      return formData;
    }

    formData.fields.add(MapEntry('Driver.FullNameEn', applyDriver.fullNameEn));
    formData.fields.add(MapEntry('Driver.FullNameAr', applyDriver.fullNameAr));
    formData.fields.add(MapEntry('Driver.Phone', applyDriver.phone));
    formData.fields.add(MapEntry('Driver.NationalId', applyDriver.nationalId));

    for (var i = 0; i < applyDriver.documents.length; i++) {
      final document = applyDriver.documents[i];
      formData.fields.add(
        MapEntry(
          'Driver.Documents[$i].DocumentId',
          document.documentId.toString(),
        ),
      );
      formData.fields.add(
        MapEntry(
          'Driver.Documents[$i].ExpiryDate',
          document.expiryDate.toIso8601String().split('T').first,
        ),
      );
      formData.files.add(
        MapEntry(
          'Driver.Documents[$i].File',
          await _multipartFileFromPath(document.filePath),
        ),
      );
    }

    return formData;
  }
}

Future<MultipartFile> _multipartFileFromPath(String filePath) async {
  final filename = p.basename(filePath);
  final name = filename.isEmpty ? 'document.jpg' : filename;
  final bytes = await XFile(filePath).readAsBytes();
  return MultipartFile.fromBytes(bytes, filename: name);
}

class ApplyDriverDto {
  const ApplyDriverDto({
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
  final List<ApplyDriverDocumentDto> documents;
}

class ApplyDriverDocumentDto {
  const ApplyDriverDocumentDto({
    required this.documentId,
    required this.filePath,
    required this.expiryDate,
    this.status = 0,
  });

  final int documentId;
  final String filePath;
  final DateTime expiryDate;
  final int status;
}
