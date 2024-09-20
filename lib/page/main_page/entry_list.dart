import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:setore/component/list_view_with_sticky_header.dart';
import 'package:setore/drift.dart';

class EntryList extends ConsumerWidget {
  const EntryList({super.key, required this.onOpenItem, required this.entries});

  final void Function(Entry) onOpenItem;
  final List<Entry>? entries;

  @override
  build(BuildContext context, WidgetRef ref) {
    return ListViewWithStickyHeader(
      header: const Text('header'),
      items: entries,
      itemBuilder: (item, i) => ListTile(title: Text('$i-${item.name}')),
      onDoubleTapItem: onOpenItem,
    );
  }
}
