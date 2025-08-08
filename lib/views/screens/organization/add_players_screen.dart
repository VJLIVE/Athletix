import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/user_model.dart';

class AddPlayersScreen extends StatefulWidget {
  final String organizationSport;

  const AddPlayersScreen({
    super.key,
    required this.organizationSport,
  });

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _connectedPlayerIds = {};
  Set<String> _pendingRequestIds = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConnectedPlayersAndRequests();
  }

  Future<void> _loadConnectedPlayersAndRequests() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      // Load connected players
      final connectedSnapshot = await _firestore
          .collection('organization_players')
          .doc(uid)
          .collection('connected_players')
          .get();

      // Load pending requests
      final requestsSnapshot = await _firestore
          .collection('connection_requests')
          .where('organizationId', isEqualTo: uid)
          .where('status', isEqualTo: 'pending')
          .get();

      setState(() {
        _connectedPlayerIds = connectedSnapshot.docs.map((doc) => doc.id).toSet();
        _pendingRequestIds = requestsSnapshot.docs.map((doc) => doc.data()['athleteId'] as String).toSet();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Stream<List<UserModel>> _getAvailablePlayers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Athlete')
        .where('sport', isEqualTo: widget.organizationSport)
        .snapshots()
        .map((snapshot) {
      List<UserModel> players = [];
      for (var doc in snapshot.docs) {
        try {
          final player = UserModel.fromFirestore(doc);
          // Filter based on search query and exclude connected players
          if (!_connectedPlayerIds.contains(player.uid)) {
            if (_searchQuery.isEmpty ||
                player.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                player.email.toLowerCase().contains(_searchQuery.toLowerCase())) {
              players.add(player);
            }
          }
        } catch (e) {
          print('Error parsing player: $e');
        }
      }
      return players;
    });
  }

  Future<void> _sendConnectionRequest(UserModel player) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      // Get organization details
      final orgDoc = await _firestore.collection('users').doc(uid).get();
      final orgData = orgDoc.data() as Map<String, dynamic>;

      // Create connection request
      await _firestore.collection('connection_requests').add({
        'organizationId': uid,
        'organizationName': orgData['name'],
        'athleteId': player.uid,
        'athleteName': player.name,
        'sport': widget.organizationSport,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create notification for the athlete
      await _firestore
          .collection('notifications')
          .doc(player.uid)
          .collection('user_notifications')
          .add({
        'title': 'Connection Request',
        'message': '${orgData['name']} wants to connect with you',
        'type': 'connection_request',
        'organizationId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      setState(() {
        _pendingRequestIds.add(player.uid);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection request sent to ${player.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error sending connection request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Players"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sports,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Finding ${widget.organizationSport} Athletes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search athletes by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _getAvailablePlayers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final players = snapshot.data ?? [];

                if (players.isEmpty) {
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
                          _searchQuery.isEmpty
                              ? 'No available ${widget.organizationSport} athletes found'
                              : 'No athletes match your search',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Text('Clear search'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final isPending = _pendingRequestIds.contains(player.uid);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            player.name.isNotEmpty ? player.name[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          player.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(player.email),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.sports,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  player.sport,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (player.emailVerified) ...[
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Verified',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _showPlayerDetails(player),
                              icon: const Icon(Icons.visibility),
                              tooltip: 'View Details',
                            ),
                            if (isPending)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: const Text(
                                  'Pending',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            else
                              IconButton(
                                onPressed: () => _sendConnectionRequest(player),
                                icon: const Icon(Icons.add_circle),
                                color: Colors.green,
                                tooltip: 'Send Request',
                              ),
                          ],
                        ),
                      ),
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

  void _showPlayerDetails(UserModel player) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      player.name.isNotEmpty ? player.name[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          player.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        if (player.emailVerified)
                          const Row(
                            children: [
                              Icon(
                                Icons.verified,
                                size: 16,
                                color: Colors.green,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Sport', player.sport),
              _buildDetailRow('Role', player.role),
              _buildDetailRow('Date of Birth', player.dob.toString().split(' ')[0]),
              _buildDetailRow('Account Created', player.createdAt.toString().split(' ')[0]),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  if (!_pendingRequestIds.contains(player.uid))
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _sendConnectionRequest(player);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Send Request'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text(
                        'Request Pending',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
