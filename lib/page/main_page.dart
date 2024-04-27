import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  build(BuildContext context, WidgetRef ref) {
    final openedItem = ref.watch(openedItemProvider);
    return Row(
      children: [
        EntryList(
          onOpenItem: (item) =>
              ref.read(openedItemProvider.notifier).update(item),
        ),
        openedItem == null
            ? const Placeholder()
            : EntryDetail(item: openedItem),
      ].map((widget) => Expanded(child: widget)).toList(),
    );
  }
}
