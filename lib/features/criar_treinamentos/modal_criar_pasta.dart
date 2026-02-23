import 'package:flutter/material.dart';
import '../../shared/services/pastas_db.dart';
import '../../shared/modals/modal_success_erro.dart';

Future<String?> showCreateFolderModal(BuildContext context) {
  final controller = TextEditingController();
  final db = PastasBb();

  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Criar pasta'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome da pasta',
            hintText: 'Ex: Programação em Python',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nome = controller.text.trim();

              if (nome.isEmpty) {
                await showResultModal(
                  context,
                  type: ResultType.error,
                  title: 'Erro',
                  message: 'O campo com o nome não foi preenchido',
                  replaceAll: false,
                );
                return;
              }

              // 3) tenta salvar (com await)
              try {
                await db.createFolder(nome);
                Navigator.pop(ctx, null);
                await showResultModal(
                  context,
                  type: ResultType.success,
                  title: 'Sucesso!',
                  message: 'Pasta criada com sucesso.',
                  replaceAll: false,
                );
              } catch (e) {
                Navigator.pop(ctx, null);
                await showResultModal(
                  context,
                  type: ResultType.error,
                  title: 'Erro',
                  message: 'Algo deu errado ao criar a pasta',
                  replaceAll: false,
                );
              }
            },
            child: const Text('Criar'),
          ),
        ],
      );
    },
  );
}
