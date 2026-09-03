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
import '../../../home/presentation/widgets/trip_request_card.dart';
import '../../../home/presentation/widgets/trip_review_card.dart';
import '../../../trips/domain/entities/booking_request/booking_request.dart';
import '../../../trips/domain/exclude_booked_trips.dart';
import '../../../trips/presentation/bloc/booking_request_bloc.dart';
import '../../../trips/presentation/bloc/booking_request_event.dart';
import '../../../trips/presentation/bloc/booking_request_state.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_event.dart';
import '../../../trips/presentation/bloc/trip_state.dart';
import 'transfers_list_type.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, required this.listType});

  final TransfersListType listType;

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.listType.isBooked) {
      context.read<BookingRequestBloc>().add(
        GetBookingRequests(pageSize: 50),
      );
    } else {
      context.read<TripBloc>().add(GetTrips(pageSize: 50, status: 1));
      context.read<BookingRequestBloc>().add(
        GetBookingRequests(pageSize: 50),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBooked = widget.listType.isBooked;

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
                      if (!isBooked) ...[
                        const _RequestedHeaderCard(),
                        const SizedBox(height: 12),
                      ],
                      _SearchRow(
                        controller: _searchController,
                        placeholder: l10n.searchForTrip,
                      ),
                      const SizedBox(height: 12),
                      _Title(
                        title: isBooked
                            ? l10n.tripsReview
                            : l10n.requestedTransfers,
                        fontSize: 16,
                      ),
                      const SizedBox(height: 10),
                      if (isBooked)
                        const _BookedTripsList()
                      else
                        const _RequestedTripsList(),
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

class _RequestedHeaderCard extends StatelessWidget {
  const _RequestedHeaderCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        return BlocBuilder<BookingRequestBloc, BookingRequestState>(
          builder: (context, bookingState) {
            final bookings = bookingState is BookingRequestLoaded
                ? bookingState.requests
                : const <BookingRequest>[];
            final count = state is TripLoaded
                ? requestedCountExcludingBooked(
                    trips: state.trips,
                    totalCount: state.totalCount,
                    bookings: bookings,
                  )
                : 0;
            return _HeaderShell(
              child: CupertinoListTile(
                padding: EdgeInsets.zero,
                leading: SvgPicture.asset(
                  'assets/images/requests.svg',
                  width: 28,
                  height: 28,
                  colorFilter: const ColorFilter.mode(
                    AppColors.mainBlue,
                    BlendMode.srcIn,
                  ),
                ),
                title: _Title(
                  title: l10n.newTripRequestsCount(count.toString()),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                subtitle: _SubTitle(
                  title: l10n.allYourTripRequests,
                  fontSize: 12,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HeaderShell extends StatelessWidget {
  const _HeaderShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
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
      child: child,
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.controller, required this.placeholder});

  final TextEditingController controller;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Row(
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
                readOnly: true,
                style: const TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefix: SvgPicture.asset('assets/images/search.svg'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
      ),
    );
  }
}

class _RequestedTripsList extends StatelessWidget {
  const _RequestedTripsList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        if (state is TripError) {
          return Center(child: Text(state.message));
        }

        if (state is TripLoaded) {
          return BlocBuilder<BookingRequestBloc, BookingRequestState>(
            builder: (context, bookingState) {
              final bookings = bookingState is BookingRequestLoaded
                  ? bookingState.requests
                  : const <BookingRequest>[];
              final trips = excludeBookedTrips(state.trips, bookings);
              if (trips.isEmpty) {
                return Center(child: Text(l10n.noTripsAvailable));
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trips.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return TripRequestCard(trip: trips[index]);
                },
              );
            },
          );
        }

        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.mainBlue),
          ),
        );
      },
    );
  }
}

class _BookedTripsList extends StatelessWidget {
  const _BookedTripsList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<BookingRequestBloc, BookingRequestState>(
      builder: (context, state) {
        if (state is BookingRequestError) {
          return Center(child: Text(state.message));
        }

        if (state is BookingRequestLoaded) {
          if (state.requests.isEmpty) {
            return Center(child: Text(l10n.noTripsAvailable));
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.requests.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return TripReviewCard(booking: state.requests[index]);
            },
          );
        }

        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.mainBlue),
          ),
        );
      },
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
