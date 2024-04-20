import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:setore/setore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_state.freezed.dart';
part 'app_state.g.dart';

@freezed
class FreezedAppState with _$FreezedAppState {
  factory FreezedAppState({Setore? setore}) = _FreezedAppState;
}

@riverpod
class AppState extends _$AppState {
  @override
  FreezedAppState build() {
    return FreezedAppState();
  }

  void update(FreezedAppState Function(FreezedAppState) updater) {
    state = updater(state);
  }
}
