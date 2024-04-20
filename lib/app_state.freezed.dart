// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FreezedAppState {
  Setore? get setore => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FreezedAppStateCopyWith<FreezedAppState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FreezedAppStateCopyWith<$Res> {
  factory $FreezedAppStateCopyWith(
          FreezedAppState value, $Res Function(FreezedAppState) then) =
      _$FreezedAppStateCopyWithImpl<$Res, FreezedAppState>;
  @useResult
  $Res call({Setore? setore});
}

/// @nodoc
class _$FreezedAppStateCopyWithImpl<$Res, $Val extends FreezedAppState>
    implements $FreezedAppStateCopyWith<$Res> {
  _$FreezedAppStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? setore = freezed,
  }) {
    return _then(_value.copyWith(
      setore: freezed == setore
          ? _value.setore
          : setore // ignore: cast_nullable_to_non_nullable
              as Setore?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FreezedAppStateImplCopyWith<$Res>
    implements $FreezedAppStateCopyWith<$Res> {
  factory _$$FreezedAppStateImplCopyWith(_$FreezedAppStateImpl value,
          $Res Function(_$FreezedAppStateImpl) then) =
      __$$FreezedAppStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Setore? setore});
}

/// @nodoc
class __$$FreezedAppStateImplCopyWithImpl<$Res>
    extends _$FreezedAppStateCopyWithImpl<$Res, _$FreezedAppStateImpl>
    implements _$$FreezedAppStateImplCopyWith<$Res> {
  __$$FreezedAppStateImplCopyWithImpl(
      _$FreezedAppStateImpl _value, $Res Function(_$FreezedAppStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? setore = freezed,
  }) {
    return _then(_$FreezedAppStateImpl(
      setore: freezed == setore
          ? _value.setore
          : setore // ignore: cast_nullable_to_non_nullable
              as Setore?,
    ));
  }
}

/// @nodoc

class _$FreezedAppStateImpl implements _FreezedAppState {
  _$FreezedAppStateImpl({this.setore});

  @override
  final Setore? setore;

  @override
  String toString() {
    return 'FreezedAppState(setore: $setore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FreezedAppStateImpl &&
            (identical(other.setore, setore) || other.setore == setore));
  }

  @override
  int get hashCode => Object.hash(runtimeType, setore);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FreezedAppStateImplCopyWith<_$FreezedAppStateImpl> get copyWith =>
      __$$FreezedAppStateImplCopyWithImpl<_$FreezedAppStateImpl>(
          this, _$identity);
}

abstract class _FreezedAppState implements FreezedAppState {
  factory _FreezedAppState({final Setore? setore}) = _$FreezedAppStateImpl;

  @override
  Setore? get setore;
  @override
  @JsonKey(ignore: true)
  _$$FreezedAppStateImplCopyWith<_$FreezedAppStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
