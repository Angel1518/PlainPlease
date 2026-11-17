import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plain_please/core/theme/app_theme.dart';
import 'package:plain_please/features/plain/controllers/plain_controller.dart';
import 'package:plain_please/features/plain/data/plain_repository.dart';
import 'package:plain_please/features/plain/models/plain_models.dart';
import 'package:plain_please/features/plain/services/plain_analyzer.dart';
import 'package:plain_please/features/plain/ui/documents_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;

  test('PlainAnalyzer detects glossary terms and preserves critical numbers/dates', () {
    const raw =
        'Se aplicará tácita reconducción si no ejerce su desistimiento antes del 15/12/2026.\n\n'
        'En caso de demora se cobrará un 5% sobre 1200 EUR.';
    final blocks = PlainAnalyzer.splitIntoBlocks(
      documentId: 'doc_1',
      rawText: raw,
      glossary: PlainAnalyzer.starterGlossary,
    );
    expect(blocks.length, 2);
    expect(blocks[0].detectedTerms, contains('tácita reconducción'));
    expect(blocks[0].detectedTerms, contains('desistimiento'));

    final exp2 = PlainAnalyzer.buildOfflineExplanation(
      block: blocks[1],
      glossary: PlainAnalyzer.starterGlossary,
    );
    expect(exp2.keyPoints, contains('5%'));
    expect(exp2.keyPoints, contains('1200 EUR'));
  });

  testWidgets('DocumentsScreen renders without overflow at 320px and 200% TextScaler', (tester) async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: PlainRepository.createSchema,
    );
    final repo = PlainRepository(testDb: db);
    await repo.saveDocumentBundle(
      doc: Documento(
        id: 'd_long',
        title: 'Clausula_${'L' * 100}',
        rawText: 'Texto de prueba',
        createdAt: DateTime(2026, 11, 17),
      ),
      blocks: const [],
      explanations: const [],
    );

    await tester.binding.setSurfaceSize(const Size(320, 568));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [plainRepositoryProvider.overrideWithValue(repo)],
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2.0),
          ),
          child: MaterialApp(
            theme: AppTheme.light(accent: const Color(0xFF6D28D9)),
            home: const DocumentsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
    await db.close();
  });
}

