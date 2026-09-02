import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_nav_bar.dart';
import '../../../../core/widgets/main_scaffold.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../trips/presentation/bloc/booking_request_bloc.dart';
import '../../../trips/presentation/bloc/booking_request_event.dart';
import '../../../trips/presentation/bloc/booking_request_state.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_event.dart';
import '../../../trips/presentation/bloc/trip_state.dart';
import '../widgets/favorite_list_section.dart';
import '../widgets/trip_request_card.dart';
import '../widgets/trip_review_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tripIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TripBloc>().add(GetTrips());
    context.read<BookingRequestBloc>().add(GetBookingRequests());
  }

  @override
  void dispose() {
    _tripIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {}
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
                      _tripIdCard(l10n: l10n),
                      const SizedBox(height: 16),
                      BlocBuilder<TripBloc, TripState>(
                        builder: (context, tripState) {
                          final requestedCount = tripState is TripLoaded
                              ? tripState.totalCount
                              : 0;
                          return BlocBuilder<
                            BookingRequestBloc,
                            BookingRequestState
                          >(
                            builder: (context, bookingState) {
                              final bookedCount =
                                  bookingState is BookingRequestLoaded
                                  ? bookingState.totalCount
                                  : 0;
                              return FavoriteListSection(
                                requestedCount: requestedCount,
                                bookedCount: bookedCount,
                                onRequestedPreview: () => context.go(
                                  AppRoutePaths.requestsPath(booked: false),
                                ),
                                onBookedPreview: () => context.go(
                                  AppRoutePaths.requestsPath(booked: true),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Title(title: l10n.requestedTransfers, fontSize: 16),
                          CupertinoButton(
                            onPressed: () => context.go(
                              AppRoutePaths.requestsPath(booked: false),
                            ),
                            padding: EdgeInsets.zero,
                            child: _Title(
                              title: l10n.showAll,
                              fontSize: 16,
                              color: AppColors.mainBlue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      BlocBuilder<TripBloc, TripState>(
                        builder: (context, state) {
                          if (state is TripLoaded) {
                            if (state.trips.isEmpty) {
                              return Center(child: Text(l10n.tripsRequest));
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.trips.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                return TripRequestCard(
                                  trip: state.trips[index],
                                );
                              },
                            );
                          }

                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.mainBlue,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _Title(title: l10n.tripsReview, fontSize: 16),
                      const SizedBox(height: 10),
                      BlocBuilder<BookingRequestBloc, BookingRequestState>(
                        builder: (context, state) {
                          if (state is BookingRequestLoaded) {
                            if (state.requests.isEmpty) {
                              return Center(child: Text(l10n.tripsReview));
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.requests.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                return TripReviewCard(
                                  booking: state.requests[index],
                                );
                              },
                            );
                          }

                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.mainBlue,
                              ),
                            ),
                          );
                        },
                      ),
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

  Widget _tripIdField({required AppLocalizations l10n}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: CupertinoTextField(
        controller: _tripIdController,
        placeholder: l10n.enterTripID,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: null,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.darkGray,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _tripIdCard({required AppLocalizations l10n}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: _Title(title: l10n.trackTheTrip, fontSize: 16),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: Directionality.of(context) == TextDirection.rtl
                      ? const EdgeInsets.only(right: 15)
                      : const EdgeInsets.only(left: 15),
                  child: _SubTitle(title: l10n.trackTheTripDesc, fontSize: 12),
                ),
              ),
              Image.asset(
                Directionality.of(context) == TextDirection.rtl
                    ? 'assets/images/home_truck_ar.png'
                    : 'assets/images/home_truck_en.png',
                width: 150,
                height: 100,
                fit: BoxFit.contain,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: _tripIdField(l10n: l10n),
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
    this.decoration,
  });

  final String title;
  final double fontSize;
  final Color color;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w400,
        decoration: decoration,
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
