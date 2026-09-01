import 'core/router/app_router.dart';
import 'core/services/app_update_service.dart';

import 'dart:async';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/locale/bloc/locale_bloc.dart';
import 'core/locale/bloc/locale_state.dart';
import 'core/network/api_client.dart';
import 'core/storage/auth_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/sources/remote/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_impl.dart';
import 'features/auth/domain/use_cases/forget_password_usecase.dart';
import 'features/auth/domain/use_cases/get_profile_usecase.dart';
import 'features/auth/domain/use_cases/login_usecase.dart';
import 'features/auth/domain/use_cases/login_with_otp_usecase.dart';
import 'features/auth/domain/use_cases/logout_usecase.dart';
import 'features/auth/domain/use_cases/reset_password_usecase.dart';
import 'features/auth/domain/use_cases/send_login_otp_usecase.dart';
import 'features/auth/domain/use_cases/send_mfa_code_usecase.dart';
import 'features/auth/domain/use_cases/update_profile_usecase.dart';
import 'features/auth/domain/use_cases/validate_password_usecase.dart';
import 'features/auth/domain/use_cases/verify_mfa_usecase.dart';
import 'features/auth/domain/use_cases/enable_mfa_usecase.dart';
import 'features/auth/domain/use_cases/disable_mfa_usecase.dart';
import 'features/auth/domain/use_cases/change_password_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'l10n/gen/app_localizations.dart';
import 'features/auth/domain/use_cases/register_usecase.dart';
import 'features/auth/domain/use_cases/get_documents_usecase.dart';

import 'features/trips/data/datasources/trip_remote_datasource.dart';
import 'features/trips/data/repositories/trip_repository_impl.dart';
import 'features/trips/presentation/bloc/trip_bloc.dart';

import 'features/drivers/data/datasources/driver_remote_datasource.dart';
import 'features/drivers/data/repositories/driver_repository_impl.dart';
import 'features/drivers/presentation/bloc/driver_bloc.dart';

/// Override with --dart-define=SENTRY_DSN=... for other environments.
const _sentryDsn = String.fromEnvironment(
  'SENTRY_DSN',
  defaultValue:
      'https://ae6e1918a34413f3d4428687887d0e05@o4508886465970176.ingest.de.sentry.io/4510835397296208',
);

bool get _isValidSentryDsn =>
    _sentryDsn.isNotEmpty &&
    _sentryDsn.contains('sentry.io') &&
    !_sentryDsn.contains('your-other-dsn');

Future<void> _runApp({bool useSentry = false}) async {
  // Initialize storage first
  await AuthStorage.instance.init();

  final dio = createContractorApiClient();
  AppUpdateService.init(dio);

  // Auth dependencies
  final authRemoteDataSource = AuthRemoteDataSourceImpl(dio);
  final authRepository = AuthImpl(authRemoteDataSource);

  // Initialize use cases
  final loginUseCase = LoginUseCase(authRepository);
  final sendLoginOtpUseCase = SendLoginOtpUseCase(authRepository);
  final loginWithOtpUseCase = LoginWithOtpUseCase(authRepository);
  final forgetPasswordUseCase = ForgetPasswordUseCase(authRepository);
  final resetPasswordUseCase = ResetPasswordUseCase(authRepository);
  final resetPasswordWithCodeUseCase = ResetPasswordWithCodeUseCase(
    authRepository,
  );
  final logoutUseCase = LogoutUseCase(authRepository);
  final sendMfaCodeUseCase = SendMfaCodeUseCase(authRepository);
  final verifyMfaUseCase = VerifyMfaUseCase(authRepository);
  final enableMfaUseCase = EnableMfaUseCase(authRepository);
  final disableMfaUseCase = DisableMfaUseCase(authRepository);
  final getProfileUseCase = GetProfileUseCase(authRepository);
  final updateProfileUseCase = UpdateProfileUseCase(authRepository);
  final changePasswordUseCase = ChangePasswordUseCase(authRepository);
  final validatePasswordUseCase = ValidatePasswordUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final getDocumentsUseCase = GetDocumentsUseCase(authRepository);
  // Trips
final tripRemoteDataSource = TripRemoteDataSourceImpl(dio);
final tripRepository = TripRepositoryImpl(tripRemoteDataSource);
final tripBloc = TripBloc(tripRepository);
  // drivers
final driverRemoteDataSource = DriverRemoteDataSourceImpl(dio);
final driverRepository = DriverRepositoryImpl(driverRemoteDataSource);
final driverBloc = DriverBloc(driverRepository);

  // Initialize BloC with use cases
  final authBloc = AuthBloc(
    loginUseCase: loginUseCase,
    sendLoginOtpUseCase: sendLoginOtpUseCase,
    loginWithOtpUseCase: loginWithOtpUseCase,
    forgetPasswordUseCase: forgetPasswordUseCase,
    resetPasswordUseCase: resetPasswordUseCase,
    resetPasswordWithCodeUseCase: resetPasswordWithCodeUseCase,
    logoutUseCase: logoutUseCase,
    sendMfaCodeUseCase: sendMfaCodeUseCase,
    verifyMfaUseCase: verifyMfaUseCase,
    enableMfaUseCase: enableMfaUseCase,
    disableMfaUseCase: disableMfaUseCase,
    changePasswordUseCase: changePasswordUseCase,
    validatePasswordUseCase: validatePasswordUseCase,
    registerUseCase: registerUseCase,
    getDocumentsUseCase: getDocumentsUseCase,
  );
  final profileBloc = ProfileBloc(
    getProfileUseCase: getProfileUseCase,
    updateProfileUseCase: updateProfileUseCase,
  );

  final localeBloc = LocaleBloc();

  // Check session on startup
  authBloc.add(const AuthCheckSessionRequested());

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: localeBloc),
        BlocProvider.value(value: profileBloc),
        BlocProvider.value(value: tripBloc),
        BlocProvider.value(value: driverBloc),
      ],
      child: useSentry
          ? SentryWidget(child: const ShayelContractorApp())
          : const ShayelContractorApp(),
    ),
  );
}

bool _sentryInitialized = false;

Future<void> main() async {
  // Ensure Flutter binding is initialized before accessing platform channels
  WidgetsFlutterBinding.ensureInitialized();
  ChuckerFlutter.showOnRelease = true;

  if (_isValidSentryDsn && !_sentryInitialized && kReleaseMode) {
    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = _sentryDsn;
          options.tracesSampleRate = 1.0;
          options.sendDefaultPii = true;
        },
        appRunner: () async {
          _sentryInitialized = true;
          await _runApp(useSentry: true);
        },
      );
      return;
    } catch (_) {
      await _runApp(useSentry: false);
    }
  } else {
    await _runApp(useSentry: _sentryInitialized);
  }
}

class ShayelContractorApp extends StatelessWidget {
  const ShayelContractorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, localeState) {
        final locale = localeState is LocaleLoaded
            ? localeState.locale
            : localeState is LocaleInitial
            ? localeState.locale
            : const Locale('ar');
        return CupertinoApp.router(
          title: 'Shayel Contractor',
          theme: buildAppTheme(locale.languageCode),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: createAppRouter(),
        );
      },
    );
  }
}
