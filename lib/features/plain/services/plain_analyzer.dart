import '../models/plain_models.dart';

class PlainAnalyzer {
  static const List<Glosario> starterGlossary = [
    Glosario(
      id: 'g_1',
      term: 'tácita reconducción',
      plainDefinition:
          'El contrato se renueva automáticamente si ninguna parte avisa antes del plazo.',
    ),
    Glosario(
      id: 'g_2',
      term: 'desistimiento',
      plainDefinition:
          'Derecho a echarse atrás y cancelar un contrato dentro del plazo legal sin penalización.',
    ),
    Glosario(
      id: 'g_3',
      term: 'demora',
      plainDefinition:
          'Retraso en un pago o entrega, que suele generar intereses o recargos.',
    ),
    Glosario(
      id: 'g_4',
      term: 'subrogación',
      plainDefinition:
          'Sustituir a una persona o entidad por otra asumiendo sus mismos derechos y obligaciones.',
    ),
    Glosario(
      id: 'g_5',
      term: 'silencio administrativo',
      plainDefinition:
          'Efecto legal cuando la administración no responde en plazo (puede ser favorable o denegatorio según el trámite).',
    ),
    Glosario(
      id: 'g_6',
      term: 'resolución contractual',
      plainDefinition:
          'Finalización anticipada del contrato por incumplimiento o acuerdo.',
    ),
  ];

  static List<Bloque> splitIntoBlocks({
    required String documentId,
    required String rawText,
    required List<Glosario> glossary,
  }) {
    final chunks = rawText
        .split(RegExp(r'\n\s*\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return [
      for (var i = 0; i < chunks.length; i++)
        Bloque(
          id: '${documentId}_blk_$i',
          documentId: documentId,
          indexOrder: i,
          originalText: chunks[i],
          detectedTerms: findTermsInText(chunks[i], glossary).join(', '),
        ),
    ];
  }

  static List<String> findTermsInText(String text, List<Glosario> glossary) {
    final lower = text.toLowerCase();
    return glossary
        .where((g) => lower.contains(g.term.toLowerCase()))
        .map((g) => g.term)
        .toList();
  }

  /// Extracts key numbers, dates, and percentages that must not be lost in simplification.
  static List<String> extractCriticalTokens(String text) {
    final tokens = <String>[];
    final matches = RegExp(
      r'\b\d+(?:[.,]\d+)?\s*(?:€|%|(?:eur|d[ií]as|meses|a[ñn]os)\b)|\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b',
      caseSensitive: false,
    ).allMatches(text);
    for (final m in matches) {
      tokens.add(m.group(0)!.trim());
    }
    return tokens.toSet().toList();
  }

  static Explicacion buildOfflineExplanation({
    required Bloque block,
    required List<Glosario> glossary,
  }) {
    final terms = findTermsInText(block.originalText, glossary);
    final critical = extractCriticalTokens(block.originalText);

    final notes = StringBuffer();
    if (terms.isNotEmpty) {
      for (final term in terms) {
        final def = glossary
            .firstWhere((g) => g.term.toLowerCase() == term.toLowerCase())
            .plainDefinition;
        notes.writeln('• $term: $def');
      }
    } else {
      notes.writeln(
          '• Sin tecnicismos del glosario detectados; revisa cifras y plazos.');
    }

    return Explicacion(
      id: 'exp_${block.id}',
      blockId: block.id,
      plainText: notes.toString().trim(),
      keyPoints: critical.isEmpty ? '' : 'Datos clave: ${critical.join(' · ')}',
      isAiDraft: false,
      isVerified: false,
    );
  }
}
