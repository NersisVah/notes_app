import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../resources/app_sizes.dart';
import '../view_model/note_editor_cubit.dart';

/// Title and body fields. Text is kept in [NoteEditorCubit], so it survives
/// switching between view and edit mode.
class NoteFormView extends StatelessWidget {
  const NoteFormView({super.key});

  static String? _notBlank(String? value, String fieldName) =>
      (value ?? '').trim().isEmpty ? '$fieldName can\'t be empty' : null;

  static void _unfocus(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NoteEditorCubit>();
    final textTheme = Theme.of(context).textTheme;

    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: cubit.state.title,
              onTapOutside: _unfocus,
              onChanged: cubit.titleChanged,
              validator: (value) => _notBlank(value, 'Title'),
              style: textTheme.titleLarge,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextFormField(
              initialValue: cubit.state.body,
              onTapOutside: _unfocus,
              onChanged: cubit.bodyChanged,
              validator: (value) => _notBlank(value, 'Note'),
              style: textTheme.bodyMedium,
              minLines: 3,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Note',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
