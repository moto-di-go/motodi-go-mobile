import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/account_ready_page.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/auth_route_args.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/onboarding_page.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/otp_page.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/session_expired_page.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/welcome_page.dart';
import 'package:motodi_go_mobile/features/example/presentation/pages/example_detail_page.dart';
import 'package:motodi_go_mobile/features/example/presentation/pages/example_list_page.dart';
import 'package:motodi_go_mobile/features/home/presentation/pages/home_page.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_publish_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_search_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/pages/booking_pages.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/pages/publish_pages.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/pages/search_pages.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_bundle.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_file_draft.dart';
import 'package:motodi_go_mobile/features/kyc/presentation/pages/kyc_pages.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/pages/driver_profile_pages.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/pages/passenger_profile_page.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/pages/profile_selection_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

GoRouter createAppRouter(SessionCubit sessionCubit) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(sessionCubit.stream),
    redirect: (context, state) {
      final session = sessionCubit.state;
      final location = state.matchedLocation;

      final authEntryRoutes = {
        RouteConstants.welcome,
        RouteConstants.login,
        RouteConstants.register,
        RouteConstants.otp,
        RouteConstants.accountReady,
        RouteConstants.forgotPassword,
        RouteConstants.resetOtp,
        RouteConstants.resetPassword,
        RouteConstants.passwordResetSuccess,
      };
      final publicRoutes = {
        RouteConstants.splash,
        RouteConstants.onboarding,
        RouteConstants.sessionExpired,
        ...authEntryRoutes,
      };
      final profileSetupRoutes = {
        RouteConstants.profileSelection,
        RouteConstants.profilePassenger,
        RouteConstants.profileMototaxi,
        RouteConstants.profileTransporter,
      };
      if (session.isBootstrapping) {
        return location == RouteConstants.splash ? null : RouteConstants.splash;
      }

      if (session.isExpired) {
        return location == RouteConstants.sessionExpired
            ? null
            : RouteConstants.sessionExpired;
      }

      if (!session.isAuthenticated) {
        if (location == RouteConstants.splash) {
          return session.onboardingSeen
              ? RouteConstants.welcome
              : RouteConstants.onboarding;
        }
        if (publicRoutes.contains(location)) return null;
        return RouteConstants.welcome;
      }

      if (location == RouteConstants.splash ||
          location == RouteConstants.sessionExpired) {
        return session.needsProfileSelection
            ? RouteConstants.profileSelection
            : RouteConstants.home;
      }

      if (session.needsProfileSelection) {
        if (location == RouteConstants.accountReady ||
            profileSetupRoutes.contains(location)) {
          return null;
        }
        return RouteConstants.profileSelection;
      }

      if (authEntryRoutes.contains(location) ||
          location == RouteConstants.onboarding) {
        return RouteConstants.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteConstants.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteConstants.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteConstants.otp,
        builder: (context, state) =>
            OtpPage(args: state.extra as RegistrationOtpArgs?),
      ),
      GoRoute(
        path: RouteConstants.accountReady,
        builder: (context, state) => const AccountReadyPage(),
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteConstants.resetOtp,
        builder: (context, state) =>
            ResetOtpPage(args: state.extra as ResetOtpArgs?),
      ),
      GoRoute(
        path: RouteConstants.resetPassword,
        builder: (context, state) =>
            NewPasswordPage(args: state.extra as ResetOtpArgs?),
      ),
      GoRoute(
        path: RouteConstants.passwordResetSuccess,
        builder: (context, state) => const PasswordResetSuccessPage(),
      ),
      GoRoute(
        path: RouteConstants.sessionExpired,
        builder: (context, state) => const SessionExpiredPage(),
      ),
      GoRoute(
        path: RouteConstants.profileSelection,
        builder: (context, state) => const ProfileSelectionPage(),
      ),
      GoRoute(
        path: RouteConstants.profilePassenger,
        builder: (context, state) => const PassengerProfilePage(),
      ),
      GoRoute(
        path: RouteConstants.profileMototaxi,
        builder: (context, state) => const MotoTaxiProfilePage(),
      ),
      GoRoute(
        path: RouteConstants.profileTransporter,
        builder: (context, state) => const TransporterProfilePage(),
      ),
      GoRoute(
        path: RouteConstants.kyc,
        builder: (context, state) => const KycStatusPage(),
      ),
      GoRoute(
        path: RouteConstants.kycDocuments,
        builder: (context, state) => const KycDocumentsPage(),
      ),
      GoRoute(
        path: RouteConstants.kycPreview,
        builder: (context, state) =>
            KycPreviewPage(draft: state.extra as KycFileDraft?),
      ),
      GoRoute(
        path: RouteConstants.kycUploading,
        builder: (context, state) =>
            KycUploadingPage(draft: state.extra as KycFileDraft?),
      ),
      GoRoute(
        path: RouteConstants.kycUploadSuccess,
        builder: (context, state) =>
            KycUploadSuccessPage(result: state.extra as KycUploadResult?),
      ),
      GoRoute(
        path: RouteConstants.kycInvalid,
        builder: (context, state) =>
            KycInvalidFilePage(args: state.extra as KycInvalidFileArgs?),
      ),
      GoRoute(
        path: RouteConstants.kycSubmitted,
        builder: (context, state) => const KycSubmittedPage(),
      ),
      GoRoute(
        path: RouteConstants.kycRejected,
        builder: (context, state) =>
            KycRejectedDocumentPage(document: state.extra as KycDocument?),
      ),
      GoRoute(
        path: RouteConstants.kycVerified,
        builder: (context, state) => const KycVerifiedPage(),
      ),
      GoRoute(
        path: RouteConstants.kycNotification,
        builder: (context, state) => KycNotificationDetailPage(
          payload: state.extra as KycNotificationPayload?,
        ),
      ),
      GoRoute(
        path: RouteConstants.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RouteConstants.intercity,
        builder: (context, state) => const IntercityHubPage(),
      ),
      GoRoute(
        path: RouteConstants.intercityResults,
        builder: (context, state) =>
            IntercityResultsPage(cubit: state.extra as IntercitySearchCubit),
      ),
      GoRoute(
        path: RouteConstants.intercityEmpty,
        builder: (context, state) =>
            IntercityEmptyResultsPage(cubit: state.extra as IntercitySearchCubit),
      ),
      GoRoute(
        path: RouteConstants.intercityDetail,
        builder: (context, state) =>
            IntercityDetailPage(announcementId: state.extra as String),
      ),
      GoRoute(
        path: RouteConstants.intercitySubscribe,
        builder: (context, state) =>
            IntercitySubscribePage(args: state.extra as IntercitySubscribeArgs),
      ),
      GoRoute(
        path: RouteConstants.intercityBooking,
        builder: (context, state) =>
            IntercityBookingStatusPage(bookingId: state.extra as String),
      ),
      GoRoute(
        path: RouteConstants.intercityPublishGuard,
        builder: (context, state) => const IntercityPublishGuardPage(),
      ),
      GoRoute(
        path: RouteConstants.intercityCreate,
        builder: (context, state) =>
            IntercityCreateAnnouncementPage(cubit: state.extra as IntercityPublishCubit),
      ),
      GoRoute(
        path: RouteConstants.intercityPreview,
        builder: (context, state) {
          final args = state.extra as (IntercityPublishCubit, CreateAnnouncementDraft);
          return IntercityPreviewPage(cubit: args.$1, draft: args.$2);
        },
      ),
      GoRoute(
        path: RouteConstants.intercityPublishSuccess,
        builder: (context, state) =>
            IntercityPublishSuccessPage(announcement: state.extra as IntercityAnnouncement),
      ),
      GoRoute(
        path: RouteConstants.intercityMyAnnouncements,
        builder: (context, state) => const IntercityMyAnnouncementsPage(),
      ),
      GoRoute(
        path: RouteConstants.intercityIncomingBookings,
        builder: (context, state) =>
            IntercityIncomingBookingsPage(announcementId: state.extra as String),
      ),
      GoRoute(
        path: RouteConstants.exampleList,
        builder: (context, state) => const ExampleListPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ExampleDetailPage(itemId: id);
            },
          ),
        ],
      ),
    ],
  );
}
