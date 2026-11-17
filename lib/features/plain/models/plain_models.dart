class Documento {
  const Documento({
    required this.id,
    required this.title,
    required this.rawText,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String rawText;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'raw_text': rawText,
        'created_at': createdAt.toIso8601String(),
      };

  factory Documento.fromMap(Map<String, dynamic> map) => Documento(
        id: map['id'] as String,
        title: map['title'] as String,
        rawText: map['raw_text'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class Bloque {
  const Bloque({
    required this.id,
    required this.documentId,
    required this.indexOrder,
    required this.originalText,
    this.detectedTerms = '',
  });

  final String id;
  final String documentId;
  final int indexOrder;
  final String originalText;
  final String detectedTerms;

  Map<String, dynamic> toMap() => {
        'id': id,
        'document_id': documentId,
        'index_order': indexOrder,
        'original_text': originalText,
        'detected_terms': detectedTerms,
      };

  factory Bloque.fromMap(Map<String, dynamic> map) => Bloque(
        id: map['id'] as String,
        documentId: map['document_id'] as String,
        indexOrder: map['index_order'] as int,
        originalText: map['original_text'] as String,
        detectedTerms: map['detected_terms'] as String? ?? '',
      );
}

class Explicacion {
  const Explicacion({
    required this.id,
    required this.blockId,
    required this.plainText,
    required this.keyPoints,
    this.isAiDraft = false,
    this.isVerified = false,
  });

  final String id;
  final String blockId;
  final String plainText;
  final String keyPoints;
  final bool isAiDraft;
  final bool isVerified;

  Explicacion copyWith({
    String? plainText,
    String? keyPoints,
    bool? isAiDraft,
    bool? isVerified,
  }) =>
      Explicacion(
        id: id,
        blockId: blockId,
        plainText: plainText ?? this.plainText,
        keyPoints: keyPoints ?? this.keyPoints,
        isAiDraft: isAiDraft ?? this.isAiDraft,
        isVerified: isVerified ?? this.isVerified,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'block_id': blockId,
        'plain_text': plainText,
        'key_points': keyPoints,
        'is_ai_draft': isAiDraft ? 1 : 0,
        'is_verified': isVerified ? 1 : 0,
      };

  factory Explicacion.fromMap(Map<String, dynamic> map) => Explicacion(
        id: map['id'] as String,
        blockId: map['block_id'] as String,
        plainText: map['plain_text'] as String,
        keyPoints: map['key_points'] as String? ?? '',
        isAiDraft: (map['is_ai_draft'] as int? ?? 0) == 1,
        isVerified: (map['is_verified'] as int? ?? 0) == 1,
      );
}

class Glosario {
  const Glosario({
    required this.id,
    required this.term,
    required this.plainDefinition,
  });

  final String id;
  final String term;
  final String plainDefinition;

  Map<String, dynamic> toMap() => {
        'id': id,
        'term': term,
        'plain_definition': plainDefinition,
      };

  factory Glosario.fromMap(Map<String, dynamic> map) => Glosario(
        id: map['id'] as String,
        term: map['term'] as String,
        plainDefinition: map['plain_definition'] as String,
      );
}

class Revision {
  const Revision({
    required this.id,
    required this.explanationId,
    required this.note,
    required this.reviewedAt,
  });

  final String id;
  final String explanationId;
  final String note;
  final DateTime reviewedAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'explanation_id': explanationId,
        'note': note,
        'reviewed_at': reviewedAt.toIso8601String(),
      };
}

