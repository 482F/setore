import 'package:drift/drift.dart';
import 'package:setore/sqlite3.dart' as sqlite3;

part 'drift.g.dart';

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
  TextColumn get name => text().unique()();
  BoolColumn get isSecret => boolean()();
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
