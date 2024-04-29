import 'package:flutter/material.dart';

class ListViewWithStickyHeader<I> extends StatelessWidget {
  ListViewWithStickyHeader({
    super.key,
    required this.header,
    required this.items,
    required this.itemBuilder,
  });

  final Widget header;
  final List<I>? items;
  final Widget Function(I, int) itemBuilder;

  @override
  build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, bodyIsScrolled) => [
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverAppBar(
            automaticallyImplyLeading: false,
            title: header,
            pinned: true,
          ),
        )
      ],
      body: Builder(
        builder: (context) => CustomScrollView(
          slivers: [
            SliverOverlapInjector(
              // This is the flip side of the SliverOverlapAbsorber
              // above.
              handle:
                  NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => itemBuilder(items![i], i),
                childCount: items?.length ?? 0,
              ),
            )
          ],
        ),
      ),
    );
  }
}

