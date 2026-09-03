import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/urban/presentation/widgets/urban_bottom_sheet.dart';
import 'package:motodi_go_mobile/features/wallet/domain/entities/wallet.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/cubit/deposit_cubit.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/widgets/wallet_widgets.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';

class DepositPage extends StatelessWidget {
  const DepositPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<DepositCubit>(), child: const _DepositView());
  }
}

class _DepositView extends StatefulWidget {
  const _DepositView();

  @override
  State<_DepositView> createState() => _DepositViewState();
}

class _DepositViewState extends State<_DepositView> {
  static const _quickAmounts = [1000, 2000, 5000, 10000];

  late final TextEditingController _amountController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final state = context.read<DepositCubit>().state;
    _amountController = TextEditingController(text: state.amountText);
    _phoneController = TextEditingController(text: state.phoneText);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<DepositCubit, DepositState>(
          listenWhen: (prev, next) =>
              prev.errorMessage != next.errorMessage && next.errorMessage != null,
          listener: (context, state) {
            final message = state.errorMessage;
            if (message == null) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          },
          builder: (context, state) {
            if (_amountController.text != state.amountText &&
                !_amountController.selection.isValid) {
              _amountController.text = state.amountText;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 22, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      ),
                      Expanded(
                        child: Text(
                          'Recharger'.tr(context),
                          style: walletText(fontSize: 28, fontWeight: FontWeight.w800, height: 1.1),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                    children: [
                      Text(
                        'Opérateur'.tr(context),
                        style: walletText(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      ...PaymentProvider.depositProviders.map((provider) {
                        final selected = state.provider == provider;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => context.read<DepositCubit>().selectProvider(provider),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: selected ? AppColors.primary : AppColors.outline,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _providerIcon(provider),
                                    color: selected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      provider.labelFr.tr(context),
                                      style: walletText(fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(Icons.check_circle, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 18),
                      Text(
                        'Montant (XAF)'.tr(context),
                        style: walletText(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: context.read<DepositCubit>().setAmount,
                        decoration: InputDecoration(
                          hintText: 'Ex. 5000'.tr(context),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.outline),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _quickAmounts.map((amount) {
                          final selected = state.amount?.round() == amount;
                          return GestureDetector(
                            onTap: () {
                              context.read<DepositCubit>().setQuickAmount(amount);
                              _amountController.text = '$amount';
                              _amountController.selection = TextSelection.collapsed(
                                offset: _amountController.text.length,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primaryLight : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected ? AppColors.primary : AppColors.outline,
                                ),
                              ),
                              child: Text(
                                formatWalletAmount(amount.toDouble()),
                                style: walletText(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Téléphone Mobile Money'.tr(context),
                        style: walletText(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: context.read<DepositCubit>().setPhone,
                        decoration: InputDecoration(
                          hintText: '+2376XXXXXXXX'.tr(context),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.outline),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Format accepté : +237 suivi d’un numéro 6–9.'.tr(context),
                        style: walletText(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: UrbanPrimaryButton(
                    label: 'Continuer'.tr(context),
                    isLoading: state.status == DepositFlowStatus.submitting,
                    onPressed: state.canSubmit ? () => _confirmAndSubmit(context) : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  IconData _providerIcon(PaymentProvider provider) {
    return switch (provider) {
      PaymentProvider.mtnMomo => Icons.phone_android_rounded,
      PaymentProvider.orangeMoney => Icons.smartphone_rounded,
      PaymentProvider.aggregator => Icons.account_tree_outlined,
      _ => Icons.payments_outlined,
    };
  }

  Future<void> _confirmAndSubmit(BuildContext context) async {
    final cubit = context.read<DepositCubit>();
    final validation = cubit.validateForm();
    if (validation != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validation)));
      return;
    }

    final state = cubit.state;
    final confirmed = await showWalletSheet<bool>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Confirmer la recharge'.tr(context),
            style: walletText(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _ConfirmRow(
            label: 'Opérateur'.tr(context),
            value: state.provider!.labelFr.tr(context),
          ),
          _ConfirmRow(label: 'Montant'.tr(context), value: formatWalletAmount(state.amount!)),
          _ConfirmRow(label: 'Téléphone'.tr(context), value: state.phoneText.trim()),
          const SizedBox(height: 16),
          UrbanPrimaryButton(
            label: 'Confirmer'.tr(context),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annuler'.tr(context),
              style: walletText(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final deposit = await cubit.submit();
    if (deposit == null || !context.mounted) return;
    context.pushReplacement(RouteConstants.walletDepositStatusPath(deposit.id));
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: walletText(fontSize: 14, color: AppColors.textSecondary)),
          ),
          Text(value, style: walletText(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
