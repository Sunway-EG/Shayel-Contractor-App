import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/gen/app_localizations.dart';

class TripRequestCard extends StatelessWidget {
  final int selectedTabIndex;
  const TripRequestCard({super.key, required this.selectedTabIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selectedTabIndex == 0 ? AppColors.mainBlue : AppColors.green,
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
                const _Title(title: 'شركة عبور لاند', fontSize: 16),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Title(title: l10n.tripDate, fontSize: 12),
                    const SizedBox(width: 10),
                    const _SubTitle(
                      title: '24-08-20226 04:40 PM',
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
                            const _Title(
                              title: 'سيدي بشر اسكندرية',
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            _SubTitle(title: l10n.tripTo, fontSize: 12),
                            const _Title(
                              title: 'الجيزة ابو رواش',
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
                            const _Title(title: 'تريلا فرش', fontSize: 14),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            _SubTitle(title: l10n.tripCost, fontSize: 12),
                            const _Title(title: '14,000 جنيه ', fontSize: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                AppButton(
                  onPressed: () {},
                  color: selectedTabIndex == 0
                      ? AppColors.mainBlue
                      : CupertinoColors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Title(
                        title: selectedTabIndex == 0
                            ? l10n.bookTrip
                            : l10n.alreadyBooked,
                        fontSize: 14,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        selectedTabIndex == 0
                            ? CupertinoIcons.add_circled_solid
                            : Directionality.of(context) == TextDirection.rtl
                            ? CupertinoIcons.chevron_back
                            : CupertinoIcons.chevron_forward,
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
