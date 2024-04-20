// TODO:
// ephemeral state 管理
//   riverpod はローカルの閉じた状態を管理するのには向いてなさそう
//   flutter_hooks とか、BLoC とかになるのかな
//   閉じた状態管理は一旦 stateful でやってみるべきかも
// p2p sync

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:setore/app_router.dart';

void main() async {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRouter();
  }
}
