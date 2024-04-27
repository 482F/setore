import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:setore/app_state.dart';
import 'package:setore/drift.dart';

class EntryDetail extends ConsumerWidget {
  EntryDetail({super.key, required this.item});

  final Entry item;
  @override
  build(BuildContext context, WidgetRef ref) {
    final fields = switch (ref.watch(fieldsProvider)) {
          AsyncError(error: final e) => throw e,
          AsyncData(value: final v) => v,
          _ => null,
        } ??
        [];
    return Column(
      children: [
        Text(item.name),
        ...fields.map((field) => field.name).map((name) => Text(name)),
      ],
    );
  }
}
