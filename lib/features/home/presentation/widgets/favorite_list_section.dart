import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/gen/app_localizations.dart';

class FavoriteListSection extends StatelessWidget {
  const FavoriteListSection({
    super.key,
    required this.requestedCount,
    required this.bookedCount,
  });

  final int requestedCount;
  final int bookedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.favoriteList,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 10),
        _FavoriteListCard(
          title: l10n.requestedTransfersCount(requestedCount.toString()),
          icon: Icons.local_shipping_outlined,
          showBadge: requestedCount > 0,
          emphasized: true,
        ),
        const SizedBox(height: 8),
        _FavoriteListCard(
          title: l10n.bookedTransfersCount(bookedCount.toString()),
          icon: CupertinoIcons.cube_box,
          showBadge: false,
          emphasized: false,
        ),
      ],
    );
  }
}

class _FavoriteListCard extends StatelessWidget {
  const _FavoriteListCard({
    required this.title,
    required this.icon,
    required this.showBadge,
    required this.emphasized,
  });

  final String title;
  final IconData icon;
  final bool showBadge;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          _IconBadge(icon: icon, showBadge: showBadge, emphasized: emphasized),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: emphasized ? AppColors.mainBlue : AppColors.darkGray,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _PreviewButton(label: l10n.preview),
        ],
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  const _PreviewButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mainBlue),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.mainBlue,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.showBadge,
    required this.emphasized,
  });

  final IconData icon;
  final bool showBadge;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final iconColor = emphasized
        ? AppColors.mainBlue
        : AppColors.mediumBlueGray;
    final backgroundColor = emphasized
        ? const Color(0xFFEFF7FF)
        : const Color(0xFFF2F4F6);

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          if (showBadge)
            const Positioned(
              top: -2,
              right: -2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.mainBlue,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 8, height: 8),
              ),
            ),
        ],
      ),
    );
  }
}
