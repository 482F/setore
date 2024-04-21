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
import 'package:setore/tabs.dart';
import 'package:setore/verify.dart';

part 'main.g.dart';

void main() async {
  runApp(ProviderScope(child: App()));
  // final setore = Setore(
  //   './s.sq3',
  //   dllPathForWindows: './sqlcipher.dll',
  //   passphrase: 'asdf',
  // );
  // await setore.createEntries([(name: 'cr test${DateTime.now().toString()}')]);
  // print(await setore.readEntries());
}

@riverpod
class _Setore extends _$Setore {
  @override
  Setore? build() {
    return null;
  }

  void update(Setore? setore) {
    state = setore;
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, _) {
            final setore = ref.watch(_setoreProvider);
            if (setore == null) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Verify(
                    onVerified: (setore) =>
                        ref.read(_setoreProvider.notifier).update(setore),
                  ),
                ),
              );
            } else {
              setore.readEntries().then((es) => print(es));
              return FutureBuilder(
                  future: setore.readEntries().then((es) => es),
                  builder: (context, snapshot) => switch (snapshot) {
                        AsyncSnapshot(hasData: true, data: final data) =>
                          Tabs(builder: () => (title: 'a', widget: Text('a'))),
                        _ => Text('yet'),
                      });
            }
          },
        ),
      ),
    );
  }
}
