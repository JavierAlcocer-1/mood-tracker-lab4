import 'package:flutter/material.dart';

import '../models/mood_entry.dart';
import 'mood_score_selector.dart';

/// A form for recording a new mood entry.
///
/// Exercise 1, step 3, and Exercise 2, steps 1-3.
class MoodEntryForm extends StatefulWidget {
  const MoodEntryForm({super.key, required this.onSubmit});

  /// Called with the new entry when the user saves it.
  final ValueChanged<MoodEntry> onSubmit;

  @override
  State<MoodEntryForm> createState() => _MoodEntryFormState();
}

class _MoodEntryFormState extends State<MoodEntryForm> {
  int? _score;
  final TextEditingController _noteController = TextEditingController();
  String? _formError;
  String? _noteError;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (_score == null) {
      setState(() {
        _formError = 'Choose a score from 1 to 10';
        _noteError = null;
      });
      return;
    }

    if (_noteController.text.length > maxNoteLength) {
      setState(() {
        _formError = null;
        _noteError = 'Note must be $maxNoteLength characters or fewer';
      });
      return;
    }

    final trimmedNote = _noteController.text.trim();
    final entry = MoodEntry(
      score: _score!,
      note: trimmedNote.isEmpty ? null : trimmedNote,
      createdAt: DateTime.now(),
    );
    widget.onSubmit(entry);
    setState(() {
      _score = null;
      _noteController.clear();
      _formError = null;
      _noteError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            MoodScoreSelector(
              selectedScore: _score,
              onChanged: (score) {
                setState(() {
                  _score = _score == score ? null : score;
                  _formError = null;
                });
              },
            ),
            TextField(
              controller: _noteController,
              onChanged: (note) {
                if (_noteError != null && note.length <= maxNoteLength) {
                  setState(() => _noteError = null);
                }
              },
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                errorText: _noteError,
              ),
            ),
            if (_formError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _formError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton(onPressed: _save, child: const Text('Save entry')),
          ],
        ),
      ),
    );
  }
}
