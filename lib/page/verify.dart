import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:setore/setore.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

part 'verify.g.dart';

@riverpod
class _Passphrase extends _$Passphrase {
  @override
  String build() {
    return '';
  }

  void update(String newPassphrase) {
    state = newPassphrase;
  }
}

@riverpod
class _TemptempDir extends _$TemptempDir {
  @override
  String build() {
    return 'null';
  }

  void update(String newD) {
    state = newD;
  }
}

class Verify extends StatelessWidget {
  const Verify({super.key, required this.onVerified});
  final void Function(BuildContext, Setore) onVerified;
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Flexible(
          flex: 1,
          child: Consumer(
            builder: (context, ref, _) => TextField(
              decoration: InputDecoration(
                labelText: 'passphrase',
              ),
              onChanged: (value) {
                ref.read(_passphraseProvider.notifier).update(value);
              },
            ),
          ),
        ),
        Consumer(
            builder: (context, ref, _) => Text(ref.watch(_temptempDirProvider))),
        Flexible(
          flex: 0,
          child: Consumer(
            builder: (context, ref, _) {
              final passphrase = ref.watch(_passphraseProvider);
              path_provider.getApplicationSupportDirectory().then((dir) => ref
                  .read(_temptempDirProvider.notifier)
                  .update(path.join(dir.path, 's.sq3')));

              return TextButton(
                onPressed: () async {
                  final dir =
                      await path_provider.getApplicationSupportDirectory();
                  final setore = Setore(
                    path.join(dir.path, 's.sq3'),
                    dllPathForWindows: './sqlcipher.dll',
                    passphrase: passphrase,
                  );
                  final verified = await setore
                      .readFieldByName('verify test')
                      .then((f) => true)
                      .catchError((e) {
                        print(e);
                        return false;
                      });
                  if (verified) {
                    onVerified(context, setore);
                  } else {
                    await setore.dispose();
                  }
                },
                child: Text('Submit'),
              );
            },
          ),
        ),
      ],
    );
  }
}
