import 'package:flutter/material.dart';

const chinguStudentOnlyMessage = '대학생만 이용 가능합니다.';

Future<void> showAccessDenied(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('접근 제한'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}
