import 'package:setore/drift.dart' as drift;

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

  void createFields(
      final List<({String name, bool isSecret, drift.FieldType type})>
          fields) async {
    await appDb.batch((batch) {
      batch.insertAll(
          appDb.fields,
          fields.map((field) => drift.FieldsCompanion.insert(
                name: field.name,
                isSecret: field.isSecret,
                type: field.type,
              )));
    });
  }
}
