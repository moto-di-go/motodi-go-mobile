// Role : Centralise toutes les routes de navigation de l'application.
class RouteConstants {
  // Auth
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String accountReady = '/account-ready';
  static const String forgotPassword = '/forgot-password';
  static const String resetOtp = '/forgot-password/otp';
  static const String resetPassword = '/reset-password';
  static const String passwordResetSuccess = '/password-reset-success';
  static const String sessionExpired = '/session-expired';

  // Onboarding
  static const String onboarding = '/onboarding';

  // Profils
  static const String profileSelection = '/profiles/select';
  static const String profilePassenger = '/profiles/passenger';
  static const String profileMototaxi = '/profiles/mototaxi';
  static const String profileTransporter = '/profiles/transporter';

  // KYC
  static const String kyc = '/kyc';
  static const String kycDocuments = '/kyc/documents';
  static const String kycPreview = '/kyc/preview';
  static const String kycUploading = '/kyc/uploading';
  static const String kycUploadSuccess = '/kyc/upload-success';
  static const String kycInvalid = '/kyc/invalid';
  static const String kycSubmitted = '/kyc/submitted';
  static const String kycRejected = '/kyc/rejected';
  static const String kycVerified = '/kyc/verified';
  static const String kycNotification = '/kyc/notification';

  // App
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Intercity
  static const String intercity = '/intercity';
  static const String intercityResults = '/intercity/results';
  static const String intercityEmpty = '/intercity/empty';
  static const String intercityDetail = '/intercity/detail';
  static const String intercitySubscribe = '/intercity/subscribe';
  static const String intercityBooking = '/intercity/booking';
  static const String intercityPublishGuard = '/intercity/publish/guard';
  static const String intercityCreate = '/intercity/publish/create';
  static const String intercityPreview = '/intercity/publish/preview';
  static const String intercityPublishSuccess = '/intercity/publish/success';
  static const String intercityMyAnnouncements = '/intercity/publish/mine';
  static const String intercityIncomingBookings = '/intercity/publish/incoming';

  // Feature d'exemple conservee pour les tests template existants.
  static const String exampleList = '/examples';
  static const String exampleDetail = '/examples/:id';
}
