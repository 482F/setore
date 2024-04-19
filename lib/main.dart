// TODO:
// ephemeral state 管理
//   riverpod はローカルの閉じた状態を管理するのには向いてなさそう
//   flutter_hooks とか、BLoC とかになるのかな
//   閉じた状態管理は一旦 stateful でやってみるべきかも
// p2p sync

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:setore/setore.dart' show Setore;

part 'main.g.dart';

void main() async {
  runApp(const ProviderScope(child: App()));
  final setore = Setore(
    './s.sq3',
    dllPathForWindows: './sqlcipher.dll',
    passphrase: 'asdf',
  );
  await setore.createEntries([(name: 'cr test${DateTime.now().toString()}')]);
  print(await setore.readEntries());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Flex(
          direction: Axis.horizontal,
          children: [
            V(Adder()),
            V(Adder()),
            // V(_Adder()),
          ],
        ),
      ),
    );
  }
}

class V extends StatelessWidget {
  V(this.child, {super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: child,
      flex: 1,
    );
  }
}

@riverpod
class RText extends _$RText {
  @override
  String build() {
    return '';
  }

  void update(String n) {
    state = n;
  }
}

class Adder extends StatelessWidget {
  Adder({super.key});

  final p = AutoDisposeNotifierProvider<RText, String>(() => RText());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        V(Consumer(
          builder: (context, ref, _) => Text(ref.watch(p)),
        )),
        V(Consumer(
          builder: (context, ref, _) => TextField(
            decoration: InputDecoration(
              labelText: 'StatelessWidget',
            ),
            onChanged: (value) {
              ref.read(p.notifier).update(value);
            },
          ),
        )),
      ],
    );
  }
}
