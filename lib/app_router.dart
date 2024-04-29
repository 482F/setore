import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:setore/app_state.dart';
import 'package:setore/entry_list.dart';
import 'package:setore/setore.dart';
import 'package:setore/verify.dart';

part 'app_router.g.dart';

class EntryListRoute extends GoRouteData {
  EntryListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Row(
      children: [
        const EntryList(),
        const Placeholder(),
      ].map((widget) => Expanded(child: widget)).toList(),
    );
  }
}

class VerifyRoute extends GoRouteData {
  VerifyRoute({this.$extra});
  final void Function(BuildContext, Setore)? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final isVerified = $extra;
    if (isVerified == null) return const Placeholder();
    return Verify(onVerified: isVerified);
  }
}

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<VerifyRoute>(path: 'verify'),
    TypedGoRoute<EntryListRoute>(path: 'entry-list'),
  ],
)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const Placeholder();
}

@riverpod
GoRouter _router(_RouterRef ref) {
  // ignore: prefer_function_declarations_over_variables
  final onVerified = (BuildContext context, Setore setore) {
    setSetore(ref, setore);
    EntryListRoute().go(context);
  };
  return GoRouter(
    initialExtra: onVerified,
    initialLocation: VerifyRoute($extra: onVerified).location,
    routes: $appRoutes,
  );
}

class AppRouter extends ConsumerWidget {
  AppRouter({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      builder: (context, widget) => Scaffold(body: widget),
      debugShowCheckedModeBanner: false,
    );
  }
}
