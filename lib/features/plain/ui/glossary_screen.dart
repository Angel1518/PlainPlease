import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/plain_controller.dart';

class GlossaryScreen extends ConsumerWidget {
  const GlossaryScreen({super.key});

  Future<void> _addTermDialog(BuildContext context, WidgetRef ref) async {
    final termCtrl = TextEditingController();
    final defCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo término'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: termCtrl,
              decoration: const InputDecoration(labelText: 'Término técnico'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: defCtrl,
              maxLines: 3,
              decoration:
                  const InputDecoration(labelText: 'Explicación sencilla'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true && termCtrl.text.trim().isNotEmpty) {
      await ref
          .read(plainControllerProvider.notifier)
          .addGlossaryTerm(termCtrl.text, defCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(plainControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Glosario claro')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTermDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          itemCount: data.glossary.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final item = data.glossary[i];
            return Card(
              child: ListTile(
                title: Text(item.term),
                subtitle: Text(item.plainDefinition),
              ),
            );
          },
        ),
      ),
    );
  }
}

