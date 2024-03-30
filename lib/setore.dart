import 'dart:typed_data' show Uint8List;

import 'package:drift/drift.dart' show innerJoin;
import 'package:setore/drift.dart' as drift;
import 'package:setore/result.dart' show Result;

typedef InsertedGetter<T extends Object?> = ({Future<T> Function() get});

class Setore {
  final drift.AppDatabase appDb;
  Setore(
    final String dbPath, {
    final String? dllPathForWindows,
    final String? passphrase,
  }) : appDb = drift.AppDatabase(
          dbPath,
          dllPathForWindows: dllPathForWindows,
          passphrase: passphrase,
        );

  Future<Result<InsertedGetter<List<drift.Entry>>, List<String>>> createEntries(
    final Iterable<({String name})> entriesForInsert,
  ) async {}

  Future<List<drift.Entry>> readEntriesByNames(
    final Iterable<String> names,
  ) async {}

  Future<drift.Entry?> readEntryByName(
    final String name,
  ) async {}

  Future<Result<Null, List<drift.Field>>> updateEntries(
    final Iterable<drift.Entry> entries,
  ) async {}

  Future<Result<Null, List<int>>> deleteEntries(
    final Iterable<int> ids,
  ) async {}

  Future<Result<InsertedGetter<List<drift.EntryField>>, List<drift.Entry>>>
      createEntriesFields(
    final drift.Entry entry,
    final Iterable<({drift.Field field, Uint8List value})>
        entriesFieldsForInsert,
  ) async {}

  Future<List<drift.EntryField>> readEntriesFieldsByEntry(
    final drift.Entry entry,
  ) async {
    // 順番通りにソート
  }

  Future<Result<Null, List<drift.EntryField>>> updateEntriesFields(
    final Iterable<drift.EntryField> entriesFields,
  ) async {}

  Future<Result<Null, List<int>>> deleteEntriesFields(
    final Iterable<int> ids,
  ) async {}

  Future<Result<InsertedGetter<List<drift.Field>>, List<String>>> createFields(
    final Iterable<({String name, bool isSecret, drift.FieldType type})>
        fieldsForInsert,
  ) async {
    // TODO: return created fields
    // TODO: name unique validation
    await appDb.batch((batch) {
      batch.insertAll(
        appDb.fields,
        fieldsForInsert.map(
          (field) => drift.FieldsCompanion.insert(
            name: field.name,
            isSecret: field.isSecret,
            type: field.type,
          ),
        ),
      );
    });
  }

  Future<List<drift.Field>> readFieldsByNames(
    final Iterable<String> names,
  ) async {
    return await (appDb.select(appDb.fields)
          ..where((fields) => fields.name.isIn(names)))
        .get();
  }

  Future<drift.Field?> readFieldByName(
    final String name,
  ) async {
    return await (appDb.select(appDb.fields)
          ..where((fields) => fields.name.equals(name)))
        .getSingleOrNull();
  }

  Future<Result<Null, List<drift.Field>>> updateFields(
    final Iterable<drift.Field> fields,
  ) async {
    // TODO: validation
    final usingEntries = await (appDb.select(appDb.entries).join([
      innerJoin(
        appDb.entriesFields,
        appDb.entries.id.equalsExp(appDb.entriesFields.entryId),
      ),
    ])
          ..where(
            appDb.entriesFields.fieldId.isIn(fields.map((field) => field.id)),
          ))
        .get();

    await appDb.batch((batch) {
      batch.replaceAll(appDb.fields, fields);
    });
  }

  Future<Result<Null, List<int>>> deleteFields(
    final Iterable<int> ids,
  ) async {
    // TODO: validation
    await (appDb.delete(appDb.fields)..where((fields) => fields.id.isIn(ids)))
        .go();
  }
}
