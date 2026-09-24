import 'package:flutter_test/flutter_test.dart';

import 'package:stockai_v_0_1/main.dart';

void main() {
  testWidgets('StockAI app loads with main screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StockAIApp());

    expect(find.text('StockAI'), findsOneWidget);
    expect(find.text('Выбрать фотографии'), findsOneWidget);
  });
}
