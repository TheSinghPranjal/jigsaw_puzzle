import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jigsaw_puzzle/app/theme/app_theme.dart';
import 'package:jigsaw_puzzle/core/widgets/common.dart';

void main() {
  for (final p in themePalettes) {
    testWidgets('${p.name} builds light and dark', (tester) async {
      for (final b in Brightness.values) {
        await tester.pumpWidget(MaterialApp(theme: buildTheme(p, b), home: const Scaffold(body: Column(children: [ProgressBar(value: .5), StarRow(2), PrimaryButton(label: 'Go', onPressed: null)]))));
        expect(find.text('Go'), findsOneWidget);
      }
    });
  }
}
