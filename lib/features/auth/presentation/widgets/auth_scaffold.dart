import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';

class AuthScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool showBack;
  final Widget? bottom;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  const AuthScaffold({
    super.key,
    this.title,
    required this.child,
    this.showBack = false,
    this.bottom,
    this.padding = const EdgeInsets.fromLTRB(28, 20, 28, 24),
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || showBack) _Header(title: title, showBack: showBack),
          if (title != null || showBack) const SizedBox(height: 28),
          child,
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFBFCF8),
      body: SafeArea(
        child: scrollable
            ? SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: content,
              )
            : content,
      ),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(minimum: const EdgeInsets.fromLTRB(28, 8, 28, 24), child: bottom!),
    );
  }
}

class _Header extends StatelessWidget {
  final String? title;
  final bool showBack;

  const _Header({this.title, required this.showBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          Material(
            color: const Color(0xFFF1F2ED),
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.canPop() ? context.pop() : context.go('/welcome'),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              ),
            ),
          ),
        if (showBack) const SizedBox(width: 16),
        if (title != null)
          Expanded(
            child: Text(
              title!,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}
