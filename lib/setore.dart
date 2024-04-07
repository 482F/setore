import 'dart:typed_data' show Uint8List;

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart' show SqliteException;
import 'package:setore/drift.dart' as db;
import 'package:setore/result.dart' show Failure, Result, Success;

typedef InsertedGetter<T extends Object?> = ({Future<T> Function() get});

class Setore {
  final db.AppDatabase appDb;
  Setore(
    final String dbPath, {
    final String? dllPathForWindows,
    final String? passphrase,
  }) : appDb = db.AppDatabase(
          dbPath,
          dllPathForWindows: dllPathForWindows,
          passphrase: passphrase,
        );

  Future<Result<InsertedGetter<List<db.Entry>>, List<String>>> createEntries(
    final Iterable<({String name})> entriesForInsert,
  ) async {
    final result = await appDb
        .batch((batch) {
          batch.insertAll(
            appDb.entries,
            entriesForInsert.map(
              (entry) => db.EntriesCompanion.insert(
                name: entry.name,
              ),
            ),
          );
        })
        .then((_) => true)
        .catchError((e) {
          return false;
        }, test: (e) => e is SqliteException);

    final names = entriesForInsert.map((entry) => entry.name);
    if (!result) {
      return Failure(names.toList());
    }
    return Success((get: () async => await readEntriesByNames(names)));
  }

  Future<List<db.Entry>> readEntriesByNames(
    final Iterable<String> names,
  ) async {
    return await (appDb.select(appDb.entries)
          ..where((entries) => entries.name.isIn(names)))
        .get();
  }

  // Future<db.Entry?> readEntryByName(
  //   final String name,
  // ) async {}

  // Future<Result<Null, List<db.Field>>> updateEntries(
  //   final Iterable<db.Entry> entries,
  // ) async {}

  // Future<Result<Null, List<int>>> deleteEntries(
  //   final Iterable<int> ids,
  // ) async {}

  // Future<Result<InsertedGetter<List<db.EntryField>>, List<db.Entry>>>
  //     createEntriesFields(
  //   final db.Entry entry,
  //   final Iterable<({db.Field field, Uint8List value})> entriesFieldsForInsert,
  // ) async {}

  // Future<List<db.EntryField>> readEntriesFieldsByEntry(
  //   final db.Entry entry,
  // ) async {
  //   // 順番通りにソート
  // }

  // Future<Result<Null, List<db.EntryField>>> updateEntriesFields(
  //   final Iterable<db.EntryField> entriesFields,
  // ) async {}

  // Future<Result<Null, List<int>>> deleteEntriesFields(
  //   final Iterable<int> ids,
  // ) async {}

  // Future<Result<InsertedGetter<List<db.Field>>, List<String>>> createFields(
  //   final Iterable<({String name, bool isSecret, db.FieldType type})>
  //       fieldsForInsert,
  // ) async {
  //   // TODO: return created fields
  //   // TODO: name unique validation
  //   await appDb.batch((batch) {
  //     batch.insertAll(
  //       appDb.fields,
  //       fieldsForInsert.map(
  //         (field) => db.FieldsCompanion.insert(
  //           name: field.name,
  //           isSecret: field.isSecret,
  //           type: field.type,
  //         ),
  //       ),
  //     );
  //   });
  // }

  // Future<List<db.Field>> readFieldsByNames(
  //   final Iterable<String> names,
  // ) async {
  //   return await (appDb.select(appDb.fields)
  //         ..where((fields) => fields.name.isIn(names)))
  //       .get();
  // }

  // Future<db.Field?> readFieldByName(
  //   final String name,
  // ) async {
  //   return await (appDb.select(appDb.fields)
  //         ..where((fields) => fields.name.equals(name)))
  //       .getSingleOrNull();
  // }

  // Future<Result<Null, List<db.Field>>> updateFields(
  //   final Iterable<db.Field> fields,
  // ) async {
  //   // TODO: validation
  //   final usingEntries = await (appDb.select(appDb.entries).join([
  //     drift.innerJoin(
  //       appDb.entriesFields,
  //       appDb.entries.id.equalsExp(appDb.entriesFields.entryId),
  //     ),
  //   ])
  //         ..where(
  //           appDb.entriesFields.fieldId.isIn(fields.map((field) => field.id)),
  //         ))
  //       .get();

  //   await appDb.batch((batch) {
  //     batch.replaceAll(appDb.fields, fields);
  //   });
  // }

  // Future<Result<Null, List<int>>> deleteFields(
  //   final Iterable<int> ids,
  // ) async {
  //   // TODO: validation
  //   await (appDb.delete(appDb.fields)..where((fields) => fields.id.isIn(ids)))
  //       .go();
  // }
}
