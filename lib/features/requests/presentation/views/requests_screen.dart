import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_nav_bar.dart';
import '../../../../core/widgets/main_scaffold.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../widgets/trip_request_card.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _searchController = TextEditingController();
  final _filterController = TextEditingController();
  int _selectedTabIndex = 0;
  DateTime? dateFilter;

  @override
  void dispose() {
    _searchController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _showFilter(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Local copy of the date, initially from parent
    DateTime? localDate = dateFilter;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // This setModalState rebuilds ONLY the modal content.
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Title(
                          title: l10n.filter,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(height: 12),
                        _Title(title: l10n.searchForPlace, fontSize: 16),
                        const SizedBox(height: 10),
                        _SubTitle(title: l10n.searchForPlaceDesc, fontSize: 14),
                        const SizedBox(height: 10),
                        _filterField(l10n: l10n),
                        const SizedBox(height: 12),
                        _Title(title: l10n.tripDate, fontSize: 16),
                        const SizedBox(height: 10),
                        // ✅ Use localDate, not parent's dateFilter
                        _buildDateField(context, localDate, (newDate) {
                          // Update local date and rebuild the modal
                          setModalState(() {
                            localDate = newDate;
                          });
                          // Optionally also update the date picker if it's open,
                          // but we don't need to.
                        }),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            onPressed: () {
                              // ✅ Apply the filter: update parent state and close
                              setState(() {
                                dateFilter = localDate;
                              });
                              Navigator.pop(context);
                            },
                            label: l10n.applyFilter,
                          ),
                        ),
                        Center(
                          child: CupertinoButton(
                            onPressed: () {
                              // Clear filter: set localDate to null and update parent
                              setModalState(() {
                                localDate = null;
                              });
                              setState(() {
                                dateFilter = null;
                              });
                              Navigator.pop(context);
                            },
                            child: _SubTitle(
                              title: l10n.clearFilter,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutePaths.home);
        }
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthUnauthenticated) {
            context.go(AppRoutePaths.login);
          }
        },
        child: CupertinoPageScaffold(
          backgroundColor: AppColors.white,
          navigationBar: const AppNavBar(),
          child: MainScaffold(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentGeometry.topCenter,
                    end: AlignmentGeometry.center,
                    stops: [0.2, 0.2],
                    colors: [AppColors.mainBlue, AppColors.white],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _headerCard(l10n: l10n),
                      const SizedBox(height: 12),
                      _requestsSearchField(l10n: l10n),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _TabButton(
                              label: l10n.newRequests,
                              isSelected: _selectedTabIndex == 0,
                              onTap: () {
                                setState(() => _selectedTabIndex = 0);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TabButton(
                              label: l10n.alreadyBooked,
                              isSelected: _selectedTabIndex == 1,
                              onTap: () {
                                setState(() => _selectedTabIndex = 1);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _Title(title: l10n.tripsRequest, fontSize: 16),
                      const SizedBox(height: 10),
                      TripRequestCard(selectedTabIndex: _selectedTabIndex),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _requestsSearchField({required AppLocalizations l10n}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.lightGray),
            ),
            child: CupertinoTextField(
              controller: _searchController,
              placeholder: l10n.searchForTrip,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              style: const TextStyle(
                color: AppColors.darkGray,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefix: SvgPicture.asset('assets/images/search.svg'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: null,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.mediumBlueGray, width: 0.5),
            borderRadius: BorderRadius.circular(50),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(50),
            color: AppColors.white,
            onPressed: () => _showFilter(context),
            child: SvgPicture.asset('assets/images/filter.svg'),
          ),
        ),
      ],
    );
  }

  Widget _headerCard({required AppLocalizations l10n}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoListTile(
            leading: SvgPicture.asset(
              'assets/images/requests.svg',
              colorFilter: const ColorFilter.mode(
                AppColors.mainBlue,
                BlendMode.srcIn,
              ),
            ),
            title: _Title(title: l10n.tripsRequest, fontSize: 14),
            subtitle: _SubTitle(title: l10n.tripsRequestDesc, fontSize: 12),
          ),
          const Divider(color: AppColors.mainGray),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const _Title(title: '12', fontSize: 16),
                  _SubTitle(title: l10n.tripInProgress, fontSize: 12),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const _Title(title: '67', fontSize: 16),
                  _Title(title: l10n.tripRequest, fontSize: 12),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterField({required AppLocalizations l10n}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: CupertinoTextField(
        controller: _filterController,
        placeholder: l10n.movingFrom,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: null,
        prefix: SvgPicture.asset('assets/images/location.svg'),
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.darkGray,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    DateTime? date,
    Function(DateTime) onDateChanged,
  ) {
    return GestureDetector(
      onTap: () => _showDatePicker(context, date, onDateChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGray),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.calendar,
              size: 20,
              color: AppColors.darkGray,
            ),
            const SizedBox(width: 10),
            _SubTitle(
              title: date == null
                  ? AppLocalizations.of(context)!.tripDate
                  : DateFormat('yyyy-MM-dd').format(date),
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(
    BuildContext context,
    DateTime? date,
    Function(DateTime) onDateChanged,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      if (date == null) {
                        onDateChanged(DateTime.now());
                      }
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.ok),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (dateTime) {
                  setState(() {
                    date = dateTime;
                    onDateChanged(dateTime);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.title,
    required this.fontSize,
    this.fontWeight = FontWeight.w400,
  });

  final String title;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppColors.darkGray,
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

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.mainBlue : AppColors.mainGray,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: isSelected
            ? AppColors.mainBlue.withValues(alpha: 0.05)
            : AppColors.mainGray,
        borderRadius: BorderRadius.circular(12),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isSelected ? AppColors.mainBlue : AppColors.darkGray,
          ),
        ),
      ),
    );
  }
}
