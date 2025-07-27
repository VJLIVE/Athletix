import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConnectionRequestsScreen extends StatelessWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connection Requests"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getConnectionRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No connection requests',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final requestDoc = snapshot.data!.docs[index];
              final requestData = requestDoc.data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      (requestData['organizationName'] ?? 'O')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    requestData['organizationName'] ?? 'Unknown Organization',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('wants to connect with you'),
                      Text(
                        'Status: ${(requestData['status'] ?? '').toString().toUpperCase()}',
                        style: TextStyle(
                          color: requestData['status'] == 'accepted' ? Colors.green : 
                                 requestData['status'] == 'pending' ? Colors.orange : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: requestData['status'] == 'pending' 
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _respondToRequest(requestDoc.id, 'accepted', context),
                            icon: const Icon(Icons.check, color: Colors.green),
                            tooltip: 'Accept',
                          ),
                          IconButton(
                            onPressed: () => _respondToRequest(requestDoc.id, 'rejected', context),
                            icon: const Icon(Icons.close, color: Colors.red),
                            tooltip: 'Reject',
                          ),
                        ],
                      )
                    : Icon(
                        requestData['status'] == 'accepted' ? Icons.check_circle : Icons.cancel,
                        color: requestData['status'] == 'accepted' ? Colors.green : Colors.red,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getConnectionRequestsStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('player_connections')
        .where('playerId', isEqualTo: uid)
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  Future<void> _respondToRequest(String requestId, String response, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('player_connections')
          .doc(requestId)
          .update({
        'status': response,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response == 'accepted' 
              ? 'Connection request accepted!' 
              : 'Connection request rejected!',
          ),
          backgroundColor: response == 'accepted' ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to respond to request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
