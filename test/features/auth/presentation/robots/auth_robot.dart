import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';

class AuthRobot {
  final WidgetTester tester;

  AuthRobot(this.tester);

  // ─── Finders ────────────────────────────────────────────────────────────

  Finder get emailField => find.widgetWithText(TextFormField, 'Email');
  Finder get passwordField => find.widgetWithText(TextFormField, 'Password');
  Finder get confirmPasswordField =>
      find.widgetWithText(TextFormField, 'Confirm Password');
  Finder get fullNameField => find.widgetWithText(TextFormField, 'Full Name');
  Finder get phoneField => find.widgetWithText(TextFormField, 'Phone Number');
  Finder get loginButton => find.byWidgetPredicate(
        (widget) => widget is NeonButton && widget.label == 'LOGIN',
      );
  Finder get registerButton => find.byWidgetPredicate(
        (widget) => widget is NeonButton && widget.label == 'REGISTER',
      );
  Finder get registerNowLink => find.text('Register now');
  Finder get loginNowLink => find.text('Login');

  // ─── Actions ────────────────────────────────────────────────────────────

  Future<void> enterEmail(String email) async {
    await tester.enterText(emailField, email);
    await tester.pump();
  }

  Future<void> enterPassword(String password) async {
    await tester.enterText(passwordField, password);
    await tester.pump();
  }

  Future<void> enterConfirmPassword(String password) async {
    await tester.enterText(confirmPasswordField, password);
    await tester.pump();
  }

  Future<void> enterFullName(String name) async {
    await tester.enterText(fullNameField, name);
    await tester.pump();
  }

  Future<void> enterPhone(String phone) async {
    await tester.enterText(phoneField, phone);
    await tester.pump();
  }

  Future<void> tapLogin() async {
    await tester.tap(loginButton);
    await tester.pump();
  }

  Future<void> tapRegister() async {
    await tester.tap(registerButton);
    await tester.pump();
  }

  Future<void> tapRegisterNow() async {
    await tester.ensureVisible(registerNowLink);
    await tester.tap(registerNowLink);
    await tester.pumpAndSettle();
  }

  Future<void> tapLoginNow() async {
    await tester.ensureVisible(loginNowLink);
    await tester.tap(loginNowLink);
    await tester.pumpAndSettle();
  }

  // ─── Assertions ─────────────────────────────────────────────────────────

  void expectLoginScreenVisible() {
    expect(find.text('Welcome\nBack 👋'), findsOneWidget);
  }

  void expectRegisterScreenVisible() {
    expect(find.text('Create Account 🏓'), findsOneWidget);
  }

  void expectErrorText(String text) {
    expect(find.text(text), findsOneWidget);
  }

  void expectLoading(bool isLoading) {
    if (isLoading) {
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    } else {
      expect(find.byType(CircularProgressIndicator), findsNothing);
    }
  }
}
