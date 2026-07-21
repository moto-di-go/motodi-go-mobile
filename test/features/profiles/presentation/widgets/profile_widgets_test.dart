import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_widgets.dart';

void main() {
  testWidgets('ProfileChoiceCard renders selected passenger as active', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileChoiceCard(
            type: ProfileType.passenger,
            profile: const UserProfile(
              id: 'passenger-1',
              userId: 'user-1',
              type: ProfileType.passenger,
              validationStatus: ValidationStatus.validated,
              displayName: 'Passager',
              averageRating: 0,
              active: true,
              allowedActions: [],
            ),
            selected: true,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Passager'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}
