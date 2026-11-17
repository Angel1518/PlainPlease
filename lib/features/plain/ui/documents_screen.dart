import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/plain_controller.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  Future<void> _importTextDialog(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final textCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Analizar texto denso'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej. Cláusula de renovación o carta médica',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: textCtrl,
                maxLines: 6,
                minLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Pega el texto (separa bloques con línea en blanco)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Desglosar'),
          ),
        ],
      ),
    );

    if (ok == true && textCtrl.text.trim().isNotEmpty) {
      final doc = await ref.read(plainControllerProvider.notifier).addDocument(
            title: titleCtrl.text,
            rawText: textCtrl.text,
          );
      if (context.mounted) context.push('/docs/${doc.id}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(plainControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('PlainPlease')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _importTextDialog(context, ref),
        icon: const Icon(Icons.text_fields),
        label: const Text('Nuevo texto'),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Entiende el texto sin perder lo importante',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            if (data.documents.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_outlined,
                            size: 52, color: theme.colorScheme.primary),
                        const SizedBox(height: 12),
                        Text('Pega un texto legal, contrato o aviso',
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 6),
                        Text(
                          'Lo dividimos en bloques y detectamos términos del glosario y cifras clave sin conexión.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 92),
                sliver: SliverList.separated(
                  itemCount: data.documents.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final doc = data.documents[index];
                    final blockCount = data.blocks
                        .where((b) => b.documentId == doc.id)
                        .length;
                    return TweenAnimationBuilder<double>(
                      duration: AppMotion.duration(
                        context,
                        Duration(milliseconds: 180 + (index.clamp(0, 6) * 35)),
                      ),
                      curve: AppMotion.curve(context),
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, t, child) => Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - t)),
                          child: child,
                        ),
                      ),
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.12),
                            child: Icon(Icons.article_outlined,
                                color: theme.colorScheme.primary),
                          ),
                          title: Text(doc.title,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text('$blockCount bloques'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/docs/${doc.id}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

