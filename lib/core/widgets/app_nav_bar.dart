import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../theme/app_colors.dart';

// class AppNavBar extends StatelessWidget
//     implements ObstructingPreferredSizeWidget {
//   final Widget? trailng;
//   const AppNavBar({super.key, this.trailng});

//   @override
//   Widget build(BuildContext context) {
//     return CupertinoNavigationBar(
//       backgroundColor: AppColors.mainBlue,
//       enableBackgroundFilterBlur: false,
//       leading: SvgPicture.asset('assets/images/logo.svg'),
//       trailing: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           ?trailng,
//           CupertinoButton(
//             padding: EdgeInsets.zero,
//             onPressed: () {},
//             child: SvgPicture.asset('assets/images/notification.svg'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(50);

//   @override
//   bool shouldFullyObstruct(BuildContext context) {
//     return true;
//   }
// }

class AppNavBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  const AppNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mainBlue,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              SvgPicture.asset('assets/images/logo.svg'),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                child: SvgPicture.asset('assets/images/notification.svg'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;
}
