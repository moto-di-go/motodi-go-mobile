import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_fields.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/otp_code_field.dart';

void main() {
  testWidgets('CameroonPhoneInput renders the Cameroon prefix and hint', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CameroonPhoneInput(controller: controller)),
      ),
    );

    expect(find.text('+237'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('OtpCodeField limits entry to six digits', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: OtpCodeField(controller: controller)),
      ),
    );

    await tester.enterText(find.byType(EditableText), '1234567');
    await tester.pump();

    expect(controller.text, '123456');
  });
}
