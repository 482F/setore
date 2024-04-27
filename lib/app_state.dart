import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:setore/drift.dart';
import 'package:setore/setore.dart';

part 'app_state.g.dart';

@Riverpod(keepAlive: true)
class _Setore extends _$Setore {
  @override
  Setore? build() {
    return null;
  }

  void update(Setore setore) {
    print('update');
    state = setore;
  }

  Setore get(AutoDisposeRef<Object?> ref) {
    print('get');
    final setore = ref.watch(_setoreProvider);
    if (setore == null) throw 'no setore';
    return setore;
  }
}

void setSetore(AutoDisposeRef<Object?> ref, Setore setore) {
  ref.read(_setoreProvider.notifier).update(setore);
}

@riverpod
Future<List<Entry>> entries(EntriesRef ref, List<String> names) {
  final setore = ref.read(_setoreProvider.notifier).get(ref);
  // TODO: ref.invalidateSelf();
  return setore.readEntriesByPartNames(names);
}

@riverpod
class Fields extends _$Fields {
  Setore get _setore => ref.read(_setoreProvider.notifier).get(ref);
  @override
  Future<List<Field>> build() {
    return _setore.readFields();
  }

  void addField() {
    _setore.createFields([
      (
        isSecret: false,
        name: DateTime.now().toIso8601String(),
        type: FieldType.text
      ),
    ]);
    ref.invalidateSelf();
  }
}
