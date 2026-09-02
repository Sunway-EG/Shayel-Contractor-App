import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../trips/domain/entities/booking_request/booking_request.dart';

class TripReviewCard extends StatelessWidget {
  const TripReviewCard({super.key, required this.booking});

  final BookingRequest booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statuses = _statuses(l10n);
    final status = _statusFor(booking, statuses);
    final tripNumber = booking.trip?.referenceNumber ?? '${booking.id ?? ''}';
    final companyName = _companyName(context, booking);
    final dateStr = _dateText(booking);
    final address = _address(booking);

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

String _companyName(BuildContext context, BookingRequest booking) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  final company = booking.company ?? booking.trip?.company;
  if (company == null) return '—';
  if (isRtl) {
    return company.nameAr ?? company.fullName ?? company.nameEn ?? '—';
  }
  return company.nameEn ?? company.fullName ?? company.nameAr ?? '—';
}

String _dateText(BookingRequest booking) {
  final raw = booking.trip?.startDate;
  final parsed = raw == null ? booking.createdAt : DateTime.tryParse(raw);
  final date = parsed ?? booking.createdAt;
  if (date == null) return '—';
  return DateFormat('dd-MM-yyyy hh:mm a').format(date.toLocal());
}

String _address(BookingRequest booking) {
  final waypoints = booking.trip?.waypoints;
  if (waypoints != null && waypoints.isNotEmpty) {
    final named = waypoints
        .map((w) => w.addressName)
        .whereType<String>()
        .where((name) => name.trim().isNotEmpty);
    if (named.isNotEmpty) return named.first;
  }
  final destination = booking.trip?.contractDestination;
  return destination?.nameAr ?? destination?.nameEn ?? '—';
}

Status _statusFor(BookingRequest booking, List<Status> statuses) {
  final code = booking.status ?? booking.trip?.status;
  if (code != null) {
    for (final status in statuses) {
      if (status.code == code) return status;
    }
  }

  final name = booking.statusName ?? booking.trip?.tripStatusName;
  if (name != null && name.trim().isNotEmpty) {
    final lower = name.toLowerCase();
    for (final status in statuses) {
      if (status.name.toLowerCase() == lower) return status;
    }
    return Status(
      name: name,
      code: code,
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
      color: CupertinoColors.systemPink,
      icon: CupertinoIcons.table_fill,
    ),
    Status(
      name: l10n.inProgress,
      code: 5,
      color: CupertinoColors.activeOrange,
      icon: CupertinoIcons.slowmo,
    ),
    Status(
      name: l10n.completed,
      code: 6,
      color: CupertinoColors.activeGreen,
      icon: CupertinoIcons.checkmark_alt,
    ),
    Status(
      name: l10n.reviewed,
      code: 7,
      color: CupertinoColors.systemTeal,
      icon: CupertinoIcons.doc_checkmark_fill,
    ),
    Status(
      name: l10n.cancelled,
      code: 8,
      color: CupertinoColors.systemRed,
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
