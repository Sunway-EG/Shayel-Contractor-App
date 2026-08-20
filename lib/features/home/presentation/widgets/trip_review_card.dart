import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/gen/app_localizations.dart';

class TripReviewCard extends StatelessWidget {
  const TripReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Status> statuses = [
      Status(
        name: AppLocalizations.of(context)!.all,
        code: null,
        color: CupertinoColors.activeBlue,
        icon: CupertinoIcons.infinite,
      ),
      Status(
        name: AppLocalizations.of(context)!.requested,
        code: 0,
        color: CupertinoColors.systemIndigo,
        icon: CupertinoIcons.paperplane_fill,
      ),
      Status(
        name: AppLocalizations.of(context)!.pending,
        code: 1,
        color: CupertinoColors.systemPurple,
        icon: CupertinoIcons.bookmark_fill,
      ),
      Status(
        name: AppLocalizations.of(context)!.scheduled,
        code: 2,
        color: CupertinoColors.systemPink,
        icon: CupertinoIcons.table_fill,
      ),
      Status(
        name: AppLocalizations.of(context)!.inProgress,
        code: 5,
        color: CupertinoColors.activeOrange,
        icon: CupertinoIcons.slowmo,
      ),
      Status(
        name: AppLocalizations.of(context)!.completed,
        code: 6,
        color: CupertinoColors.activeGreen,
        icon: CupertinoIcons.checkmark_alt,
      ),
      Status(
        name: AppLocalizations.of(context)!.reviewed,
        code: 7,
        color: CupertinoColors.systemTeal,
        icon: CupertinoIcons.doc_checkmark_fill,
      ),
      Status(
        name: AppLocalizations.of(context)!.cancelled,
        code: 8,
        color: CupertinoColors.systemRed,
        icon: CupertinoIcons.xmark,
      ),
      Status(
        name: AppLocalizations.of(context)!.draft,
        code: -1,
        color: CupertinoColors.systemMint,
        icon: CupertinoIcons.doc_fill,
      ),
    ];
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
              title: '${l10n.trip} #123',
              fontSize: 14,
              color: AppColors.darkGray,
            ),
            subtitle: const _Title(title: 'اسم الشركة', fontSize: 14),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: statuses
                    .firstWhere((element) => element.code == 5)
                    .color
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                statuses.firstWhere((element) => element.code == 5).name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statuses
                      .firstWhere((element) => element.code == 5)
                      .color,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width * 0.2,
            ),
            child: const _Title(title: '24-08-20226 04:40 PM', fontSize: 14),
          ),
          CupertinoListTile(
            leading: SvgPicture.asset('assets/images/location.svg'),
            leadingSize: 40,
            title: const _Title(
              title: '789 شارع النموذج، ليكفيو، ZZ 34567',
              fontSize: 14,
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
    this.color = CupertinoColors.systemGrey,
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

class Status {
  String name;
  int? code;
  Color color;
  IconData icon;

  Status({
    required this.name,
    required this.code,
    required this.color,
    required this.icon,
  });
}
