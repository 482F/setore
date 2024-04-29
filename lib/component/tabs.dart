import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tabs.g.dart';

typedef TabState = Map<Key, ({String title, Widget widget})>;

@riverpod
class TabMap extends _$TabMap {
  @override
  TabState build() {
    return {};
  }

  void add(String title, Widget widget) {
    state = Map.fromEntries([
      ...state.entries,
      MapEntry(UniqueKey(), (title: title, widget: widget)),
    ]);
  }

  void updateTitle(UniqueKey key, String title) {
    final tab = state[key];
    if (tab == null) return;

    state = Map.fromEntries([
      ...state.entries,
      MapEntry(key, (title: title, widget: tab.widget)),
    ]);
  }

  void remove(UniqueKey key) {
    state = Map.fromEntries(state.entries.where((entry) => entry.key != key));
  }
}

class Tabs extends ConsumerWidget {
  Tabs({super.key, required this.builder});

  final ({String title, Widget widget}) Function() builder;

  final tabMapProvider =
      AutoDisposeNotifierProvider<TabMap, TabState>(() => TabMap());

  @override
  build(BuildContext context, WidgetRef ref) {
    final tabMap = ref.watch(tabMapProvider);
    final tabs = tabMap.values;
    return DefaultTabController(
      length: tabMap.length,
      child: Flex(
        direction: Axis.vertical,
        children: [
          Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(
                child: TabBar(
                  tabs: tabs.map((tab) => Tab(text: tab.title)).toList(),
                ),
              ),
              IconButton(
                onPressed: () {
                  final tab = builder();
                  ref.read(tabMapProvider.notifier).add(tab.title, tab.widget);
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Flexible(
            child: TabBarView(
              children: tabs.map((tab) => tab.widget).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
