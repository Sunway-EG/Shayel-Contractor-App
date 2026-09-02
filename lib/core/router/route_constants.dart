class AppRoutePaths {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const passwordLogin = '/auth/login';
  static const mfa = '/mfa-channel';
  static const otp = '/otp';
  static const changePassword = '/change-password';
  static const notFound = '/404';
  static const firstChoose = '/first-choose';
  static const register = '/register';
  static const home = '/home';
  static const requests = '/requests';
  static const requestsTypeParam = 'type';
  static const requestsTypeRequested = 'requested';
  static const requestsTypeBooked = 'booked';

  static String requestsPath({required bool booked}) =>
      '$requests?$requestsTypeParam=${booked ? requestsTypeBooked : requestsTypeRequested}';
  static const market = '/market';
  static const settings = '/settings';
  static const profile = '/profile';
  static const String bookTrip = '/book-trip';
  static const String addDriver = '/add-driver';
}
