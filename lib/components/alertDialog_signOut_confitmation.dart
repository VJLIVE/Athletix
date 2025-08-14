import 'package:athletix/views/screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:athletix/l10n/app_localizations.dart';

Future<void> signoutConfirmation(
  BuildContext context, {
  required Function(Locale) setLocale,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final localizations = AppLocalizations.of(context)!;
      return AlertDialog(
        title: Text(localizations.signOutDialogTitle),
        content: Text(localizations.signOutConfirmationMessage),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.cancelButton),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();

                    if (context.mounted) {
                      Fluttertoast.showToast(
                        msg: localizations.signOutSuccessToast,
                        backgroundColor: Colors.green,
                      );
                      // Pass the setLocale function to the AuthScreen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AuthScreen(setLocale: setLocale),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                        msg:
                            '${localizations.signOutFailedToast}: ${e.toString()}',
                        backgroundColor: Colors.red,
                      );
                      debugPrint("Sign out error: $e");
                    }
                  }
                },
                child: Text(
                  localizations.signOutButton,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
