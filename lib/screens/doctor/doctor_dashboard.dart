import 'package:athletix/components/alertDialog_signOut_confitmation.dart';
import 'package:flutter/material.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
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
          const Center(
            child: Text('Welcome, Doctor!', style: TextStyle(fontSize: 20)),
          ),
         
        ],
      ),
    );
  }
}
