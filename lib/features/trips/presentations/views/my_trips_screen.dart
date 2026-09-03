import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_nav_bar.dart';
import '../../../../core/widgets/main_scaffold.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../home/presentation/widgets/trip_review_card.dart';
import '../../domain/entities/trip/trip.dart';
import '../../presentation/bloc/trip_bloc.dart';
import '../../presentation/bloc/trip_event.dart';
import '../../presentation/bloc/trip_state.dart';

const _kScheduled = 2;
const _kInProgress = 5;
const _kCompleted = 6;
const _kCancelled = 8;

const _myTripStatuses = {_kScheduled, _kInProgress, _kCompleted, _kCancelled};

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TripBloc>().add(GetTrips(pageSize: 50));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                      const _StatsHeader(),
                      const SizedBox(height: 12),
                      _SearchRow(
                        controller: _searchController,
                        placeholder: l10n.searchForTrip,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.tripsReview,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _MyTripsList(query: _searchController.text),
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
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TripBloc, TripState>(
      builder: (context, tripState) {
        final trips = tripState is TripLoaded
            ? _myTrips(tripState.trips)
            : const <Trip>[];
        final stats = _TripStats.from(trips);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
          child: Row(
            children: [
              Expanded(
                child: _StatCell(
                  count: stats.notStarted,
                  label: l10n.notStarted,
                  color: AppColors.newgreen,
                ),
              ),
              Expanded(
                child: _StatCell(
                  count: stats.inProgress,
                  label: l10n.inProgress,
                  color: AppColors.orange,
                ),
              ),
              Expanded(
                child: _StatCell(
                  count: stats.finished,
                  label: l10n.finishedTransfers,
                  color: AppColors.mainBlue,
                ),
              ),
              Expanded(
                child: _StatCell(
                  count: stats.cancelled,
                  label: l10n.cancellations,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.placeholder,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              controller: controller,
              placeholder: placeholder,
              onChanged: (_) => onChanged(),
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
            onPressed: () {},
            child: SvgPicture.asset('assets/images/filter.svg'),
          ),
        ),
      ],
    );
  }
}

class _MyTripsList extends StatelessWidget {
  const _MyTripsList({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TripBloc, TripState>(
      builder: (context, tripState) {
        if (tripState is TripInitial || tripState is TripLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.mainBlue),
            ),
          );
        }

        if (tripState is TripError) {
          return Center(child: Text(tripState.message));
        }

        final trips = tripState is TripLoaded
            ? _myTrips(tripState.trips)
            : const <Trip>[];
        final filtered = _filterTrips(context, trips, query);

        if (filtered.isEmpty) {
          return Center(child: Text(l10n.noTripsAvailable));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return TripReviewCard(trip: filtered[index]);
          },
        );
      },
    );
  }
}

class _TripStats {
  const _TripStats({
    required this.notStarted,
    required this.inProgress,
    required this.finished,
    required this.cancelled,
  });

  final int notStarted;
  final int inProgress;
  final int finished;
  final int cancelled;

  factory _TripStats.from(List<Trip> trips) {
    var notStarted = 0;
    var inProgress = 0;
    var finished = 0;
    var cancelled = 0;

    for (final trip in trips) {
      switch (trip.status) {
        case _kScheduled:
          notStarted++;
        case _kInProgress:
          inProgress++;
        case _kCompleted:
          finished++;
        case _kCancelled:
          cancelled++;
      }
    }

    return _TripStats(
      notStarted: notStarted,
      inProgress: inProgress,
      finished: finished,
      cancelled: cancelled,
    );
  }
}

List<Trip> _myTrips(List<Trip> trips) {
  final items = trips
      .where((trip) => _myTripStatuses.contains(trip.status))
      .toList();
  items.sort((a, b) {
    final aDate = DateTime.tryParse(a.startDate ?? '') ?? a.createdAt;
    final bDate = DateTime.tryParse(b.startDate ?? '') ?? b.createdAt;
    return (bDate ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
      aDate ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  });
  return items;
}

List<Trip> _filterTrips(BuildContext context, List<Trip> trips, String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return trips;

  final isRtl = Directionality.of(context) == TextDirection.rtl;
  return trips.where((trip) {
    final company = trip.company;
    final companyName = isRtl
        ? company?.nameAr ?? company?.fullName ?? company?.nameEn ?? ''
        : company?.nameEn ?? company?.fullName ?? company?.nameAr ?? '';
    final haystack = '${trip.id ?? ''} $companyName'.toLowerCase();
    return haystack.contains(trimmed.toLowerCase());
  }).toList();
}
