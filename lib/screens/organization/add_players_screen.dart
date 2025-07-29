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
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPlayersScreen extends StatefulWidget {
  final String sport;
  
  const AddPlayersScreen({super.key, required this.sport});

  @Override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Players"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Athletes by Email',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Enter athlete email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _searchAthletes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Results Section
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Search for athletes to connect',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final athlete = _searchResults[index];
                          final athleteData = athlete.data() as Map<String, dynamic>;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  (athleteData['name'] ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                athleteData['name'] ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${athleteData['email'] ?? 'N/A'}'),
                                  Text('Sport: ${athleteData['sport'] ?? 'N/A'}'),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _sendConnectionRequest(athlete.id, athleteData),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Connect'),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchAthletes() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an email to search'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'athlete')
          .where('sport', isEqualTo: widget.sport)
          .where('email', isEqualTo: _searchController.text.trim().toLowerCase())
          .get();

      setState(() {
        _searchResults = querySnapshot.docs;
        _isSearching = false;
      });

      if (_searchResults.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No athletes found with that email'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendConnectionRequest(String athleteId, Map<String, dynamic> athleteData) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      
      // Check if connection request already exists
      final existingRequest = await FirebaseFirestore.instance
          .collection('connection_requests')
          .where('athleteId', isEqualTo: athleteId)
          .where('organizationId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection request already sent'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Check if already connected
      final existingConnection = await FirebaseFirestore.instance
          .collection('player_connections')
          .where('playerId', isEqualTo: athleteId)
          .where('organizationId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'accepted')
          .get();

      if (existingConnection.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Already connected with this athlete'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Create connection request
      await FirebaseFirestore.instance
          .collection('connection_requests')
          .add({
        'athleteId': athleteId,
        'organizationId': currentUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection request sent to ${athleteData['name']}'),
          backgroundColor: Colors.green,
        ),
      );

      // Remove from search results
      setState(() {
        _searchResults.removeWhere((doc) => doc.id == athleteId);
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
