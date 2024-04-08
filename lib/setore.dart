import 'dart:async' show FutureOr;
import 'dart:typed_data' show Uint8List;

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart' show SqliteException;
import 'package:setore/drift.dart' as db;
import 'package:setore/result.dart' show Failure, Result, Success;

typedef Getter<T extends Object?> = ({FutureOr<T> Function() get});

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

  Future<Result<Getter<List<db.Entry>>, Getter<List<String>>>> createEntries(
    final Iterable<({String name})> entriesForInsert,
  ) async {
    final succeeded = await appDb
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
        .catchError(
          (_) => false,
          test: (e) => e is SqliteException,
        );

    final names = entriesForInsert.map((entry) => entry.name);
    if (!succeeded) {
      return Failure((
        get: () async => await readEntriesByNames(names)
            .then((es) => es.map((e) => e.name).toList())
      ));
    }
    return Success((get: () async => await readEntriesByNames(names)));
  }

  Future<List<db.Entry>> readEntries() async {
    return await appDb.select(appDb.entries).get();
  }

  Future<List<db.Entry>> readEntriesByNames(
    final Iterable<String> names,
  ) async {
    return await (appDb.select(appDb.entries)
          ..where((entries) => entries.name.isIn(names)))
        .get();
  }

  Future<db.Entry?> readEntryByName(
    final String name,
  ) async {
    return await (appDb.select(appDb.entries)
          ..where((entries) => entries.name.equals(name)))
        .getSingleOrNull();
  }

  Future<List<db.Entry>> readEntriesByPartNames(
    final List<String> partNames,
  ) async {
    return await (appDb.select(appDb.entries)
          ..where((entries) => partNames
              .map((partName) => entries.name.like('%$partName%'))
              .reduce((allExp, exp) => allExp | exp)))
        .get();
  }

  Future<Result<Null, Getter<List<db.Entry>>>> updateEntries(
    final Iterable<db.Entry> entries,
  ) async {
    final succeeded = await appDb
        .batch((batch) {
          batch.replaceAll(appDb.entries, entries);
        })
        .then((_) => true)
        .catchError(
          (_) => false,
          test: (e) => e is SqliteException,
        );
    if (!succeeded) {
      return Failure((
        get: () async {
          final names = entries.map((entry) => entry.name);
          final existingEntryNames = await (appDb.select(appDb.entries)
                ..where((entries) => entries.name.isIn(names)))
              .get()
              .then((es) => es.toSet().map((e) => e.name));
          return entries
              .where((entry) => existingEntryNames.contains(entry.name))
              .toList();
        }
      ));
    }
    return Success(null);
  }

  Future<Result<Null, Null>> deleteEntries(
    final Iterable<int> ids,
  ) async {
    await (appDb.delete(appDb.entries)..where((t) => t.id.isIn(ids))).go();
    return Success(null);
  }

  Future<Result<Getter<List<db.EntryField>>, Null>> createEntriesFields(
    final db.Entry entry,
    final Iterable<({db.Field field, Uint8List value})> entriesFieldsForInsert,
  ) async {
    final maxId = await (appDb.select(appDb.entriesFields)
          ..orderBy([(t) => drift.OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull()
        .then((ef) => ef?.id ?? 0);

    final lastEf = await (appDb.select(appDb.entriesFields)
          ..where((entriesFields) => entriesFields.entryId.equals(entry.id)))
        .getSingleOrNull();

    final relationedEfs = entriesFieldsForInsert.toList().asMap().entries.map(
      (e) {
        final ef = e.value;
        final id = maxId + e.key + 1;
        return db.EntriesFieldsCompanion.insert(
          id: drift.Value(id),
          entryId: entry.id,
          fieldId: ef.field.id,
          value: ef.value,
          nextField: drift.Value(id + 1),
        );
      },
    ).toList();

    relationedEfs.last = relationedEfs.last.copyWith(
      nextField: drift.Value.absent(),
    );

    await appDb.batch((batch) {
      batch.insertAll(
        appDb.entriesFields,
        relationedEfs.map((ef) => ef.copyWith(
              nextField: drift.Value(null),
            )),
      );
      batch.replaceAll(
        appDb.entriesFields,
        [
          if (lastEf != null)
            lastEf.copyWith(nextField: relationedEfs.first.id),
          ...relationedEfs,
        ],
      );
    });

    return Success((
      get: () async => await readEntriesFieldsByEntry(entry).then((efs) =>
          efs.sublist(efs.length - entriesFieldsForInsert.length, efs.length))
    ));
  }

  Future<List<db.EntryField>> readEntriesFieldsByEntry(
    final db.Entry entry,
  ) async {
    final efs = await (appDb.select(appDb.entriesFields)
          ..where((entriesFields) => entriesFields.entryId.equals(entry.id)))
        .get();
    final nextIdToEf = Map.fromIterables(
      efs.map((ef) => ef.nextField),
      efs.map((ef) => ef),
    );

    // 順番通りにソート
    return (() async* {
      db.EntryField? ef = efs.where((ef) => ef.nextField == null).firstOrNull;
      while (ef != null) {
        yield ef;
        ef = nextIdToEf[ef.id];
      }
    })()
        .toList()
        .then((l) => l.reversed.toList());
  }

  Future<Result<Null, Null>> updateEntriesFields(
    final Iterable<db.EntryField> entriesFields,
  ) async {
    await appDb.batch((batch) {
      batch.replaceAll(
        appDb.entriesFields,
        entriesFields,
      );
    });
    return Success(null);
  }

  Future<Result<Null, Null>> deleteEntriesFields(
    final Iterable<int> ids,
  ) async {
    final efs = await (appDb.select(appDb.entriesFields)
          ..where((t) => t.nextField.isIn(ids) | t.id.isIn(ids)))
        .get();
    final idToEf = Map.fromIterables(efs.map((ef) => ef.id), efs);
    final idToNeighbors = Map.fromIterables(
      ids.map((id) => id),
      ids.map<({int? next, int? prev})>((_) => (next: null, prev: null)),
    );

    final idSet = ids.toSet();

    for (final ef in efs) {
      final next = ef.nextField;
      if (idSet.contains(next)) {
        idToNeighbors[next!] =
            (prev: ef.id, next: idToNeighbors[ef.nextField]?.next);
      }
    }

    await appDb.batch((batch) {
      batch.replaceAll(
        appDb.entriesFields,
        efs.map(
          (ef) => ef.copyWith(
            nextField: drift.Value(null),
          ),
        ),
      );
      batch.deleteWhere(
        appDb.entriesFields,
        (t) => t.id.isIn(ids),
      );
      batch.replaceAll(
        appDb.entriesFields,
        efs.map(
          (ef) {
            final int? nextField;
            if (idSet.contains(ef.nextField)) {
              nextField = idToEf[ef.nextField]!.nextField;
            } else {
              nextField = ef.nextField;
            }
            return ef.copyWith(
              nextField: drift.Value(nextField),
            );
          },
        ),
      );
    });

    return Success(null);
  }

  Future<Result<Getter<List<db.Field>>, Getter<List<String>>>> createFields(
    final Iterable<({String name, bool isSecret, db.FieldType type})>
        fieldsForInsert,
  ) async {
    final succeeded = await appDb
        .batch((batch) {
          batch.insertAll(
            appDb.fields,
            fieldsForInsert.map(
              (field) => db.FieldsCompanion.insert(
                name: field.name,
                isSecret: field.isSecret,
                type: field.type,
              ),
            ),
          );
        })
        .then((_) => true)
        .catchError(
          (_) => false,
          test: (e) => e is SqliteException,
        );

    if (!succeeded) {
      return Failure((
        get: () async =>
            await readFieldsByNames(fieldsForInsert.map((field) => field.name))
                .then((fields) => fields.map((field) => field.name).toList())
      ));
    }

    return Success((
      get: () async =>
          await readFieldsByNames(fieldsForInsert.map((field) => field.name))
    ));
  }

  Future<List<db.Field>> readFieldsByNames(
    final Iterable<String> names,
  ) async {
    return await (appDb.select(appDb.fields)
          ..where((fields) => fields.name.isIn(names)))
        .get();
  }

  Future<db.Field?> readFieldByName(
    final String name,
  ) async {
    return await (appDb.select(appDb.fields)
          ..where((fields) => fields.name.equals(name)))
        .getSingleOrNull();
  }

  Future<Result<Null, Getter<List<db.Field>>>> updateFields(
    final Iterable<db.Field> fields,
  ) async {
    final fieldIds = fields.map((field) => field.id);
    final usingEfs = await (appDb.select(appDb.entriesFields)
          ..where((t) => t.fieldId.isIn(fieldIds)))
        .get();

    if (usingEfs.isNotEmpty) {
      final usedFieldIds = usingEfs.map((ef) => ef.fieldId).toSet();
      final idToExistingFields = Map.fromEntries(
        await (appDb.select(appDb.fields)
              ..where((t) => t.id.isIn(usedFieldIds)))
            .get()
            .then((r) => r.map((field) => MapEntry(field.id, field))),
      );
      final invalidFields = fields.where((field) {
        final existingField = idToExistingFields[field.id];
        return db.Fields.isModifiedUnmodifiableValue(field, existingField!);
      });
      if (invalidFields.isNotEmpty) {
        return Failure((
          get: () =>
              fields.where((field) => usedFieldIds.contains(field.id)).toList()
        ));
      }
    }

    final succeeded = await appDb
        .batch((batch) {
          batch.replaceAll(appDb.fields, fields);
        })
        .then((_) => true)
        .catchError(
          (_) => false,
          test: (e) => e is SqliteException,
        );
    if (!succeeded) {
      return Failure((
        get: () async {
          final fieldNames = fields.map((field) => field.name);
          final existingFieldNameSet = await (appDb.select(appDb.fields)
                ..where((t) => t.name.isIn(fieldNames)))
              .get()
              .then((r) => r.map((field) => field.name).toSet());
          return fields
              .where((field) => existingFieldNameSet.contains(field.name))
              .toList();
        }
      ));
    }
    return Success(null);
  }

  Future<Result<Null, Getter<List<int>>>> deleteFields(
    final Iterable<int> ids,
  ) async {
    final succeeded = await (appDb.delete(appDb.fields)
          ..where((fields) => fields.id.isIn(ids)))
        .go()
        .then((_) => true)
        .catchError(
          (_) => false,
          test: (e) => e is SqliteException,
        );
    if (!succeeded) {
      return Failure((
        get: () async => await (appDb.select(appDb.entriesFields)
              ..where((t) => t.fieldId.isIn(ids)))
            .get()
            .then((efs) => efs.map((ef) => ef.fieldId).toSet().toList())
      ));
    }

    return Success(null);
  }
}
