import 'dart:async' as async;
import 'package:archive/archive.dart' as archive;

import 'package:drift/drift.dart';
import 'package:setore/sqlite3.dart' as sqlite3;

part 'drift.g.dart';

@DataClassName('Entry')
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

enum FieldType<T extends Object> {
  text<String>(encode: encodeString, decode: decodeString),
  memo<String>(encode: encodeString, decode: decodeString),
  date<DateTime>(encode: encodeDate, decode: decodeDate),
  files<Iterable<archive.ArchiveFile>>(
      encode: encodeFiles, decode: decodeFiles),
  totpToken<String>(encode: encodeString, decode: decodeString);

  const FieldType({
    required this.encode,
    required this.decode,
  });

  final async.FutureOr<Uint8List> Function(T?) encode;
  final async.FutureOr<T?> Function(Uint8List) decode;

  static Uint8List encodeString(String? s) =>
      Uint8List.fromList((s ?? '').codeUnits);
  static String decodeString(Uint8List u) => String.fromCharCodes(u);

  static Uint8List encodeDate(DateTime? d) =>
      encodeString(d?.toUtc().toIso8601String() ?? '');
  static DateTime? decodeDate(Uint8List u) {
    final dateString = decodeString(u);
    if (dateString.isEmpty) {
      return null;
    }
    return DateTime.parse(dateString).toLocal();
  }

  static Future<Uint8List> encodeFiles(
      Iterable<archive.ArchiveFile>? fs) async {
    final a = archive.Archive();
    await (fs ?? []).map((f) async {
      a.addFile(f);
    }).wait;
    return Uint8List.fromList(archive.TarEncoder().encode(a));
  }

  static List<archive.ArchiveFile> decodeFiles(Uint8List u) {
    return archive.TarDecoder().decodeBytes(u).files;
  }
}

class Fields extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  BoolColumn get isSecret => boolean()();
  IntColumn get type => intEnum<FieldType<Object>>()();
}

@DataClassName('EntryField')
class EntriesFields extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get entryId =>
      integer().references(Entries, #id, onDelete: KeyAction.cascade)();
  IntColumn get fieldId =>
      integer().references(Fields, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get prevField => integer()
      .nullable()
      .references(EntriesFields, #id, onDelete: KeyAction.restrict)();
  IntColumn get nextField => integer()
      .nullable()
      .references(EntriesFields, #id, onDelete: KeyAction.restrict)();
  BlobColumn get value => blob()();
}

@DriftDatabase(tables: [
  Entries,
  Fields,
  EntriesFields,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(
    final String path, {
    final String? dllPathForWindows,
    final String? passphrase,
  }) : super(sqlite3.createLazyDb(
          path,
          dllPathForWindows: dllPathForWindows,
          passphrase: passphrase,
        ));

  @override
  int get schemaVersion => 1;
}
