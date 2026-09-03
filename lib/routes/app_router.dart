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
import 'package:motodi_go_mobile/features/home/presentation/pages/main_shell.dart';
import 'package:motodi_go_mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:motodi_go_mobile/features/wallet/domain/entities/wallet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/pages/deposit_page.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/pages/deposit_status_page.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/pages/pay_booking_page.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/pages/receipt_page.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/pages/wallet_page.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/pages/nfc_eligibility_page.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/pages/nfc_emit_page.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/pages/nfc_pay_page.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/pages/nfc_pending_page.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/pages/nfc_receive_page.dart';
import 'package:motodi_go_mobile/features/offline/presentation/pages/offline_dashboard_page.dart';
import 'package:motodi_go_mobile/features/offline/presentation/pages/offline_maps_page.dart';
import 'package:motodi_go_mobile/features/offline/presentation/pages/offline_queue_page.dart';
import 'package:motodi_go_mobile/features/offline/presentation/pages/offline_settings_page.dart';
import 'package:motodi_go_mobile/features/offline/presentation/pages/offline_sync_page.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_publish_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_search_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/pages/booking_pages.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/pages/intercity_tab_page.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/pages/publish_pages.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/pages/search_pages.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_bundle.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_file_draft.dart';
import 'package:motodi_go_mobile/features/kyc/presentation/pages/kyc_pages.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/pages/driver_profile_pages.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/pages/mes_profils_page.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/pages/passenger_profile_page.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/pages/profile_hub_page.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/pages/profile_selection_page.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/pages/settings_page.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/presentation/pages/rate_trip_page.dart';
import 'package:motodi_go_mobile/features/post/presentation/pages/receipts_list_page.dart';
import 'package:motodi_go_mobile/features/post/presentation/pages/support_pages.dart';
import 'package:motodi_go_mobile/features/post/presentation/pages/trip_history_detail_page.dart';
import 'package:motodi_go_mobile/features/post/presentation/pages/trip_history_page.dart';
import 'package:motodi_go_mobile/features/trips/presentation/pages/trip_track_page.dart';
import 'package:motodi_go_mobile/features/urban/presentation/pages/driver_availability_page.dart';
import 'package:motodi_go_mobile/features/urban/presentation/pages/urban_map_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

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
        return location == RouteConstants.sessionExpired ? null : RouteConstants.sessionExpired;
      }

      if (!session.isAuthenticated) {
        if (location == RouteConstants.splash) {
          return session.onboardingSeen ? RouteConstants.welcome : RouteConstants.onboarding;
        }
        if (publicRoutes.contains(location)) return null;
        return RouteConstants.welcome;
      }

      if (location == RouteConstants.splash || location == RouteConstants.sessionExpired) {
        return session.needsProfileSelection
            ? RouteConstants.profileSelection
            : RouteConstants.home;
      }

      if (session.needsProfileSelection) {
        if (location == RouteConstants.accountReady || profileSetupRoutes.contains(location)) {
          return null;
        }
        return RouteConstants.profileSelection;
      }

      if (authEntryRoutes.contains(location) || location == RouteConstants.onboarding) {
        return RouteConstants.home;
      }

      return null;
    },
    routes: [
      GoRoute(path: RouteConstants.splash, builder: (context, state) => const SplashPage()),
      GoRoute(path: RouteConstants.onboarding, builder: (context, state) => const OnboardingPage()),
      GoRoute(path: RouteConstants.welcome, builder: (context, state) => const WelcomePage()),
      GoRoute(path: RouteConstants.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: RouteConstants.register, builder: (context, state) => const RegisterPage()),
      GoRoute(
        path: RouteConstants.otp,
        builder: (context, state) => OtpPage(args: state.extra as RegistrationOtpArgs?),
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
        builder: (context, state) => ResetOtpPage(args: state.extra as ResetOtpArgs?),
      ),
      GoRoute(
        path: RouteConstants.resetPassword,
        builder: (context, state) => NewPasswordPage(args: state.extra as ResetOtpArgs?),
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
        path: RouteConstants.profilesMine,
        builder: (context, state) => const MesProfilsPage(),
      ),
      GoRoute(path: RouteConstants.settings, builder: (context, state) => const SettingsPage()),
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
        routes: [
          GoRoute(path: 'documents', builder: (context, state) => const KycDocumentsPage()),
          GoRoute(
            path: 'preview',
            builder: (context, state) => KycPreviewPage(draft: state.extra as KycFileDraft?),
          ),
          GoRoute(
            path: 'uploading',
            builder: (context, state) => KycUploadingPage(draft: state.extra as KycFileDraft?),
          ),
          GoRoute(
            path: 'upload-success',
            builder: (context, state) =>
                KycUploadSuccessPage(result: state.extra as KycUploadResult?),
          ),
          GoRoute(
            path: 'invalid',
            builder: (context, state) =>
                KycInvalidFilePage(args: state.extra as KycInvalidFileArgs?),
          ),
          GoRoute(path: 'submitted', builder: (context, state) => const KycSubmittedPage()),
          GoRoute(
            path: 'rejected',
            builder: (context, state) =>
                KycRejectedDocumentPage(document: state.extra as KycDocument?),
          ),
          GoRoute(path: 'verified', builder: (context, state) => const KycVerifiedPage()),
          GoRoute(
            path: 'notification',
            builder: (context, state) =>
                KycNotificationDetailPage(payload: state.extra as KycNotificationPayload?),
          ),
        ],
      ),
      GoRoute(path: RouteConstants.urbanMap, builder: (context, state) => const UrbanMapPage()),
      GoRoute(
        path: RouteConstants.driverAvailability,
        builder: (context, state) => const DriverAvailabilityPage(),
      ),
      GoRoute(
        path: RouteConstants.tripTrack,
        builder: (context, state) => TripTrackPage(tripId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteConstants.tripsHistory,
        builder: (context, state) => const TripHistoryPage(),
      ),
      GoRoute(
        path: RouteConstants.tripRateSuccess,
        builder: (context, state) => const RatingSuccessPage(),
      ),
      GoRoute(
        path: RouteConstants.tripRate,
        builder: (context, state) {
          final extra = state.extra;
          final ratedProfileId = extra is String ? extra : null;
          return RateTripPage(
            tripId: state.pathParameters['id']!,
            ratedProfileId: ratedProfileId,
          );
        },
      ),
      GoRoute(
        path: RouteConstants.tripHistoryDetail,
        builder: (context, state) {
          final extra = state.extra;
          return TripHistoryDetailPage(
            itemId: state.pathParameters['id']!,
            initialItem: extra is TripHistoryItem ? extra : null,
          );
        },
      ),
      GoRoute(
        path: RouteConstants.receipts,
        builder: (context, state) => const ReceiptsListPage(),
      ),
      GoRoute(
        path: RouteConstants.support,
        builder: (context, state) {
          final extra = state.extra;
          return SupportFormPage(
            supportContext: extra is SupportContext ? extra : null,
          );
        },
      ),
      GoRoute(
        path: RouteConstants.supportTicketCreated,
        builder: (context, state) {
          final ticket = state.extra;
          if (ticket is! SupportTicket) {
            return const SupportTicketsPage();
          }
          return SupportTicketCreatedPage(ticket: ticket);
        },
      ),
      GoRoute(
        path: RouteConstants.supportTickets,
        builder: (context, state) => const SupportTicketsPage(),
      ),
      GoRoute(
        path: RouteConstants.supportTicketDetail,
        builder: (context, state) =>
            SupportTicketDetailPage(ticketId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: RouteConstants.home, builder: (context, state) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.intercity,
                builder: (context, state) => const IntercityTabPage(),
                routes: [
                  GoRoute(
                    path: 'results',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        IntercityResultsPage(cubit: state.extra as IntercitySearchCubit),
                  ),
                  GoRoute(
                    path: 'empty',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        IntercityEmptyResultsPage(cubit: state.extra as IntercitySearchCubit),
                  ),
                  GoRoute(
                    path: 'detail',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        IntercityDetailPage(announcementId: state.extra as String),
                  ),
                  GoRoute(
                    path: 'subscribe',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        IntercitySubscribePage(args: state.extra as IntercitySubscribeArgs),
                  ),
                  GoRoute(
                    path: 'booking/:id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? state.extra as String?;
                      return IntercityBookingStatusPage(bookingId: id!);
                    },
                  ),
                  GoRoute(
                    path: 'publish/guard',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const IntercityPublishGuardPage(),
                  ),
                  GoRoute(
                    path: 'publish/create',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => IntercityCreateAnnouncementPage(
                      cubit: state.extra as IntercityPublishCubit,
                    ),
                  ),
                  GoRoute(
                    path: 'publish/preview',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final args = state.extra as (IntercityPublishCubit, CreateAnnouncementDraft);
                      return IntercityPreviewPage(cubit: args.$1, draft: args.$2);
                    },
                  ),
                  GoRoute(
                    path: 'publish/success',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => IntercityPublishSuccessPage(
                      announcement: state.extra as IntercityAnnouncement,
                    ),
                  ),
                  GoRoute(
                    path: 'publish/incoming',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        IntercityIncomingBookingsPage(announcementId: state.extra as String),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.wallet,
                builder: (context, state) => const WalletPage(),
                routes: [
                  GoRoute(
                    path: 'deposit',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const DepositPage(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) =>
                            DepositStatusPage(depositId: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'pay/:bookingId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final bookingId = state.pathParameters['bookingId']!;
                      final extra = state.extra;
                      if (extra is PayBookingArgs) {
                        return PayBookingPage(
                          bookingId: extra.bookingId,
                          expectedAmount: extra.amount,
                          label: extra.label,
                        );
                      }
                      if (extra is double) {
                        return PayBookingPage(bookingId: bookingId, expectedAmount: extra);
                      }
                      return PayBookingPage(bookingId: bookingId);
                    },
                  ),
                  GoRoute(
                    path: 'receipt/:id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => ReceiptPage(
                      receiptId: state.pathParameters['id']!,
                      receipt: state.extra is WalletReceipt ? state.extra as WalletReceipt : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.notifications,
                builder: (context, state) => const NotificationsTabPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.profile,
                builder: (context, state) => const ProfileHubPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.nfcEligibility,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NfcEligibilityPage(),
      ),
      GoRoute(
        path: RouteConstants.nfcPay,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          final amountRaw = q['amount'];
          return NfcPayPage(
            amount: amountRaw == null ? null : double.tryParse(amountRaw),
            bookingId: q['bookingId'],
            tripId: q['tripId'],
          );
        },
      ),
      GoRoute(
        path: '/nfc/emit/:tokenId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => NfcEmitPage(tokenId: state.pathParameters['tokenId']!),
      ),
      GoRoute(
        path: RouteConstants.nfcReceive,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final amountRaw = state.uri.queryParameters['amount'];
          return NfcReceivePage(
            expectedAmount: amountRaw == null ? null : double.tryParse(amountRaw),
          );
        },
      ),
      GoRoute(
        path: RouteConstants.nfcPending,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NfcPendingPage(),
      ),
      GoRoute(
        path: RouteConstants.offline,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OfflineDashboardPage(),
      ),
      GoRoute(
        path: RouteConstants.offlineMaps,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OfflineMapsPage(),
      ),
      GoRoute(
        path: RouteConstants.offlineMapsSelect,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OfflineMapsSelectPage(),
      ),
      GoRoute(
        path: RouteConstants.offlineQueue,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OfflineQueuePage(),
      ),
      GoRoute(
        path: RouteConstants.offlineSync,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OfflineSyncPage(),
      ),
      GoRoute(
        path: RouteConstants.offlineSettings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OfflineSettingsPage(),
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
