import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../trips/data/models/trip_model.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';

class TripRequestCard extends StatelessWidget {
  const TripRequestCard({super.key, required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = DateFormat('dd-MM-yyyy hh:mm a').format(trip.startDate.toLocal());
    final cost = trip.spotPrice ?? trip.cargoPrice;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.mainBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.time, color: AppColors.white, size: 20),
              const SizedBox(width: 10),
              _Title(
                title: l10n.sunwayAdminSendThisTripFromAgo,
                fontSize: 12,
                color: AppColors.white,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Title(
                  title: trip.companyName ?? trip.referenceNumber,
                  fontSize: 16,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Title(title: l10n.tripDate, fontSize: 12),
                    const SizedBox(width: 10),
                    _SubTitle(
                      title: dateStr,
                      fontSize: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.mainGray),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _SubTitle(title: l10n.tripFrom, fontSize: 12),
                            _Title(
                              title: trip.fromLocation ?? '—',
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            _SubTitle(title: l10n.tripTo, fontSize: 12),
                            _Title(
                              title: trip.toLocation ?? '—',
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.mainGray),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _SubTitle(title: l10n.vehicleType, fontSize: 12),
                            _Title(
                              title: trip.vehicleTypeName ?? '—',
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            _SubTitle(title: l10n.tripCost, fontSize: 12),
                            _Title(
                              title: cost != null
                                  ? '${cost.toStringAsFixed(0)} جنيه'
                                  : '—',
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                AppButton(
                  onPressed: () {
                     context.go(
      AppRoutePaths.bookTrip,
      extra: trip,
    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Title(
                        title: l10n.bookTrip,
                        fontSize: 14,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        CupertinoIcons.add_circled_solid,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.title,
    required this.fontSize,
    this.color = AppColors.darkGray,
  });

  final String title;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({required this.title, required this.fontSize});

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        color: CupertinoColors.systemGrey,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}