import '../../features/auth/domain/failures/auth_failure.dart';

/// Maps auth failures to user-facing display strings.
/// This is a lightweight replacement for the Shayel Contractor shared mapper.
class FailureMessageMapper {
  static String forAuth(
    AuthFailure failure, {
    String invalidCredentialsMessage = 'auth.invalid_credentials',
  }) {
    return switch (failure) {
      AuthFailureInvalidCredentials(:final message) =>
        message ?? invalidCredentialsMessage,
      AuthFailureServer(:final message) => message ?? 'server_error',
      AuthFailureNetwork() => 'network_error',
      AuthFailureUnknown(:final message) => message ?? 'unknown_error',
    };
  }
}
