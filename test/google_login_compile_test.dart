import 'package:flutter_test/flutter_test.dart';
import 'package:biji_coffee/pages/auth/google_login_page.dart';

void main() {
  testWidgets('GoogleLoginScreen compiles', (WidgetTester tester) async {
    // Just importing it is enough to check for fundamental compilation errors
    // related to missing dependencies or syntax.
    await tester.pumpWidget(const MaterialApp(home: GoogleLoginScreen()));
  });
}
