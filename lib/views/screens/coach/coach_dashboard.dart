import 'package:athletix/components/alertDialog_signOut_confitmation.dart';
import 'package:flutter/material.dart';

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
              await signoutConfirmation(context);
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Welcome, Coach!', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
