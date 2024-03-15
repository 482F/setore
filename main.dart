import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dart:ffi';

import 'package:path/path.dart';
import 'package:sqlite3/open.dart';

import './lib/database.dart' as db;

void main() async {
  open.overrideFor(OperatingSystem.windows, _openOnWindows);
  print(db.TodoItems);

  final database = db.AppDatabase(LazyDatabase(() async {
    return NativeDatabase.opened(sqlite3.openInMemory());
  }));

  await database.into(database.todoItems).insert(db.TodoItemsCompanion.insert(
        title: 'todo: finish drift setup',
        content: 'We can now write queries and define our own tables.',
      ));
  List<db.TodoItem> allItems = await database.select(database.todoItems).get();

  print('items in database: $allItems');
  print(allItems.first.title);
}

DynamicLibrary _openOnWindows() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final libraryNextToScript = File(join(scriptDir.path, 'sqlite3.dll'));
  return DynamicLibrary.open(libraryNextToScript.path);
}
