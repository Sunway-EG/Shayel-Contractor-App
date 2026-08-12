import 'dart:io' show Platform;

import 'package:contractor_app/core/router/route_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:contractor_app/core/locale/bloc/locale_bloc.dart';
import 'package:flutter/material.dart';


import '../../../../core/services/biometric_service.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog_presenter.dart';
import '../../../../core/widgets/app_phone_input.dart';
import '../../../../core/widgets/app_update_flow.dart';
import '../../../../core/widgets/app_version.dart';
import '../../../../core/widgets/language_switcher.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../utils/auth_error_extensions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  String? _phoneError;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _didAutoOpenBiometric = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
    _rememberMe = AuthStorage.instance.rememberMe;
    final remembered = AuthStorage.instance.rememberedLogin;
    if (_rememberMe && remembered != null && remembered.isNotEmpty) {
      if (remembered.startsWith('+2') && remembered.length == 13) {
        _phoneController.text = remembered.substring(2);
      }
    }
  }

  Future<void> _checkBiometricStatus() async {
    final isAvailable = await BiometricService.instance.isAvailable();
    final isEnabled = await BiometricService.instance.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricAvailable = isAvailable;
        _biometricEnabled = isEnabled;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Phone sent to API in format +201000665931 (no spaces, +2 then 11 digits).
  String get _fullPhoneNumber {
    final digits = extractDigits(_phoneController.text);
    return '+2${digits.length > 11 ? digits.substring(0, 11) : digits}';
  }

  String? _validateAndGetError(AppLocalizations l10n) {
    final digits = extractDigits(_phoneController.text);
    if (digits.isEmpty) return l10n.enterYourPhone;
    if (digits.length != 11) return l10n.enterValidPhone11Digits;
    if (!digits.startsWith('01')) return l10n.enterValidPhone01;
    return null;
  }

  void _toggleRememberMe() {
    setState(() {
      _rememberMe = !_rememberMe;
      if (!_rememberMe) {
        AuthStorage.instance.saveRememberMe(false);
      }
    });
  }

  void _validatePhone(AppLocalizations l10n) {
    final digits = extractDigits(_phoneController.text);
    String? error;
    if (digits.isEmpty) {
      error = null;
    } else if (digits.length != 11) {
      error = l10n.enterValidPhone11Digits;
    } else if (!digits.startsWith('01')) {
      error = l10n.enterValidPhone01;
    }
    if (_phoneError != error) setState(() => _phoneError = error);
  }

  void _submit(AppLocalizations l10n) {
    final error = _validateAndGetError(l10n);
    if (error != null) {
      setState(() => _phoneError = error);
      return;
    }
    setState(() => _phoneError = null);
    context.read<AuthBloc>().add(
      AuthSendLoginOtpRequested(login: _fullPhoneNumber),
    );
  }

  void _showError(
    BuildContext context,
    AuthError error,
    AppLocalizations l10n,
  ) {
    final message = error.getDisplayMessage(l10n);
    showAppAlertDialog(
      context: context,
      title: l10n.error,
      message: message,
      actionText: l10n.ok,
    );
  }

  void _maybeAutoOpenBiometric(BuildContext context) {
    if (!_biometricAvailable || !_biometricEnabled || _didAutoOpenBiometric) {
      return;
    }
    _didAutoOpenBiometric = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      context.read<AuthBloc>().add(
        AuthBiometricLoginRequested(
          localizedReason: l10n.biometricLocalizedReasonSignIn,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _maybeAutoOpenBiometric(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          _showError(context, state, l10n);
        } else if (state is AuthSendLoginOtpSuccess) {
          if (_rememberMe) {
            AuthStorage.instance.saveRememberMe(true, login: _fullPhoneNumber);
          } else {
            AuthStorage.instance.saveRememberMe(false);
          }
          Future.microtask(() {
            if (context.mounted) {
              final phone = Uri.encodeComponent(_fullPhoneNumber);
              context.go('${AppRoutePaths.otp}?contact=$phone&viaSms=true');
            }
          });
        } else if (state is AuthLoginSuccess) {
          Future.microtask(() async {
            if (!context.mounted) return;
            await handleLoginNavigationWithAppUpdate(
              context: context,
              navigate: () {
                if (!context.mounted) return;
                if (state.loginResult.redirect == 'mfa') {
                  final email = state.loginResult.email ?? '';
                  final phone = state.loginResult.phone ?? '';
                  context.go(
                    '${AppRoutePaths.mfa}?email=${Uri.encodeComponent(email)}&phone=${Uri.encodeComponent(phone)}',
                  );
                } else if (state.loginResult.redirect == 'forget_password' &&
                    state.loginResult.phoneForOtp != null) {
                  final contact = Uri.encodeComponent(
                    state.loginResult.phoneForOtp!,
                  );
                  final isPhone = !state.loginResult.phoneForOtp!.contains('@');
                  context.go(
                    '${AppRoutePaths.otp}?contact=$contact&viaSms=$isPhone&forgetPassword=true',
                  );
                } else {
                  context.go(AppRoutePaths.home);
                }
              },
            );
          });
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
          
                /// Logo
                Image.asset(
                  "assets/images/logo.png",
                  width: 60,
                  height: 60,
                ),
          
                const SizedBox(height: 18),
          
                /// Title
                const Text(
                  "مرحباً في شايل",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          
                const SizedBox(height: 10),
          
                /// Subtitle
                const Text(
                  "اكتب كلمة مرورك لتسجيل الدخول أو تبديل حسابك",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
          
                const SizedBox(height: 28),
          
                /// Phone Label
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "رقم الهاتف",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
          
                const SizedBox(height: 8),
          
                /// Phone Field
                TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "10 234 5678",
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(14),
                      child: Text(
                        "🇪🇬 +20",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 90),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
          
                const SizedBox(height: 22),
          
                /// Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:  () => _submit(l10n),
                     
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0066C3),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "تسجيل الدخول",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
          
                const SizedBox(height: 20),
          
                /// Password Login
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      context.go(AppRoutePaths.passwordLogin);
                      
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff0066C3),
                      side: const BorderSide(
                        color: Color(0xff0066C3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "تسجيل دخول بكلمة المرور",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
          
const SizedBox(height: 20),          
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "تبديل الحساب",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff0066C3),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
          
                const Text(
                  "التطبيق الإصدار0.1",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
          
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
        },
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _LoginHeaderClipper(),
      child: Container(
        width: double.infinity,
        height: AppLayout.authHeaderHeight,
        color: AppColors.mainBlue,
      ),
    );
  }
}

/// Curved bottom edge: dips down on the left, curves up on the right.
class _LoginHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height - 40,
        0,
        size.height * 0.6,
      )
      ..lineTo(0, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
