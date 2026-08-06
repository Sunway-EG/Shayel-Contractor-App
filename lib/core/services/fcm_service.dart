/// Minimal FCM service stub used by the API client.
///
/// The contractor_app project currently uses only the cached token from this
/// service, so this stub avoids introducing Firebase dependencies.
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  String? _currentToken;

  /// Returns the currently cached FCM token, if any.
  String? get currentToken => _currentToken;

  /// Sets a token for local testing or initialization.
  void setToken(String? token) {
    _currentToken = token;
  }
}
