import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:setore/app_state.dart';
import 'package:setore/drift.dart';
import 'package:setore/page/main_page/entry_detail.dart';
import 'package:setore/page/main_page/entry_list.dart';

part 'main_page.g.dart';

@riverpod
class OpenedItem extends _$OpenedItem {
  @override
  Entry? build() {
    return null;
  }

  void update(Entry? item) {
    state = item;
  }
}

final List<String> l = [];

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  build(BuildContext context, WidgetRef ref) {
    final filteredEntriesProvider = entriesProvider(l);
    final entries = switch (ref.watch(filteredEntriesProvider)) {
      AsyncError(error: final e) => throw e,
      AsyncData(value: final entries) => entries,
      _ => null,
    };
    final openedItem = ref.watch(openedItemProvider);

    return Row(
      children: [
        EntryList(
          onOpenItem: (item) =>
              ref.read(openedItemProvider.notifier).update(item),
          entries: entries,
        ),
        openedItem == null
            ? const Placeholder()
            : EntryDetail(
                item: openedItem,
                onUpdate: (newEntry) => ref
                    .read(filteredEntriesProvider.notifier)
                    .updateEntry(newEntry),
              ),
      ].map((widget) => Expanded(child: widget)).toList(),
    );
  }
}
