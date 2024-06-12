import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:setore/app_state.dart';
import 'package:setore/drift.dart';

part 'entry_detail.g.dart';

@riverpod
class _IsEdit extends _$IsEdit {
  @override
  bool build() {
    return true;
  }

  void update(bool newValue) {
    state = newValue;
  }
}

class EntryDetail extends ConsumerWidget {
  EntryDetail({super.key, required this.item, required this.onUpdate});

  final _isEditProvider =
      AutoDisposeNotifierProvider<_IsEdit, bool>(() => _IsEdit());

  final Entry item;
  final void Function(Entry) onUpdate;
  @override
  build(BuildContext context, WidgetRef ref) {
    final fields = switch (ref.watch(fieldsProvider)) {
          AsyncError(error: final e) => throw e,
          AsyncData(value: final v) => v,
          _ => null,
        } ??
        [];
    final isEdit = ref.watch(_isEditProvider);
    return isEdit
        ? EntryDetailEdit(
            item: item,
            fields: fields,
            onExit: () => ref.read(_isEditProvider.notifier).update(false),
            onSubmit: (newItem) {
              ref.read(_isEditProvider.notifier).update(false);
              onUpdate(newItem);
            },
          )
        : EntryDetailShow(
            item: item,
            fields: fields,
            onEditButton: () => ref.read(_isEditProvider.notifier).update(true),
          );
  }
}

@riverpod
class _EntriesFields extends _$EntriesFields {
  @override
  List<EntriesFields> build() {
    return [];
  }

  void add(EntriesFields field) {
    state = [...state, field];
  }
}

class EntryDetailEdit extends StatelessWidget {
  EntryDetailEdit({
    super.key,
    required this.item,
    required this.fields,
    required this.onExit,
    required this.onSubmit,
  });
  final Entry item;
  final List<Field> fields;
  final void Function() onExit;
  final void Function(Entry) onSubmit;

  @override
  build(BuildContext context) {
    return Column(
      children: [
        Text('edit'),
        IconButton(
          icon: Icon(Icons.plus_one),
          onPressed: () => {
            // TODO: mock change name
          },
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.cancel),
          onPressed: onExit,
        ),
      ],
    );
  }
}

class EntryDetailShow extends StatelessWidget {
  EntryDetailShow({
    super.key,
    required this.item,
    required this.fields,
    required this.onEditButton,
  });
  final Entry item;
  final List<Field> fields;
  final void Function() onEditButton;

  @override
  build(BuildContext context) {
    return Column(children: [
      Text(item.name),
      ...fields.map((field) => field.name).map((name) => Text(name)),
      Spacer(),
      IconButton(
        icon: Icon(Icons.edit),
        onPressed: onEditButton,
      ),
    ]);
  }
}
