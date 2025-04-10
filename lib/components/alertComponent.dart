import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void _showAnalogAlert(BuildContext context, bool isSuccess) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            SizedBox(width: 10),
            Text(isSuccess ? 'Success' : 'Error'),
          ],
        ),
        content: Text(isSuccess
            ? 'The operation was successful.'
            : 'The operation failed.'),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
