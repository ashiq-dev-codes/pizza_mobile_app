import 'package:flutter/material.dart';

class LoadingDialog {
  static Future<T> show<T>(BuildContext context, Future<T> future) async {
    // Show the loading dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (c) => Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(c).size.width * 0.3,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator.adaptive(),
                  SizedBox(height: 15),
                  Text('Loading...'),
                ],
              ),
            ),
          ),
    );

    try {
      return await future;
    } catch (e) {
      rethrow;
    } finally {
      // Dismiss the dialog using the context of the dialog itself
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }
}
