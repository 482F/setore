import 'dart:async' as async;

import 'package:drift/drift.dart';
import 'package:setore/sqlite3.dart' as sqlite3;

part 'drift.g.dart';

@DataClassName('Entry')
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

enum FieldType<T extends Object> {
  text<String>(encode: _encodeString, decode: _decodeString),
  memo<String>(encode: _encodeString, decode: _decodeString),
  totpToken<String>(encode: _encodeString, decode: _decodeString);

  const FieldType({
    required this.encode,
    required this.decode,
  });

  final async.FutureOr<Uint8List> Function(T?) encode;
  final async.FutureOr<T?> Function(Uint8List) decode;

  static Uint8List _encodeString(String? s) =>
      Uint8List.fromList((s ?? '').codeUnits);
  static String _decodeString(Uint8List u) => String.fromCharCodes(u);
}

class Fields extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  BoolColumn get isSecret => boolean()();
  IntColumn get type => intEnum<FieldType<Object>>()();

  static final List<Object? Function(Field)> _unmodifiableValueGetters = [
    (field) => field.type,
  ];
  static bool isModifiedUnmodifiableValue(Field a, Field b) {
    return _unmodifiableValueGetters.any((getter) => getter(a) != getter(b));
  }
}

@DataClassName('EntryField')
class EntriesFields extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get entryId =>
      integer().references(Entries, #id, onDelete: KeyAction.cascade)();
  IntColumn get fieldId =>
      integer().references(Fields, #id, onDelete: KeyAction.restrict)();
  IntColumn get nextField => integer()
      .unique()
      .nullable()
      .references(EntriesFields, #id, onDelete: KeyAction.restrict)();
  BlobColumn get value => blob()();
}

@DriftDatabase(tables: [
  Entries,
  Fields,
  EntriesFields,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(
    final String path, {
    final String? dllPathForWindows,
    final String? passphrase,
  }) : super(sqlite3.createLazyDb(
          path,
          dllPathForWindows: dllPathForWindows,
          passphrase: passphrase,
        ));

  @override
  int get schemaVersion => 1;
}
