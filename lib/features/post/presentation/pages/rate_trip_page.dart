import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/core/widgets/rating_stars.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/presentation/cubit/rating_cubit.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/post/presentation/widgets/post_ui.dart';

class RateTripPage extends StatelessWidget {
  final String tripId;
  final String? ratedProfileId;

  const RateTripPage({super.key, required this.tripId, this.ratedProfileId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RatingCubit>()..load(tripId, preferredRatedProfileId: ratedProfileId),
      child: const _RateTripView(),
    );
  }
}

class _RateTripView extends StatelessWidget {
  const _RateTripView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RatingCubit, RatingState>(
      listenWhen: (p, n) => p.status != n.status,
      listener: (context, state) {
        if (state.status == RatingViewStatus.success) {
          context.pushReplacement(RouteConstants.tripRateSuccess);
        }
      },
      builder: (context, state) {
        if (state.status == RatingViewStatus.loading || state.status == RatingViewStatus.initial) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (state.status == RatingViewStatus.impossible) {
          return RatingImpossiblePage(
            reason: state.impossibleReason ?? RatingImpossibleReason.forbidden,
            message: state.errorMessage?.tr(context),
            tripId: state.tripId,
          );
        }

        if (state.status == RatingViewStatus.failure && state.trip == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: AppErrorView(
                message: (state.errorMessage ?? 'Impossible de charger la notation.').tr(context),
                onRetry: () => context.read<RatingCubit>().load(state.tripId ?? ''),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      PostBackButton(onTap: () => context.pop()),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Noter le trajet'.tr(context), style: postText(fontSize: 26, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                    children: [
                      if (state.trip != null) ...[
                        Text(
                          state.trip!.routeLabel,
                          textAlign: TextAlign.center,
                          style: postText(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 22),
                      ],
                      Text(
                        'Comment s’est passé le trajet ?'.tr(context),
                        textAlign: TextAlign.center,
                        style: postText(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 20),
                      RatingStars(
                        value: state.stars,
                        onChanged: context.read<RatingCubit>().setStars,
                      ),
                      const SizedBox(height: 28),
                      Text('Tags (optionnel)'.tr(context), style: postText(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: RatingTag.values.map((tag) {
                          final selected = state.selectedTags.contains(tag);
                          return GestureDetector(
                            onTap: () => context.read<RatingCubit>().toggleTag(tag),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: selected ? AppColors.primary : AppColors.outline),
                              ),
                              child: Text(
                                tag.labelFr.tr(context),
                                style: postText(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 22),
                      Text('Commentaire (optionnel)'.tr(context), style: postText(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                      const SizedBox(height: 8),
                      TextField(
                        maxLines: 4,
                        maxLength: 1000,
                        onChanged: context.read<RatingCubit>().setComment,
                        decoration: InputDecoration(
                          hintText: 'Partagez votre expérience…'.tr(context),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(color: AppColors.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(color: AppColors.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage!.tr(context),
                          style: postText(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: PostPrimaryButton(
                    label: 'Envoyer'.tr(context),
                    isLoading: state.status == RatingViewStatus.submitting,
                    onPressed: state.canSubmit || state.status == RatingViewStatus.submitting
                        ? () => context.read<RatingCubit>().submit()
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RatingSuccessPage extends StatelessWidget {
  const RatingSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFE8F8EE), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 22),
              Text(
                'Merci pour votre avis !'.tr(context),
                textAlign: TextAlign.center,
                style: postText(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'Votre note aide la communauté MOTO’DI GO à voyager en confiance.'.tr(context),
                textAlign: TextAlign.center,
                style: postText(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.4),
              ),
              const Spacer(),
              PostPrimaryButton(
                label: 'Voir l’historique'.tr(context),
                onPressed: () => context.go(RouteConstants.tripsHistory),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(RouteConstants.home),
                child: Text(
                  'Retour à l’accueil'.tr(context),
                  style: postText(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RatingImpossiblePage extends StatelessWidget {
  final RatingImpossibleReason reason;
  final String? message;
  final String? tripId;

  const RatingImpossiblePage({
    super.key,
    required this.reason,
    this.message,
    this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    final (title, body, icon) = switch (reason) {
      RatingImpossibleReason.notCompleted => (
        'Notation indisponible'.tr(context),
        (message ?? 'Le trajet doit être terminé avant de pouvoir le noter.').tr(context),
        Icons.hourglass_empty_rounded,
      ),
      RatingImpossibleReason.alreadyRated => (
        'Déjà noté'.tr(context),
        (message ?? 'Vous avez déjà envoyé une note pour ce trajet.').tr(context),
        Icons.star_rounded,
      ),
      RatingImpossibleReason.forbidden => (
        'Accès refusé'.tr(context),
        (message ?? 'Vous n’êtes pas autorisé à noter ce trajet.').tr(context),
        Icons.lock_outline_rounded,
      ),
      RatingImpossibleReason.notFound => (
        'Trajet introuvable'.tr(context),
        (message ?? 'Ce trajet n’existe pas ou n’est plus accessible.').tr(context),
        Icons.search_off_rounded,
      ),
      RatingImpossibleReason.noRatee => (
        'Notation impossible'.tr(context),
        (message ?? 'Impossible d’identifier le profil à noter.').tr(context),
        Icons.person_off_outlined,
      ),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: PostBackButton(onTap: () => context.canPop() ? context.pop() : context.go(RouteConstants.tripsHistory)),
              ),
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFF1F2ED), shape: BoxShape.circle),
                child: Icon(icon, size: 40, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 22),
              Text(title, textAlign: TextAlign.center, style: postText(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: postText(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.4),
              ),
              const Spacer(),
              PostPrimaryButton(
                label: 'Voir l’historique'.tr(context),
                onPressed: () => context.go(RouteConstants.tripsHistory),
              ),
              if (tripId != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.push(RouteConstants.support, extra: SupportContext(tripId: tripId)),
                  child: Text(
                    'Contacter le support'.tr(context),
                    style: postText(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
