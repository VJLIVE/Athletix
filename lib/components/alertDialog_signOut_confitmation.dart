import 'package:athletix/views/screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> signoutConfirmation(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to Sign Out?"),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();

                    if (context.mounted) {
                      Fluttertoast.showToast(
                        msg: "Signed Out successfully",
                        backgroundColor: Colors.green,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                        msg: 'Failed to Sign out: ${e.toString()}',
                        backgroundColor: Colors.red,
                      );
                      debugPrint("Sign out error: $e");
                    }
                  }
                },
                child: const Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
