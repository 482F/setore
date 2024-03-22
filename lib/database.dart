import 'dart:ffi';

import 'package:drift/drift.dart';
import 'package:my_app/sqlite3.dart' as sqlite3;
import 'package:sqlite3/open.dart' as sqlite3_open;

part 'database.g.dart';

@DataClassName('Entry')
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

enum FieldType {
  text,
  memo,
  number,
  date,
  totpToken,
}

class Fields extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get secret => boolean()();
  IntColumn get type => intEnum<FieldType>()();
}

@DataClassName('EntryField')
class EntriesFields extends Table {
  IntColumn get entryId => integer().references(Entries, #id)();
  IntColumn get fieldId => integer().references(Fields, #id)();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [Entries, Fields, EntriesFields])
class AppDatabase extends _$AppDatabase {
  AppDatabase(final String path,
      {final String? dllPathForWindows, final String? passphrase})
      : super(sqlite3.createLazyDb(path, passphrase: passphrase)) {
    if (dllPathForWindows != null) {
      sqlite3_open.open.overrideFor(
        sqlite3_open.OperatingSystem.windows,
        () => openOnWindows(dllPathForWindows),
      );
    }
  }

  @override
  int get schemaVersion => 1;
}

DynamicLibrary openOnWindows(String dllPath) {
  return DynamicLibrary.open(dllPath);
}
