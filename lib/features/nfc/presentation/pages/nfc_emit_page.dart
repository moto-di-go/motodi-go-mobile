import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/core/widgets/nfc_transfer_screen.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/nfc/presentation/cubit/nfc_emit_cubit.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';

class NfcEmitPage extends StatelessWidget {
  final String tokenId;

  const NfcEmitPage({super.key, required this.tokenId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NfcEmitCubit>()..load(tokenId),
      child: _NfcEmitView(tokenId: tokenId),
    );
  }
}

class _NfcEmitView extends StatelessWidget {
  final String tokenId;

  const _NfcEmitView({required this.tokenId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NfcEmitCubit, NfcEmitState>(
      builder: (context, state) {
        if (state.status == NfcEmitStatus.loading || state.status == NfcEmitStatus.initial) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (state.status == NfcEmitStatus.failure || state.token == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: AppErrorView(
                message: state.errorMessage ?? 'Jeton introuvable.',
                onRetry: () => context.read<NfcEmitCubit>().load(tokenId),
              ),
            ),
          );
        }

        if (state.status == NfcEmitStatus.expired) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Jeton expiré', style: walletText(fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Text(
                      'Ce jeton ne peut plus être utilisé. Préparez-en un nouveau ou payez via wallet.',
                      style: walletText(fontSize: 15, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const Spacer(),
                    UrbanPrimaryButton(
                      label: 'Nouveau jeton NFC',
                      onPressed: () => context.pushReplacement(RouteConstants.nfcPay),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => context.go(RouteConstants.wallet),
                      child: Text(
                        'Payer via wallet',
                        style: walletText(fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final token = state.token!;
        return NfcTransferScreen(
          signedToken: token.signedToken,
          amount: token.amount,
          currency: token.currency,
          remaining: state.remaining,
          useQr: state.useQr,
          nfcHint: state.nfcAvailable,
          statusMessage: state.statusMessage,
          onTryNfc: state.nfcAvailable
              ? () => context.read<NfcEmitCubit>().tryNfcEmit()
              : null,
          onSwitchToQr: () => context.read<NfcEmitCubit>().showQr(),
          onCancel: () => context.pop(),
        );
      },
    );
  }
}
