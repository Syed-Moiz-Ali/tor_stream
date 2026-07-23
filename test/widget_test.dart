import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tor_stream/app/app.dart';

void main() {
  testWidgets('TorStream app renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TorStreamApp()));

    expect(find.text('TorStream'), findsWidgets);
  });
}
