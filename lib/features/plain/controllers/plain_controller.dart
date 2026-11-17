import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/ai_controller.dart';
import '../data/plain_repository.dart';
import '../models/plain_models.dart';
import '../services/plain_analyzer.dart';

final plainRepositoryProvider = Provider<PlainRepository>(
  (ref) => PlainRepository(),
);

class PlainState {
  const PlainState({
    this.documents = const [],
    this.blocks = const [],
    this.explanations = const [],
    this.glossary = const [],
  });

  final List<Documento> documents;
  final List<Bloque> blocks;
  final List<Explicacion> explanations;
  final List<Glosario> glossary;
}

class PlainController extends AsyncNotifier<PlainState> {
  @override
  Future<PlainState> build() async => _loadAll();

  PlainRepository get _repo => ref.read(plainRepositoryProvider);

  Future<PlainState> _loadAll() async {
    return PlainState(
      documents: await _repo.listDocuments(),
      blocks: await _repo.listBlocks(),
      explanations: await _repo.listExplanations(),
      glossary: await _repo.listGlossary(),
    );
  }

  Future<Documento> addDocument({
    required String title,
    required String rawText,
  }) async {
    final now = DateTime.now();
    final docId = 'doc_${now.microsecondsSinceEpoch}';
    final glossary = state.valueOrNull?.glossary ?? PlainAnalyzer.starterGlossary;

    final doc = Documento(
      id: docId,
      title: title.trim().isEmpty ? 'Texto sin título' : title.trim(),
      rawText: rawText.trim(),
      createdAt: now,
    );
    final blocks = PlainAnalyzer.splitIntoBlocks(
      documentId: docId,
      rawText: doc.rawText,
      glossary: glossary,
    );
    final explanations = blocks
        .map((b) => PlainAnalyzer.buildOfflineExplanation(
              block: b,
              glossary: glossary,
            ))
        .toList();

    await _repo.saveDocumentBundle(
      doc: doc,
      blocks: blocks,
      explanations: explanations,
    );
    state = AsyncData(await _loadAll());
    return doc;
  }

  Future<void> verifyExplanation(Explicacion exp, {String? editedText}) async {
    await _repo.upsertExplanation(
      exp.copyWith(
        plainText: editedText ?? exp.plainText,
        isVerified: true,
      ),
    );
    state = AsyncData(await _loadAll());
  }

  Future<void> addGlossaryTerm(String term, String definition) async {
    await _repo.upsertGlossary(
      Glosario(
        id: 'g_${DateTime.now().microsecondsSinceEpoch}',
        term: term.trim(),
        plainDefinition: definition.trim(),
      ),
    );
    state = AsyncData(await _loadAll());
  }

  Future<void> explainBlockWithAi({
    required Bloque block,
    required Explicacion currentExp,
    required String reviewedText,
  }) async {
    final ai = ref.read(aiSettingsProvider.notifier);
    final resp = await ai.runStructured(
      taskInstruction:
          'Explica este bloque de texto complejo en lenguaje claro y sencillo para cualquier persona, '
          'SIN omitir obligaciones, importes, porcentajes ni fechas. No inventes datos.',
      reviewedText: reviewedText,
      jsonSchemaHint: '''
{
  "plain_text": "explicación clara en español cotidiano",
  "key_points": "obligaciones, plazos o cifras clave"
}''',
    );
    final json = resp.parsedJson;
    if (json == null) return;
    final plainText = json['plain_text']?.toString().trim() ?? '';
    if (plainText.isEmpty) return;

    await _repo.upsertExplanation(
      currentExp.copyWith(
        plainText: plainText,
        keyPoints: json['key_points']?.toString() ?? currentExp.keyPoints,
        isAiDraft: true,
        isVerified: false,
      ),
    );
    state = AsyncData(await _loadAll());
  }
}

final plainControllerProvider =
    AsyncNotifierProvider<PlainController, PlainState>(PlainController.new);

