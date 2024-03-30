import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:setore/drift.dart' as db;
import 'package:setore/setore.dart';
import 'package:test/test.dart' as test;

void main() {
  final setore = Setore('./s.sq3');
  test.tearDownAll(() async {
    await File('./s.sq3').delete();
  });

  test.test('create entries', () async {
    test.expect(
      await setore.createEntries([
        (name: 'create-entries-1'),
        (name: 'create-entries-2'),
      ]).then((r) => r.unwrap().get()),
      test.isA<List<int>>(),
    );
    test.expect(
      () async => await setore.createEntries([
        (name: 'create-entries-1'),
      ]).then((r) => r.unwrap()),
      test.throwsException,
    );
  });

  test.test('read entries', () async {
    await setore.createEntries([
      (name: 'create-entries-1'),
      (name: 'create-entries-2'),
    ]).then((r) => r.unwrap());
    test.expect(
      await setore.readEntriesByNames([
        'create-entries-1',
        'create-entries-2',
        'create-entries-2',
        'create-entries-3',
      ]),
      test.hasLength(2),
    );
  });

  test.test('read entry', () async {
    await setore.createEntries([
      (name: 'create-entries-1'),
    ]).then((r) => r.unwrap());
    test.expect(
      await setore.readEntryByName('create-entries-1'),
      test.isA<db.Entry>(),
    );
    test.expect(
      await setore.readEntryByName('create-entries-2'),
      test.isNull,
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
      () async => await setore.updateEntries([
        newField.copyWith(name: 'update-entries-2'),
      ]).then((r) => r.unwrap()),
      test.throwsException,
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
          value: await field.type.encode('a'),
        )
      ],
    ).then((r) => r.unwrap());

    test.expect(
      await setore.deleteEntries([entry.id]),
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
          value: await field.type.encode('a'),
        ),
      ],
    ).then((r) => r.unwrap());
    Future<List<db.EntryField>> getEntriesFields() =>
        setore.readEntriesFieldsByEntry(entry);

    var entriesFields = await getEntriesFields();

    // 一件目の entriesFields の prevFields, nextFields はいずれも Null
    test.expect(
      entriesFields.last.prevField,
      test.isNull,
    );
    test.expect(
      entriesFields.last.nextField,
      test.isNull,
    );

    await setore.createEntriesFields(
      entry,
      [
        (field: field, value: await field.type.encode('b')),
        (field: field, value: await field.type.encode('c')),
      ],
    ).then((r) => r.unwrap());

    entriesFields = await getEntriesFields();

    // entriesFields が登録されると、その前の entriesFields に自動で値が入る
    test.expect(
      entriesFields.first.prevField,
      test.isNull,
    );
    test.expect(
      entriesFields.first.nextField,
      test.same(entriesFields[1].id),
    );
    test.expect(
      entriesFields[1].prevField,
      test.same(entriesFields.first.id),
    );
    test.expect(
      entriesFields[1].nextField,
      test.same(entriesFields.last.id),
    );
    test.expect(
      entriesFields.last.prevField,
      test.same(entriesFields[1].id),
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
        (field: field, value: await field.type.encode('a')),
      ],
    ).then((r) => r.unwrap());
    final entryField =
        await setore.readEntriesFieldsByEntry(entry).then((e) => e.first);
    test.expect(
      field.type.decode(entryField.value),
      test.same('a'),
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
        (field: field, value: await field.type.encode('a')),
        (field: field, value: await field.type.encode('b')),
      ],
    ).then((r) => r.unwrap().get());

    await Future<void>.delayed(const Duration(seconds: 2));

    test.expect(
      await setore.updateEntriesFields([
        entriesFields.first.copyWith(value: await field.type.encode('c')),
      ]),
      test.isNull,
    );

    final updatedEntryField =
        await setore.readEntriesFieldsByEntry(entry).then((e) => e.first);

    test.expect(
      field.type.decode(updatedEntryField.value),
      test.same('c'),
    );

    // 更新日が更新される
    test.expect(
      updatedEntryField.updatedAt.toString(),
      test.isNot(test.equals(entriesFields.first.updatedAt.toString())),
    );

    // prevFields, nextFields の更新を行うと readEntriesFieldsByEntries の返り値の順序が更新される
    await setore.updateEntriesFields([
      entriesFields.last.copyWith(
        prevField: const drift.Value.absent(),
        nextField: drift.Value(entriesFields.first.id),
      ),
      entriesFields.first.copyWith(
        prevField: drift.Value(entriesFields.last.id),
        nextField: const drift.Value.absent(),
      ),
    ]);

    final orderedEntriesFields = await setore.readEntriesFieldsByEntry(entry);
    test.expect(
      field.type.decode(orderedEntriesFields.first.value),
      test.same('b'),
    );
    test.expect(
      field.type.decode(orderedEntriesFields.last.value),
      test.same('c'),
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
        (field: field, value: await field.type.encode('a')),
        (field: field, value: await field.type.encode('b')),
        (field: field, value: await field.type.encode('c')),
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
      deletedEntriesFields.last.prevField,
      test.same(deletedEntriesFields.first.id),
    );
  });

  test.test('create fields', () async {
    test.expect(
      await setore.createFields([
        (name: 'create-fields-1', isSecret: true, type: db.FieldType.date),
        (name: 'create-fields-2', isSecret: true, type: db.FieldType.date),
      ]).then((r) => r.unwrap()),
      test.isA<List<int>>(),
    );
    test.expect(
      () async => await setore.createFields([
        (name: 'create-fields-1', isSecret: true, type: db.FieldType.date),
      ]).then((r) => r.unwrap()),
      test.throwsException,
    );
  });

  test.test('read fields', () async {
    await setore.createFields([
      (name: 'read-fields-1', isSecret: true, type: db.FieldType.date),
      (name: 'read-fields-2', isSecret: true, type: db.FieldType.date),
      (name: 'read-fields-3', isSecret: true, type: db.FieldType.date),
    ]).then((r) => r.unwrap());
    test.expect(
      await setore.readFieldsByNames([
        'read-fields-1',
        'read-fields-2',
        'read-fields-3',
        'read-fields-3',
        'read-fields-4',
      ]),
      test.hasLength(3),
    );
  });

  test.test('read field', () async {
    await setore.createFields([
      (name: 'read-field-1', isSecret: true, type: db.FieldType.date),
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
      () async => await setore.updateFields([
        newFields.first.copyWith(name: 'update-fields-3')
      ]).then((r) => r.unwrap()),
      test.throwsException,
    );

    // fields が使われている場合は更新できない
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
                    value: await field.type.encode('a'),
                  ))
              .wait,
        )
        .then((r) => r.unwrap());

    test.expect(
      () async => await setore
          .updateFields(
            newFields.map((field) => field.copyWith(name: '${field.name}0')),
          )
          .then((r) => r.unwrap()),
      test.throwsException,
    );

    // 更新される値が無い場合はエラーにならない
    test.expect(
      await setore.updateFields(newFields).then((r) => r.unwrap()),
      test.isNull,
    );
  });

  test.test('delete fields', () async {
    var fields = await setore.createFields([
      (name: 'delete-fields-1', isSecret: true, type: db.FieldType.date),
      (name: 'delete-fields-2', isSecret: true, type: db.FieldType.date),
      (name: 'delete-fields-3', isSecret: true, type: db.FieldType.date),
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
                    value: await field.type.encode('a'),
                  ))
              .wait,
        )
        .then((r) => r.unwrap());

    test.expect(
      () async => await setore
          .deleteFields(fields.map((field) => field.id))
          .then((r) => r.unwrap()),
      test.throwsException,
    );
  });
}
