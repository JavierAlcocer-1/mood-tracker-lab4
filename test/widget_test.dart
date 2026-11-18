import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker/data/sample_entries.dart';
import 'package:mood_tracker/main.dart';
import 'package:mood_tracker/models/mood_entry.dart';
import 'package:mood_tracker/widgets/mood_card.dart';
import 'package:mood_tracker/widgets/mood_entry_form.dart';

// Self-check for Lab 4, Exercises 1 and 2. Run it with: flutter test
//
// Both tests fail on the starter code and pass once Exercise 2 is done.
// Exercise 3 changes what the Save button should do. Part of that task is
// to update these tests so they check the new requirement.

/// Renders the app in a window tall enough for every card to be built.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MoodTrackerApp());
}

Finder get saveButton => find.widgetWithText(FilledButton, 'Save entry');

void main() {
  testWidgets('saving without a score shows an error and adds no entry', (
    tester,
  ) async {
    await pumpApp(tester);

    final initialCardCount = tester.widgetList(find.byType(MoodCard)).length;
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);

    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Choose a score from 1 to 10'), findsOneWidget);
    expect(tester.widgetList(find.byType(MoodCard)).length, initialCardCount);
  });

  testWidgets('an over-limit note shows an error and adds no entry', (
    tester,
  ) async {
    await pumpApp(tester);
    final initialCardCount = tester.widgetList(find.byType(MoodCard)).length;

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextField),
      List.filled(maxNoteLength + 1, 'a').join(),
    );
    await tester.tap(saveButton);
    await tester.pump();

    expect(
      find.text('Note must be $maxNoteLength characters or fewer'),
      findsOneWidget,
    );
    expect(tester.widgetList(find.byType(MoodCard)).length, initialCardCount);
  });

  testWidgets('tapping a selected score deselects it', (tester) async {
    await pumpApp(tester);
    final scoreChip = find.widgetWithText(ChoiceChip, '3');

    await tester.tap(scoreChip);
    await tester.pump();
    expect(tester.widget<ChoiceChip>(scoreChip).selected, isTrue);

    await tester.tap(scoreChip);
    await tester.pump();

    expect(tester.widget<ChoiceChip>(scoreChip).selected, isFalse);
  });

  testWidgets('saving an entry puts it at the top of the history', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Rainy walk home');
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length + 1));
    expect(
      find.descendant(
        of: find.byType(MoodCard).first,
        matching: find.text('Rainy walk home'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a note at the character limit can be saved', (tester) async {
    final entries = <MoodEntry>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MoodEntryForm(onSubmit: entries.add)),
      ),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextField),
      List.filled(maxNoteLength, 'a').join(),
    );
    await tester.tap(saveButton);
    await tester.pump();

    expect(entries, hasLength(1));
    expect(entries.single.note, hasLength(maxNoteLength));
  });
}
