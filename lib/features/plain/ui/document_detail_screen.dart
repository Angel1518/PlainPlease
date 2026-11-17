import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/ai_controller.dart';
import '../../../core/ai/privacy_preview_dialog.dart';
import '../controllers/plain_controller.dart';
import '../models/plain_models.dart';

class DocumentDetailScreen extends ConsumerWidget {
  const DocumentDetailScreen({super.key, required this.documentId});
  final String documentId;

  Future<void> _explainWithAi(
    BuildContext context,
    WidgetRef ref,
    Bloque block,
    Explicacion exp,
  ) async {
    final aiSettings = ref.read(aiSettingsProvider);
    if (!aiSettings.enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activa la IA BYOK en Ajustes para generar explicaciones.'),
        ),
      );
      return;
    }
    final reviewed = await showPrivacyPreviewDialog(
      context: context,
      settings: aiSettings,
      initialText: block.originalText,
      title: 'Revisar bloque antes de explicar con IA',
    );
    if (reviewed == null || reviewed.isEmpty) return;
    try {
      await ref.read(plainControllerProvider.notifier).explainBlockWithAi(
            block: block,
            currentExp: exp,
            reviewedText: reviewed,
          );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error IA: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(plainControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Lectura por bloques')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) {
          final doc =
              data.documents.where((d) => d.id == documentId).firstOrNull;
          if (doc == null) {
            return const Center(child: Text('Documento no encontrado.'));
          }
          final blocks =
              data.blocks.where((b) => b.documentId == doc.id).toList();
          final expByBlock = {
            for (final e in data.explanations) e.blockId: e,
          };

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(doc.title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              ...blocks.map((block) {
                final exp = expByBlock[block.id];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bloque ${block.indexOrder + 1} · Original',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(block.originalText),
                          if (block.detectedTerms.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Chip(
                              avatar: const Icon(Icons.bookmark_outline,
                                  size: 16),
                              label: Text('Términos: ${block.detectedTerms}'),
                            ),
                          ],
                          if (exp != null) ...[
                            const Divider(height: 20),
                            Text(
                              exp.isVerified
                                  ? 'Explicación verificada'
                                  : (exp.isAiDraft
                                      ? 'Borrador IA (revisar)'
                                      : 'Análisis local'),
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(exp.plainText,
                                style: theme.textTheme.bodyLarge),
                            if (exp.keyPoints.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(exp.keyPoints,
                                    style: theme.textTheme.bodyMedium),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (!exp.isVerified)
                                  FilledButton.tonal(
                                    onPressed: () => ref
                                        .read(plainControllerProvider.notifier)
                                        .verifyExplanation(exp),
                                    child: const Text('Marcar revisado'),
                                  ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _explainWithAi(context, ref, block, exp),
                                  icon: const Icon(Icons.auto_awesome_outlined,
                                      size: 18),
                                  label: const Text('Explicar con IA'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

