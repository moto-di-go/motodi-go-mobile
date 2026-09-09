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

  static const Set<String> authEntryRoutes = {
    welcome,
    login,
    register,
    otp,
    accountReady,
    forgotPassword,
    resetOtp,
    resetPassword,
    passwordResetSuccess,
  };

  // Onboarding
  static const String onboarding = '/onboarding';

  // Profils
  static const String profileSelection = '/profiles/select';
  static const String profilesMine = '/profiles/mine';
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

  // App (onglets shell)
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String wallet = '/wallet';
  static const String walletDeposit = '/wallet/deposit';
  static const String walletDepositStatus = '/wallet/deposit/:id';
  static const String walletPay = '/wallet/pay/:bookingId';
  static const String walletReceipt = '/wallet/receipt/:id';
  static const String notifications = '/notifications';
  static const String urbanMap = '/urban/map';
  static const String driverAvailability = '/urban/driver';

  static String walletDepositStatusPath(String id) => '/wallet/deposit/$id';
  static String walletPayPath(String bookingId) => '/wallet/pay/$bookingId';
  static String walletReceiptPath(String id) => '/wallet/receipt/$id';

  // NFC offline payment
  static const String nfcEligibility = '/nfc/eligibility';
  static const String nfcPay = '/nfc/pay';
  static const String nfcEmit = '/nfc/emit/:tokenId';
  static const String nfcReceive = '/nfc/receive';
  static const String nfcPending = '/nfc/pending';

  // Offline mode
  static const String offline = '/offline';
  static const String offlineMaps = '/offline/maps';
  static const String offlineMapsSelect = '/offline/maps/select';
  static const String offlineQueue = '/offline/queue';
  static const String offlineSync = '/offline/sync';
  static const String offlineSettings = '/offline/settings';

  static String nfcEmitPath(String tokenId) => '/nfc/emit/$tokenId';
  static String nfcPayWithQuery({double? amount, String? bookingId, String? tripId}) {
    final params = <String, String>{};
    if (amount != null) params['amount'] = amount.toString();
    if (bookingId != null && bookingId.isNotEmpty) params['bookingId'] = bookingId;
    if (tripId != null && tripId.isNotEmpty) params['tripId'] = tripId;
    if (params.isEmpty) return nfcPay;
    return Uri(path: nfcPay, queryParameters: params).toString();
  }

  // Intercity
  static const String intercity = '/intercity';

  /// Alias historique : ouvre l'onglet Trajets / Annonces.
  static const String intercityMyAnnouncements = '/intercity';
  static const String intercityResults = '/intercity/results';
  static const String intercityEmpty = '/intercity/empty';
  static const String intercityDetail = '/intercity/detail';
  static const String intercitySubscribe = '/intercity/subscribe';
  static const String intercityBooking = '/intercity/booking/:id';
  static const String intercityPublishGuard = '/intercity/publish/guard';
  static const String intercityCreate = '/intercity/publish/create';
  static const String intercityPreview = '/intercity/publish/preview';
  static const String intercityPublishSuccess = '/intercity/publish/success';
  static const String intercityIncomingBookings = '/intercity/publish/incoming';

  // Trips / suivi live + post-trajet
  static const String tripTrack = '/trips/:id/track';
  static const String tripsHistory = '/trips/history';
  static const String tripRate = '/trips/:id/rate';
  static const String tripHistoryDetail = '/trips/:id/history';
  static const String tripRateSuccess = '/trips/rate/success';
  static const String receipts = '/receipts';
  static const String support = '/support';
  static const String supportTickets = '/support/tickets';
  static const String supportTicketDetail = '/support/tickets/:id';
  static const String supportTicketCreated = '/support/created';

  static String intercityBookingPath(String id) => '/intercity/booking/$id';
  static String intercityDetailPath(String id) =>
      Uri(path: intercityDetail, queryParameters: {'id': id}).toString();
  static String tripTrackPath(String id) => '/trips/$id/track';
  static String tripRatePath(String id) => '/trips/$id/rate';
  static String tripHistoryDetailPath(String id) => '/trips/$id/history';
  static String supportTicketDetailPath(String id) => '/support/tickets/$id';

  // Feature d'exemple conservee pour les tests template existants.
  static const String exampleList = '/examples';
  static const String exampleDetail = '/examples/:id';
}
