import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../trips/domain/entities/trip/trip.dart';

class TripRequestCard extends StatelessWidget {
  const TripRequestCard({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final companyName = isRtl
        ? trip.company?.nameAr ?? trip.company?.fullName ?? trip.company?.nameEn
        : trip.company?.nameEn ??
              trip.company?.fullName ??
              trip.company?.nameAr;
    final vehicleName = isRtl
        ? trip.contractVehicleType?.vehicleType?.nameAr ??
              trip.contractVehicleType?.vehicleType?.name ??
              trip.contractVehicleType?.vehicleType?.nameEn
        : trip.contractVehicleType?.vehicleType?.nameEn ??
              trip.contractVehicleType?.vehicleType?.name ??
              trip.contractVehicleType?.vehicleType?.nameAr;
    final dateStr = _dateText(trip.startDate);
    final cost = trip.spotPrice ?? trip.cargoPrice;
    final priceText = cost == null
        ? '—'
        : NumberFormat('#,###').format(cost.round()).replaceAll(',', '.');
    final waypoints = trip.waypoints;
    final from = (waypoints != null && waypoints.isNotEmpty)
        ? waypoints.first.addressName ?? '—'
        : '—';
    final to = (waypoints != null && waypoints.isNotEmpty)
        ? waypoints.last.addressName ?? '—'
        : '—';
    final tripId = trip.id;
    final title = [
      companyName ?? '—',
      if (tripId != null) '#$tripId',
    ].join(' ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mainBlue, width: 10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(maxWidth: 140),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.mainBlue),
                ),
                child: Text(
                  '${l10n.tripValue}: $priceText',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${l10n.tripDate} $dateStr',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7A8A99),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledValue(label: l10n.tripTo, value: to),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabeledValue(label: l10n.tripFrom, value: from),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledValue(label: l10n.vehicleType, value: vehicleName ?? '—'),
              ),
              const SizedBox(width: 8),
              AppButton(
                  minSize: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  onPressed: () {
                    context.go(AppRoutePaths.bookTrip, extra: trip);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.add_circled_solid,
                        color: AppColors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.requestTripBooking,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // const SizedBox(height: 14),
        ],
      ),
    );
  }

  String _dateText(String? startDate) {
    final parsed = startDate == null ? null : DateTime.tryParse(startDate);
    if (parsed == null) return '—';
    return DateFormat('hh:mm a • dd-MM-yyyy').format(parsed.toLocal());
  }
}

class _LabeledValue extends StatelessWidget {
  const _LabeledValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7A8A99),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            softWrap: true,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}
