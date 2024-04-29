import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:setore/app_state.dart';
import 'package:setore/component/list-view-with-sticky-header.dart';

final List<String> l = [];


class EntryList extends ConsumerWidget {
  const EntryList({super.key});

  @override
  build(BuildContext context, WidgetRef ref) {
    final entries = switch (ref.watch(entriesProvider(l))) {
      AsyncError(error: final e) => throw e,
      AsyncData(value: final entries) => entries,
      _ => null,
    };
    return ListViewWithStickyHeader(
      header: const Text('header'),
      items: entries,
      itemBuilder: (item, i) => ListTile(title: Text('$i-${item.name}')),
    );
  }
}
