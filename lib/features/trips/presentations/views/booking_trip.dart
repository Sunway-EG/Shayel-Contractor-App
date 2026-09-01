import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog_presenter.dart';
import '../../../../core/widgets/main_scaffold.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../drivers/data/models/driver_model.dart';
import '../../../drivers/presentation/bloc/driver_bloc.dart';
import '../../../drivers/presentation/bloc/driver_event.dart';
import '../../../drivers/presentation/bloc/driver_state.dart';
import '../../../trips/data/models/trip_model.dart';
import '../../../trips/presentation/bloc/booking_request_bloc.dart';
import '../../../trips/presentation/bloc/booking_request_event.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_event.dart';
import '../../../trips/presentation/bloc/trip_state.dart';

class BookingTripScreen extends StatefulWidget {
  const BookingTripScreen({super.key, this.trip});

  final TripModel? trip;

  @override
  State<BookingTripScreen> createState() => _BookingTripScreenState();
}

class _BookingTripScreenState extends State<BookingTripScreen> {
  DriverModel? _selectedDriver;
  bool _showSelectDriverHint = false;
  Timer? _selectDriverHintTimer;
  late TripModel? _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    final tripId = widget.trip?.id;
    if (tripId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTripDetails(tripId);
      });
    }
  }

  Future<void> _loadTripDetails(int tripId) async {
    try {
      final trip = await context.read<TripBloc>().getTripDetails(tripId);
      if (!mounted) return;
      setState(() {
        final current = _trip;
        _trip = current == null ? trip : current.mergedWith(trip);
      });
    } catch (error, stackTrace) {
      developer.log(
        'GetTrip failed: $error',
        name: 'TripJson',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void dispose() {
    _selectDriverHintTimer?.cancel();
    super.dispose();
  }

  void _showSelectDriverMessage() {
    _selectDriverHintTimer?.cancel();
    setState(() => _showSelectDriverHint = true);
    _selectDriverHintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSelectDriverHint = false);
    });
  }

  void _bookTrip() {
    final trip = _trip;
    final driver = _selectedDriver;

    if (trip == null) return;

    if (driver == null) {
      _showSelectDriverMessage();
      return;
    }

    context.read<TripBloc>().add(
      BookTrip(tripId: trip.id, driverId: driver.id),
    );
  }

  void _showBookingSuccessDialog() {
    final l10n = AppLocalizations.of(context)!;

    showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: false,
      builder: (bottomSheetContext) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/register_success.svg',
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.tripBookedTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.tripBookedMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    onPressed: () {
                      Navigator.of(bottomSheetContext).pop();
                      context.read<TripBloc>().add(GetTrips());
                      context.read<BookingRequestBloc>().add(
                        GetBookingRequests(),
                      );
                      context.go(AppRoutePaths.home);
                    },
                    label: l10n.goToHomepage,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<TripBloc, TripState>(
      listenWhen: (previous, current) =>
          current is TripBooked || current is TripBookError,
      listener: (context, state) {
        if (state is TripBooked) {
          _showBookingSuccessDialog();
        } else if (state is TripBookError) {
          showAppAlertDialog(
            context: context,
            title: l10n.bookTrip,
            message: state.message,
          );
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        child: MainScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(title: l10n.bookTrip, onBack: () => context.go(AppRoutePaths.home)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                  child: _TripCard(
                    trip: _trip,
                    selectedDriver: _selectedDriver,
                    onDriverSelected: (driver) {
                      _selectDriverHintTimer?.cancel();
                      setState(() {
                        _selectedDriver = driver;
                        _showSelectDriverHint = false;
                      });
                    },
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_showSelectDriverHint) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l10n.selectDriver,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      BlocBuilder<TripBloc, TripState>(
                        builder: (context, state) {
                          final isBooking = state is TripBooking;
                          return SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              loading: isBooking,
                              onPressed: _trip == null ? null : _bookTrip,
                              label: l10n.bookTrip,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.mainBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PositionedDirectional(
                start: 8,
                child: AppBackButton(onPressed: onBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.onDriverSelected,
    this.trip,
    this.selectedDriver,
  });

  final TripModel? trip;
  final DriverModel? selectedDriver;
  final ValueChanged<DriverModel> onDriverSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const _WarningBanner(),
          const SizedBox(height: 8),
          _CompanySection(name: trip?.companyName ?? trip?.referenceNumber),
          const SizedBox(height: 8),
          _DateSection(date: trip?.startDate),
          const SizedBox(height: 8),
          _PointsSection(
            from: trip?.fromLocation,
            to: trip?.toLocation,
          ),
          const SizedBox(height: 8),
          _VehicleSection(name: trip?.vehicleTypeName),
          const SizedBox(height: 8),
          _PriceSection(price: trip?.spotPrice ?? trip?.cargoPrice),
          _DriverSection(
            selectedDriver: selectedDriver,
            onDriverSelected: onDriverSelected,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF5FAFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.clock, color: Color(0xFF0874C9), size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.sunwayAdminSendThisTripFromAgo,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Color(0xFF0874C9),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanySection extends StatelessWidget {
  const _CompanySection({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5FF),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              CupertinoIcons.building_2_fill,
              size: 15,
              color: Color(0xFF0874C9),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name?.isNotEmpty == true ? name! : '—',
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181818),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSection extends StatelessWidget {
  const _DateSection({this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = date == null
        ? '—'
        : DateFormat('dd-MM-yyyy  •  hh:mm a').format(date!.toLocal());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E9ED)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            l10n.tripDate,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF858585),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF777777),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsSection extends StatelessWidget {
  const _PointsSection({this.from, this.to});

  final String? from;
  final String? to;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E9ED)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PointItem(
              title: l10n.pickupPoint,
              value: from?.isNotEmpty == true ? from! : '—',
            ),
          ),
          Container(width: 1, height: 45, color: const Color(0xFFE5E5E5)),
          Expanded(
            child: _PointItem(
              title: l10n.dropoffPoint,
              value: to?.isNotEmpty == true ? to! : '—',
            ),
          ),
        ],
      ),
    );
  }
}

class _PointItem extends StatelessWidget {
  const _PointItem({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF969696),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF222222),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _VehicleSection extends StatelessWidget {
  const _VehicleSection({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E9ED)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8FE),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              CupertinoIcons.car_detailed,
              color: Color(0xFF0874C9),
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name?.isNotEmpty == true ? name! : '—',
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF222222),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            l10n.vehicleType,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF969696),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({this.price});

  final double? price;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formatted = price == null
        ? '—'
        : l10n.priceInEgp(
            NumberFormat('#,###').format(price!.round()),
          );

    return Container(
      height: 49,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E9ED)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Text(
            formatted,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF222222),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            l10n.tripCost,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF333333),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverSection extends StatefulWidget {
  const _DriverSection({
    required this.onDriverSelected,
    this.selectedDriver,
  });

  final DriverModel? selectedDriver;
  final ValueChanged<DriverModel> onDriverSelected;

  @override
  State<_DriverSection> createState() => _DriverSectionState();
}

class _DriverSectionState extends State<_DriverSection> {
  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(GetDrivers());
  }

  Future<void> _openDriversSheet() async {
    final selected = await showCupertinoModalPopup<DriverModel>(
      context: context,
      builder: (sheetContext) => _DriversSheet(
        initiallySelected: widget.selectedDriver,
      ),
    );

    if (selected != null) {
      widget.onDriverSelected(selected);
    }
  }

  Future<void> _openAddDriver() async {
    final created = await context.push<DriverModel?>(AppRoutePaths.addDriver);
    if (created != null && mounted) {
      widget.onDriverSelected(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final driverName = widget.selectedDriver == null
        ? l10n.chooseDriverPlaceholder
        : _driverDisplayName(widget.selectedDriver!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.selectDriver,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF222222),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            onTap: _openDriversSheet,
            child: Container(
              height: 57,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E9ED)),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Container(
                    width: 41,
                    height: 41,
                    margin: const EdgeInsets.symmetric(horizontal: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F8FE),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      CupertinoIcons.person_crop_rectangle,
                      color: Color(0xFF0874C9),
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      driverName,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFDADADA)),
                    ),
                    child: const Icon(
                      CupertinoIcons.add,
                      size: 17,
                      color: Color(0xFF222222),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.driversFromYourList,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF999999),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            onTap: _openAddDriver,
            child: Container(
              height: 38,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.add,
                    size: 17,
                    color: Color(0xFF0874C9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.tapToAddNewDriver,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0874C9),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriversSheet extends StatefulWidget {
  const _DriversSheet({this.initiallySelected});

  final DriverModel? initiallySelected;

  @override
  State<_DriversSheet> createState() => _DriversSheetState();
}

class _DriversSheetState extends State<_DriversSheet> {
  late final TextEditingController _searchController;
  DriverModel? _tempSelected;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tempSelected = widget.initiallySelected;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDADADA),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.selectDriver,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _searchController,
            placeholder: l10n.searchForDriver,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E9ED)),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<DriverBloc, DriverState>(
              builder: (context, state) {
                if (state is DriverLoading) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                if (state is DriverError) {
                  return Center(child: Text(state.message));
                }
                if (state is DriverLoaded) {
                  final query = _searchController.text.trim();
                  final drivers = state.drivers.where((d) {
                    if (query.isEmpty) return true;
                    final name = _driverDisplayName(d);
                    return name.contains(query) || d.phone.contains(query);
                  }).toList();

                  if (drivers.isEmpty) {
                    return Center(child: Text(l10n.noDrivers));
                  }

                  return ListView.separated(
                    itemCount: drivers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final driver = drivers[index];
                      final isSelected = _tempSelected?.id == driver.id;

                      return GestureDetector(
                        onTap: () => setState(() => _tempSelected = driver),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEFF7FF)
                                : CupertinoColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0874C9)
                                  : const Color(0xFFE5E9ED),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _driverDisplayName(driver),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF222222),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                driver.phone,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: const Color(0xFF0874C9),
              borderRadius: BorderRadius.circular(12),
              onPressed: _tempSelected == null
                  ? null
                  : () => Navigator.of(context).pop(_tempSelected),
              child: Text(
                l10n.chooseThisDriver,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _driverDisplayName(DriverModel driver) {
  if (driver.fullNameAr.isNotEmpty) return driver.fullNameAr;
  if (driver.fullNameEn.isNotEmpty) return driver.fullNameEn;
  return driver.phone;
}
