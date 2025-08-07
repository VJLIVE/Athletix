import 'package:flutter/material.dart';

class ManagePlayersScreen extends StatelessWidget {
  const ManagePlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Players")),
      body: const Center(child: Text("Manage Players Screen")),
    );
  }
}
