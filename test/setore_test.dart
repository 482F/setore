import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:setore/drift.dart' as db;
import 'package:setore/result.dart' show Failure;
import 'package:setore/setore.dart';
import 'package:test/test.dart' as test;

void main() {
  final setore = Setore('./s.sq3');
  test.tearDownAll(() async {
    await setore.appDb.close();
    await File('./s.sq3').delete();
  });

  test.test('create entries', () async {
    test.expect(
      await setore.createEntries([
        (name: 'create-entries-1'),
        (name: 'create-entries-2'),
      ]).then((r) => r.unwrap().get()),
      test.isA<List<db.Entry>>(),
    );

    // 名前が被る場合はエラー
    test.expect(
      await setore.createEntries([
        (name: 'create-entries-1'),
        (name: 'create-entries-3'),
      ]).then(
        (r) => switch (r) {
          Failure(exception: final e) => e.get(),
          _ => throw r,
        },
      ),
      test.equals(['create-entries-1']),
    );

    // 被らなかったエントリも登録はされない
    test.expect(
      await setore.readEntryByName('create-entries-3'),
      test.isNull,
    );
  });

  test.test('read entries', () async {
    await setore.createEntries([
      (name: 'read-entries-1'),
      (name: 'read-entries-2'),
    ]).then((r) => r.unwrap());
    test.expect(
      await setore.readEntries().then((entries) => entries.length),
      test.greaterThanOrEqualTo(2),
    );
  });

  test.test('read entries by names', () async {
    await setore.createEntries([
      (name: 'read-entries-by-names-1'),
      (name: 'read-entries-by-names-2'),
    ]).then((r) => r.unwrap());
    test.expect(
      await setore.readEntriesByNames([
        'read-entries-by-names-1',
        'read-entries-by-names-2',
        'read-entries-by-names-2',
        'read-entries-by-names-3',
      ]),
      test.hasLength(2),
    );
  });

  test.test('read entry by name', () async {
    await setore.createEntries([
      (name: 'read-entry-by-name-1'),
    ]).then((r) => r.unwrap());
    test.expect(
      await setore.readEntryByName('read-entry-by-name-1'),
      test.isA<db.Entry>(),
    );
    test.expect(
      await setore.readEntryByName('read-entry-by-name-2'),
      test.isNull,
    );
  });

  test.test('read entries by part names', () async {
    await setore.createEntries([
      (name: 'read-entries-by-part-names-qwe-1'),
      (name: 'read-entries-by-part-names-rty-2'),
    ]).then((r) => r.unwrap());
    test.expect(
      await setore.readEntriesByPartNames(['qwe', 'rty']).then(
          (entries) => entries.length),
      test.greaterThanOrEqualTo(2),
    );
  });

  test.test('update entries', () async {
    final newField = await setore
        .createEntries([
          (name: 'update-entries-1'),
          (name: 'update-entries-2'),
        ])
        .then((r) => r.unwrap().get())
        .then((r) => r
            .firstWhere((field) => field.name.endsWith('1'))
            .copyWith(name: 'update-entries-11'));

    test.expect(
      await setore.updateEntries([
        newField,
      ]).then((r) => r.unwrap()),
      test.isNull,
    );

    // 名前が被る場合は更新できない
    test.expect(
      await setore
          .updateEntries([
            newField.copyWith(name: 'update-entries-2'),
          ])
          .then(
            (r) => switch (r) {
              Failure(exception: final e) => e.get(),
              _ => throw r,
            },
          )
          .then((entries) => entries.single.name),
      test.equals('update-entries-2'),
    );

    // 更新される値が無い場合はエラーにならない
    test.expect(
      await setore.updateEntries([
        newField,
      ]).then((r) => r.unwrap()),
      test.isNull,
    );
  });

  test.test('delete entries', () async {
    final entry = await setore
        .createEntries([
          (name: 'delete-entries-1'),
        ])
        .then((r) => r.unwrap().get())
        .then((r) => r.first);

    final field = await setore
        .createFields(
          [
            (name: 'delete-entries-1', isSecret: false, type: db.FieldType.text)
          ],
        )
        .then((r) => r.unwrap().get())
        .then((r) => r.first);
    test.expect(field, test.isNotNull);

    await setore.createEntriesFields(
      entry,
      [
        (
          field: field,
          value: await db.FieldType.text.encode('a'),
        )
      ],
    ).then((r) => r.unwrap());

    test.expect(
      await setore.deleteEntries([entry.id]).then((r) => r.unwrap()),
      test.isNull,
    );

    // 紐付く entriesFields は削除される
    test.expect(
      await setore.readEntriesFieldsByEntry(entry),
      test.isEmpty,
    );
  });

  test.test('create entriesFields', () async {
    final entry = await setore
        .createEntries([
          (name: 'create-entriesFields-1'),
        ])
        .then((r) => r.unwrap().get())
        .then((r) => r.first);
    final field = await setore
        .createFields([
          (
            name: 'create-entriesFields-1',
            isSecret: false,
            type: db.FieldType.text,
          ),
        ])
        .then((r) => r.unwrap().get())
        .then((r) => r.first);

    await setore.createEntriesFields(
      entry,
      [
        (
          field: field,
          value: await db.FieldType.text.encode('a'),
        ),
      ],
    ).then((r) => r.unwrap());
    Future<List<db.EntryField>> getEntriesFields() =>
        setore.readEntriesFieldsByEntry(entry);

    var entriesFields = await getEntriesFields();

    // 一件目の entriesFields の nextField は Null
    test.expect(
      entriesFields.last.nextField,
      test.isNull,
    );

    await setore.createEntriesFields(
      entry,
      [
        (field: field, value: await db.FieldType.text.encode('b')),
        (field: field, value: await db.FieldType.text.encode('c')),
      ],
    ).then((r) => r.unwrap());

    entriesFields = await getEntriesFields();

    // entriesFields が登録されると、その前の entriesFields に自動で値が入る
    test.expect(
      entriesFields.first.nextField,
      test.same(entriesFields[1].id),
    );
    test.expect(
      entriesFields[1].nextField,
      test.same(entriesFields.last.id),
    );
    test.expect(
      entriesFields.last.nextField,
      test.isNull,
    );
  });

  test.test('read entriesfields by entry', () async {
    final entry = await setore
        .createEntries([
          (name: 'read-entriesFields-by-entry-1'),
        ])
        .then((r) => r.unwrap().get())
        .then((r) => r.first);
    final field = await setore
        .createFields([
          (
            name: 'read-entriesFields-by-entry-1',
            isSecret: false,
            type: db.FieldType.text,
          ),
        ])
        .then((r) => r.unwrap().get())
        .then((r) => r.first);

    await setore.createEntriesFields(
      entry,
      [
        (field: field, value: await db.FieldType.text.encode('a')),
      ],
    ).then((r) => r.unwrap());
    final entryField =
        await setore.readEntriesFieldsByEntry(entry).then((e) => e.first);
    test.expect(
      db.FieldType.text.decode(entryField.value),
      test.equals('a'),
    );
  });

  test.test('update entriesFields', () async {
    final entry = await setore
        .createEntries([
          (name: 'update-entriesFields-1'),
        ])
        .then((r) => r.unwrap().get())
        .then((r) => r.first);
    final field = await setore
        .createFields([
          (
            name: 'update-entriesFields-1',
            isSecret: false,
            type: db.FieldType.text,
          ),
        ])
        .then((r) => r.unwrap().get())
        .then((r) => r.first);

    final entriesFields = await setore.createEntriesFields(
      entry,
      [
        (field: field, value: await db.FieldType.text.encode('a')),
        (field: field, value: await db.FieldType.text.encode('b')),
      ],
    ).then((r) => r.unwrap().get());

    test.expect(
      await setore.updateEntriesFields([
        entriesFields.first
            .copyWith(value: await db.FieldType.text.encode('c')),
      ]).then((r) => r.unwrap()),
      test.isNull,
    );

    final updatedEntryField =
        await setore.readEntriesFieldsByEntry(entry).then((e) => e.first);

    test.expect(
      db.FieldType.text.decode(updatedEntryField.value),
      test.equals('c'),
    );

    // nextField の更新を行うと readEntriesFieldsByEntries の返り値の順序が更新される
    await setore.updateEntriesFields([
      entriesFields.last.copyWith(
        nextField: drift.Value(entriesFields.first.id),
      ),
      entriesFields.first.copyWith(
        nextField: drift.Value(null),
      ),
    ]);

    final orderedEntriesFields = await setore.readEntriesFieldsByEntry(entry);
    test.expect(
      db.FieldType.text.decode(orderedEntriesFields.first.value),
      test.equals('b'),
    );
    test.expect(
      db.FieldType.text.decode(orderedEntriesFields.last.value),
      test.equals('a'),
    );
  });

  test.test('delete entriesFields', () async {
    final entry = await setore
        .createEntries([
          (name: 'delete-entriesFields-1'),
        ])
        .then((r) => r.unwrap().get())
        .then((r) => r.first);
    final field = await setore
        .createFields([
          (
            name: 'delete-entriesFields-1',
            isSecret: false,
            type: db.FieldType.text,
          ),
        ])
        .then((r) => r.unwrap().get())
        .then((r) => r.first);

    final entriesFields = await setore.createEntriesFields(
      entry,
      [
        (field: field, value: await db.FieldType.text.encode('a')),
        (field: field, value: await db.FieldType.text.encode('b')),
        (field: field, value: await db.FieldType.text.encode('c')),
      ],
    ).then((r) => r.unwrap().get());

    await setore.deleteEntriesFields([entriesFields[1].id]);

    // 削除すると前後の参照が更新される
    final deletedEntriesFields = await setore.readEntriesFieldsByEntry(entry);
    test.expect(
      deletedEntriesFields.first.nextField,
      test.same(deletedEntriesFields.last.id),
    );
    test.expect(
      deletedEntriesFields.last.nextField,
      test.same(null),
    );
  });

  test.test('create fields', () async {
    test.expect(
      await setore.createFields([
        (name: 'create-fields-1', isSecret: true, type: db.FieldType.text),
        (name: 'create-fields-2', isSecret: true, type: db.FieldType.text),
      ]).then((r) => r.unwrap().get()),
      test.isA<List<db.Field>>(),
    );

    // 名前が被る場合はエラー
    test.expect(
      await setore.createFields([
        (name: 'create-fields-1', isSecret: true, type: db.FieldType.text),
        (name: 'create-fields-3', isSecret: true, type: db.FieldType.text),
      ]).then(
        (r) => switch (r) {
          Failure(exception: final e) => e.get(),
          _ => throw r,
        },
      ),
      test.equals(['create-fields-1']),
    );

    // 被らなかったエントリも登録はされない
    test.expect(
      await setore.readFieldByName('create-fields-3'),
      test.isNull,
    );
  });

  test.test('read fields', () async {
    await setore.createFields([
      (name: 'read-fields-1', isSecret: true, type: db.FieldType.text),
      (name: 'read-fields-2', isSecret: true, type: db.FieldType.text),
    ]).then((r) => r.unwrap());
    test.expect(
      await setore.readFieldsByNames([
        'read-fields-1',
        'read-fields-2',
        'read-fields-2',
        'read-fields-3',
      ]),
      test.hasLength(2),
    );
  });

  test.test('read field', () async {
    await setore.createFields([
      (name: 'read-field-1', isSecret: true, type: db.FieldType.text),
    ]).then((r) => r.unwrap());
    test.expect(
      await setore.readFieldByName('read-field-1'),
      test.isA<db.Field>(),
    );
    test.expect(
      await setore.readFieldByName('read-field-2'),
      test.isNull,
    );
  });

  test.test('update fields', () async {
    final newFields = await setore
        .createFields([
          (name: 'update-fields-1', isSecret: true, type: db.FieldType.text),
          (name: 'update-fields-2', isSecret: true, type: db.FieldType.text),
          (name: 'update-fields-3', isSecret: true, type: db.FieldType.text),
        ])
        .then((r) => r.unwrap().get())
        .then((r) => r.map((field) => field.copyWith(name: '${field.name}0')));

    test.expect(
      await setore.updateFields(newFields).then((r) => r.unwrap()),
      test.isNull,
    );

    // 名前が被る場合は更新できない
    test.expect(
      await setore
          .updateFields([newFields.first.copyWith(name: 'update-fields-30')])
          .then((r) => switch (r) {
                Failure(exception: final e) => e.get(),
                _ => throw r,
              })
          .then((fields) => fields.single.name),
      test.equals('update-fields-30'),
    );

    final entry = await setore
        .createEntries(
          [(name: 'update-fields-1')],
        )
        .then((r) => r.unwrap().get())
        .then((r) => r.first);
    test.expect(entry, test.isNotNull);

    await setore
        .createEntriesFields(
          entry,
          await newFields
              .map((field) async => (
                    field: field,
                    value: await db.FieldType.text.encode('a'),
                  ))
              .wait,
        )
        .then((r) => r.unwrap());

    // fields が使われている場合は type を更新できない
    test.expect(
      await setore
          .updateFields(
            newFields.map((field) => field.copyWith(type: db.FieldType.memo)),
          )
          .then((r) => switch (r) {
                Failure(exception: final e) => e.get(),
                _ => throw r,
              }),
      test.isA<List<db.Field>>(),
    );

    // fields が使われていても name や isSecret であれば更新できる
    test.expect(
      await setore
          .updateFields(
            newFields.map((field) => field.copyWith(
                  name: '${field.name}0',
                  isSecret: false,
                )),
          )
          .then((r) => r.unwrap()),
      test.isNull,
    );
  });

  test.test('delete fields', () async {
    var fields = await setore.createFields([
      (name: 'delete-fields-1', isSecret: true, type: db.FieldType.text),
      (name: 'delete-fields-2', isSecret: true, type: db.FieldType.text),
      (name: 'delete-fields-3', isSecret: true, type: db.FieldType.text),
    ]).then((r) => r.unwrap().get());

    test.expect(
      await setore
          .deleteFields(fields.map((field) => field.id))
          .then((r) => r.unwrap()),
      test.isNull,
    );
    test.expect(
      await setore.readFieldsByNames([
        'delete-fields-1',
        'delete-fields-2',
        'delete-fields-3',
      ]),
      test.isEmpty,
    );

    // fields が使われている場合は削除できない
    fields = await setore.createFields([
      (name: 'delete-fields-4', isSecret: true, type: db.FieldType.text),
      (name: 'delete-fields-5', isSecret: true, type: db.FieldType.text),
      (name: 'delete-fields-6', isSecret: true, type: db.FieldType.text),
    ]).then((r) => r.unwrap().get());

    await setore
        .createEntries([(name: 'delete-fields-1')]).then((r) => r.unwrap());
    final entry =
        await setore.readEntryByName('delete-fields-1').then((e) => e!);
    test.expect(entry, test.isNotNull);

    await setore
        .createEntriesFields(
          entry,
          await fields
              .map((field) async => (
                    field: field,
                    value: await db.FieldType.text.encode('a'),
                  ))
              .wait,
        )
        .then((r) => r.unwrap());

    test.expect(
      await setore
          .deleteFields(fields.map((field) => field.id))
          .then((r) => switch (r) {
                Failure(exception: final e) => e.get(),
                _ => throw r,
              }),
      test.isA<List<int>>(),
    );
  });
}
