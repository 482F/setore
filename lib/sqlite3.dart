import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

LazyDatabase createLazyDb(final String path, {final String? passphrase}) {
  return LazyDatabase(() async {
    final rawDb = sqlite3.open(path);
    if (passphrase != null) {
      assert(rawDb.select('PRAGMA cipher_version;').isNotEmpty);
      rawDb.execute("PRAGMA key = '$passphrase';");
    }
    return NativeDatabase.opened(rawDb);
  });
}
