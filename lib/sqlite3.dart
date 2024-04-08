import 'dart:ffi';

import 'package:drift/drift.dart' show LazyDatabase;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:sqlite3/sqlite3.dart' show sqlite3;
import 'package:sqlite3/open.dart' as sqlite3_open;

LazyDatabase createLazyDb(final String path,
    {final String? dllPathForWindows, final String? passphrase}) {
  return LazyDatabase(() async {
    if (dllPathForWindows != null) {
      sqlite3_open.open.overrideFor(
        sqlite3_open.OperatingSystem.windows,
        () => DynamicLibrary.open(dllPathForWindows),
      );
    }

    final rawDb = sqlite3.open(path);
    if (passphrase != null) {
      assert(rawDb.select('PRAGMA cipher_version;').isNotEmpty);
      rawDb.execute("PRAGMA key = '$passphrase';");
    }
    rawDb.execute('PRAGMA foreign_keys = ON;');
    return NativeDatabase.opened(rawDb);
  });
}
