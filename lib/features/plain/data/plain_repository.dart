import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/plain_models.dart';
import '../services/plain_analyzer.dart';

class PlainRepository {
  PlainRepository({Database? testDb}) : _db = testDb;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'plain_please.db'),
      version: 1,
      onCreate: createSchema,
    );
    return _db!;
  }

  static Future<void> createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE documentos (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        raw_text TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE bloques (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        index_order INTEGER NOT NULL,
        original_text TEXT NOT NULL,
        detected_terms TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE explicaciones (
        id TEXT PRIMARY KEY,
        block_id TEXT NOT NULL,
        plain_text TEXT NOT NULL,
        key_points TEXT NOT NULL DEFAULT '',
        is_ai_draft INTEGER NOT NULL DEFAULT 0,
        is_verified INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE glosario (
        id TEXT PRIMARY KEY,
        term TEXT NOT NULL,
        plain_definition TEXT NOT NULL
      )
    ''');
    for (final g in PlainAnalyzer.starterGlossary) {
      await db.insert('glosario', g.toMap());
    }
  }

  Future<List<Documento>> listDocuments() async {
    final db = await database;
    final rows = await db.query('documentos', orderBy: 'created_at DESC');
    return rows.map(Documento.fromMap).toList();
  }

  Future<List<Bloque>> listBlocks() async {
    final db = await database;
    final rows = await db.query('bloques', orderBy: 'index_order ASC');
    return rows.map(Bloque.fromMap).toList();
  }

  Future<List<Explicacion>> listExplanations() async {
    final db = await database;
    final rows = await db.query('explicaciones');
    return rows.map(Explicacion.fromMap).toList();
  }

  Future<List<Glosario>> listGlossary() async {
    final db = await database;
    final rows = await db.query('glosario', orderBy: 'term ASC');
    return rows.map(Glosario.fromMap).toList();
  }

  Future<void> saveDocumentBundle({
    required Documento doc,
    required List<Bloque> blocks,
    required List<Explicacion> explanations,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('documentos', doc.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      for (final b in blocks) {
        await txn.insert('bloques', b.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final e in explanations) {
        await txn.insert('explicaciones', e.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> upsertExplanation(Explicacion exp) async {
    final db = await database;
    await db.insert('explicaciones', exp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> upsertGlossary(Glosario term) async {
    final db = await database;
    await db.insert('glosario', term.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

