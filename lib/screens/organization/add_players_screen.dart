import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPlayersScreen extends StatefulWidget {
  final String sport;
  
  const AddPlayersScreen({super.key, required this.sport});

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.sport.toUpperCase()} Players'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search players by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Available Players List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getAvailablePlayersStream(),
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
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${widget.sport} players found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return searchQuery.isEmpty || name.contains(searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      'No players match your search',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final playerDoc = filteredDocs[index];
                    final playerData = playerDoc.data() as Map<String, dynamic>;
                    
                    return FutureBuilder<DocumentSnapshot?>(
                      future: _getConnectionStatus(playerDoc.id),
                      builder: (context, connectionSnapshot) {
                        final connectionStatus = connectionSnapshot.data?.data() as Map<String, dynamic>?;
                        final status = connectionStatus?['status'];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Text(
                                (playerData['name'] ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              playerData['name'] ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sport: ${playerData['sport'] ?? 'N/A'}'),
                                Text('Email: ${playerData['email'] ?? 'N/A'}'),
                                if (status != null) 
                                  Text(
                                    'Status: ${status.toString().toUpperCase()}',
                                    style: TextStyle(
                                      color: status == 'accepted' ? Colors.green : 
                                             status == 'pending' ? Colors.orange : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: _buildActionButton(playerDoc.id, status),
                            onTap: () => _showPlayerModal(playerData, playerDoc.id, status),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String playerId, String? status) {
    if (status == 'accepted') {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (status == 'pending') {
      return const Icon(Icons.access_time, color: Colors.orange);
    } else {
      return IconButton(
        onPressed: () => _sendConnectionRequest(playerId),
        icon: const Icon(Icons.add_circle, color: Colors.blue),
        tooltip: 'Send Connection Request',
      );
    }
  }

  Stream<QuerySnapshot> _getAvailablePlayersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Athlete')
        .where('sport', isEqualTo: widget.sport)
        .snapshots();
  }

  Future<DocumentSnapshot?> _getConnectionStatus(String playerId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('player_connections')
          .where('organizationId', isEqualTo: uid)
          .where('playerId', isEqualTo: playerId)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
    } catch (e) {
      return null;
    }
  }

  void _showPlayerModal(Map<String, dynamic> playerData, String playerId, String? status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(playerData['name'] ?? 'Player Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', playerData['name']),
              _buildDetailRow('Email', playerData['email']),
              _buildDetailRow('Sport', playerData['sport']),
              _buildDetailRow('Role', playerData['role']),
              _buildDetailRow('Phone', playerData['phone']),
              if (status != null) 
                _buildDetailRow('Connection Status', status.toUpperCase()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (status != 'accepted' && status != 'pending')
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _sendConnectionRequest(playerId);
              },
              icon: const Icon(Icons.add),
              label: const Text('Send Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendConnectionRequest(String playerId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final organizationDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      final organizationName = organizationDoc.data()?['name'] ?? 'Unknown Organization';
      
      await FirebaseFirestore.instance
          .collection('player_connections')
          .add({
        'organizationId': uid,
        'playerId': playerId,
        'organizationName': organizationName,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {}); // Refresh the UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send connection request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
