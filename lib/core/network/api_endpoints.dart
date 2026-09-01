/// contractor API endpoint paths (no leading slash; base URL is set on Dio).
abstract final class ApiEndpoints {
  static const String login = '/auth/login';
  static const String sendLoginOtp = '/auth/send-login-otp';
  static const String loginWithOtp = '/auth/login-with-otp';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile';
  static const String forgetPassword = '/auth/forget-password';
  static const String resetPassword = '/auth/reset-password';
  static const String resetPasswordWithCode = '/auth/reset-password-with-code';
  static const String changePassword = '/auth/change-password';
  static const String sendMfaCode = '/auth/send-mfa-code';
  static const String verifyMfa = '/auth/verify-mfa';
  static const String enableMfa = '/auth/enable-mfa';
  static const String disableMfa = '/auth/disable-mfa';
  static const String validatePassword = '/auth/validate-password';
  static const register = '/auth/register';
  static const documents = '/documents';
  static const String trips = '/trips';
  static String bookTrip(int tripId) => '/trips/$tripId/book';
  static const String drivers = '/drivers';

  // App version check (shared API root, not under /contractor)
  static const String appVersionCheck = '/app-version/check';
}
