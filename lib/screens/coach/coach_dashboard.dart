import 'package:athletix/components/Alertdialog_signout.dart';
import 'package:flutter/material.dart';
import '../auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoachDashboardScreen extends StatelessWidget {
  const CoachDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await AlertDialog_signout(context);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome, Coach!', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
