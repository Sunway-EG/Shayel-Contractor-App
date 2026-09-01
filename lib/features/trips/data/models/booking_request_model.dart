class BookingRequestModel {
  const BookingRequestModel({
    required this.id,
    this.statusName,
    this.note,
  });

  final int id;
  final String? statusName;
  final String? note;

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      id: json['id'] as int? ?? 0,
      statusName: json['statusName'] as String?,
      note: json['note'] as String?,
    );
  }
}
