import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'discover_page.dart'; // Import Discover Page
import 'club_details_page.dart'; // Import Club Details Page
import 'admin_page.dart';
import 'signedInEvent_page.dart';
import 'club_registration_form.dart'; // Import Club Registration Page
import 'club_members_page.dart';
import 'edit_club_page.dart';

class ClubsPage extends StatefulWidget {
  final String role; // Role of the user (admin or non-admin)
  // final bool isAdmin;
  const ClubsPage({Key? key, required this.role}) : super(key: key);

  @override
  _ClubsPageState createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get isAdminTabVisible => widget.role == 'admin' || widget.role == 'clubAdmin';

  int _selectedIndex = 0; // Default selected tab (Home)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle(int index) {
  switch (index) {
    case 0:
      return 'Clubs';
    case 1:
      return 'Events';
    case 2:
      return 'Discover';
    case 3:
      return 'Admin Panel';
    default:
      return 'App';
  }
}


  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      buildClubList(), // Home/Clubs
      SignedInEventsPage(role: widget.role), // Events
      const DiscoverPage(), // Discover
      if (isAdminTabVisible) AdminPage(role: widget.role), // Admin
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          _getAppBarTitle(_selectedIndex),
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.account_circle, color: Colors.black, size: 30),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: isAdminTabVisible
            ? const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
                BottomNavigationBarItem(icon: Icon(Icons.public), label: "Discover"),
                BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: "Admin"),
              ]
            : const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
                BottomNavigationBarItem(icon: Icon(Icons.public), label: "Discover"),
              ],
      ),
    );
  }

  Widget buildClubList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Club',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('clubs').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No clubs found"));
              }

              final clubs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['clubName']?.toLowerCase() ?? '';
                final desc = data['clubDescription']?.toLowerCase() ?? '';
                return name.contains(_searchQuery) || desc.contains(_searchQuery);
              }).toList();

              if (clubs.isEmpty) {
                return const Center(child: Text("No matching clubs found"));
              }

              return ListView.builder(
                itemCount: clubs.length,
                itemBuilder: (context, index) {
                  final data = clubs[index].data() as Map<String, dynamic>;
                  final presidentEmail = data['presidentEmail'] as String? ?? '';
                  return _buildClubCard(
                    clubId: clubs[index].id, 
                    clubName: data['clubName'] ?? '',
                    description: data['clubDescription'] ?? '',
                    imagePath: data['clubImageUrl'] ?? '',
                    activities: data['clubActivities'] ?? '',
                    picName: data['picName'] ?? '',
                    picContact: data['picContactNumber'] ?? '',
                    picPosition: data['picPosition'] ?? '',
                    presidentEmail: presidentEmail,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClubCard(
      {required String clubId,
      required String clubName,
      required String description,
      required String imagePath,
      required String activities,
      required String picName,
      required String picContact,
      required String picPosition,
      String? presidentEmail,}) {
    // get the signed‑in user’s email
    final currentEmail = FirebaseAuth.instance.currentUser?.email?.toLowerCase();
    final isAdmin        = widget.role == 'admin';
    final isClubAdmin    = presidentEmail?.toLowerCase() == currentEmail;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Club Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(imagePath,
                width: double.infinity, height: 150, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(description, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 10),

                // Buttons (More Info & Register)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClubDetailsPage(
                              clubName: clubName,
                              description: description,
                              imagePath: imagePath,
                              activities: activities,
                              picName: picName,
                              picContact: picContact,
                              picPosition: picPosition,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child: const Text("More Info",
                          style: TextStyle(color: Colors.white)),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                         context,
                         MaterialPageRoute(
                          builder: (_) => ClubRegistrationPage(
                            clubId: clubId,
                            clubName: clubName,
                          ),
                        ),
                      );
                      },
                      child: const Text("Register",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              // only admin or clubAdmin see these:
              if (isAdmin || isClubAdmin) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.group),
                      label: const Text("View Members"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClubMembersPage(clubId: clubId),
                          ),
                        );
                      },
                    ),

                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditClubPage(
                              clubId: clubId,
                              existingData: {
                                'clubName': clubName,
                                'clubDescription': description,
                                'clubActivities': activities,
                                'clubImageUrl': imagePath,
                                'picName': picName,
                                'picContactNumber': picContact,
                                'picPosition': picPosition,
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
