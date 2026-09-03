import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../trips/domain/entities/booking_request/booking_request.dart';
import '../../../trips/domain/entities/trip/trip.dart';

class TripReviewCard extends StatelessWidget {
  const TripReviewCard({super.key, this.booking, this.trip})
    : assert(booking != null || trip != null);

  final BookingRequest? booking;
  final Trip? trip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tripEntity = trip ?? booking?.trip;
    final tripId = booking?.tripId ?? tripEntity?.id;
    final tripNumber = tripId == null ? '—' : '$tripId';
    final statuses = _statuses(l10n);
    final status = _statusFor(
      statusCode: tripEntity?.status ?? booking?.status,
      statusName: tripEntity?.tripStatusName ?? booking?.statusName,
      statuses: statuses,
    );
    final companyName = _companyName(
      context,
      booking?.company ?? tripEntity?.company,
    );
    final dateStr = _dateText(
      startDate: tripEntity?.startDate,
      fallback: booking?.createdAt ?? tripEntity?.createdAt,
    );
    final address = _address(tripEntity);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoListTile(
            leading: SvgPicture.asset(
              'assets/images/trip_review_truck.svg',
              width: 40,
              height: 40,
            ),
            leadingSize: 40,
            title: _Title(
              title: '${l10n.trip} #$tripNumber',
              fontSize: 14,
              color: AppColors.darkGray,
            ),
            subtitle: _Title(title: companyName, fontSize: 14),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: status.color,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width * 0.2,
            ),
            child: _Title(title: dateStr, fontSize: 14),
          ),
          CupertinoListTile(
            leading: SvgPicture.asset('assets/images/location.svg'),
            leadingSize: 40,
            title: _Title(title: address, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

String _companyName(BuildContext context, Company? company) {
  if (company == null) return '—';
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  if (isRtl) {
    return company.nameAr ?? company.fullName ?? company.nameEn ?? '—';
  }
  return company.nameEn ?? company.fullName ?? company.nameAr ?? '—';
}

String _dateText({String? startDate, DateTime? fallback}) {
  final parsed = startDate == null ? fallback : DateTime.tryParse(startDate);
  final date = parsed ?? fallback;
  if (date == null) return '—';
  return DateFormat('hh:mm a • dd-MM-yyyy').format(date.toLocal());
}

String _address(Trip? trip) {
  final waypoints = trip?.waypoints;
  if (waypoints != null && waypoints.isNotEmpty) {
    final named = waypoints
        .map((w) => w.addressName)
        .whereType<String>()
        .where((name) => name.trim().isNotEmpty);
    if (named.isNotEmpty) return named.first;
  }
  final destination = trip?.contractDestination;
  return destination?.nameAr ?? destination?.nameEn ?? '—';
}

Status _statusFor({
  required int? statusCode,
  required String? statusName,
  required List<Status> statuses,
}) {
  if (statusCode != null) {
    for (final status in statuses) {
      if (status.code == statusCode) return status;
    }
  }

  if (statusName != null && statusName.trim().isNotEmpty) {
    final lower = statusName.toLowerCase();
    for (final status in statuses) {
      if (status.name.toLowerCase() == lower) return status;
    }
    return Status(
      name: statusName,
      code: statusCode,
      color: CupertinoColors.activeBlue,
      icon: CupertinoIcons.doc_text,
    );
  }

  return statuses.first;
}

List<Status> _statuses(AppLocalizations l10n) {
  return [
    Status(
      name: l10n.all,
      code: null,
      color: CupertinoColors.activeBlue,
      icon: CupertinoIcons.infinite,
    ),
    Status(
      name: l10n.requested,
      code: 0,
      color: CupertinoColors.systemIndigo,
      icon: CupertinoIcons.paperplane_fill,
    ),
    Status(
      name: l10n.pending,
      code: 1,
      color: CupertinoColors.systemPurple,
      icon: CupertinoIcons.bookmark_fill,
    ),
    Status(
      name: l10n.scheduled,
      code: 2,
      color: AppColors.newgreen,
      icon: CupertinoIcons.table_fill,
    ),
    Status(
      name: l10n.loadingCargo,
      code: 3,
      color: const Color(0xFFE89B5D),
      icon: CupertinoIcons.cube_box_fill,
    ),
    Status(
      name: l10n.inProgress,
      code: 5,
      color: AppColors.orange,
      icon: CupertinoIcons.slowmo,
    ),
    Status(
      name: l10n.tripCompleted,
      code: 6,
      color: const Color(0xFF0874C9),
      icon: CupertinoIcons.checkmark_alt,
    ),
    Status(
      name: l10n.reviewed,
      code: 7,
      color: CupertinoColors.systemTeal,
      icon: CupertinoIcons.doc_checkmark_fill,
    ),
    Status(
      name: l10n.tripWasCancelled,
      code: 8,
      color: AppColors.red,
      icon: CupertinoIcons.xmark,
    ),
    Status(
      name: l10n.draft,
      code: -1,
      color: CupertinoColors.systemMint,
      icon: CupertinoIcons.doc_fill,
    ),
  ];
}

class _Title extends StatelessWidget {
  const _Title({
    required this.title,
    required this.fontSize,
    this.color = CupertinoColors.systemGrey,
  });

  final String title;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class Status {
  Status({
    required this.name,
    required this.code,
    required this.color,
    required this.icon,
  });

  String name;
  int? code;
  Color color;
  IconData icon;
}
