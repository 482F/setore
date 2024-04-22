import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:setore/setore.dart';

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
        Flexible(
          flex: 0,
          child: Consumer(
            builder: (context, ref, _) {
              final passphrase = ref.watch(_passphraseProvider);
              return TextButton(
                onPressed: () async {
                  final setore = Setore(
                    './s.sq3',
                    dllPathForWindows: './sqlcipher.dll',
                    passphrase: passphrase,
                  );
                  final verified = await setore
                      .readFieldByName('verify test')
                      .then((f) => true)
                      .catchError((_) => false);
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
