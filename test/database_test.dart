import 'dart:io';

import 'package:setore/database.dart' as db;
import 'package:path/path.dart' as path;
import 'package:test/test.dart' as test;

void main() {
  // test('equals sample', () {
  //   int actual = 5;
  //   int expected = 5;
  //   expect(actual, equals(expected));
  // });

  // test('contains sample', () {
  //   List<int> numbers = [1, 2, 3, 4, 5];
  //   int value = 3;
  //   expect(numbers, contains(value));
  // });

  // test('isEmpty sample', () {
  //   List<int> emptyList = [];
  //   expect(emptyList, isEmpty);
  // });

  final scriptDir = File(Platform.script.toFilePath()).parent;
  final database = db.AppDatabase(
    path.absolute('s.sq3'),
    dllPathForWindows: path.join(scriptDir.path, 'sqlcipher.dll'),
    passphrase: 'asdf',
  );
  test.test('insert', () async {
    await database
        .into(database.entries)
        .insert(db.EntriesCompanion.insert(name: 'sample entry'));
    // await database.into(database.fields).insert(TodoItemsCompanion.insert(
    //       title: 'todo: finish drift setup',
    //       content: 'We can now write queries and define our own tables.',
    //     ));
    // List<TodoItem> allItems = await database.select(database.todoItems).get();

    // print('items in database: $allItems');
    // print(allItems.first.title);
  });
}
