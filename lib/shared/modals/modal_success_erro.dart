import 'package:flutter/material.dart';

enum ResultType { success, error }

Future<void> showResultModal(
  BuildContext context, {
  required ResultType type,
  required String title,
  required String message,
  Object? routeArgs,
  bool replaceAll = false, // se true, limpa a pilha e vai pra rota
}) {
  final isSuccess = type == ResultType.success;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/criar_treinamento');
            },
            child: const Text('Fechar'),
          ),
        ],
      );
    },
  );
}
