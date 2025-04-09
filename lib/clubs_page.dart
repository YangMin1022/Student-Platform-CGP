import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'discover_page.dart'; // Import Discover Page
import 'club_details_page.dart'; // Import Club Details Page

class ClubsPage extends StatefulWidget {
  const ClubsPage({Key? key}) : super(key: key);

  @override
  _ClubsPageState createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int _selectedIndex = 0; // Default selected tab (Home)

  void _onItemTapped(int index) {
    if (index == 2) {
      // Navigate to Discover Page when 3rd icon is clicked
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DiscoverPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // void _navigateToClubDetails(
  //     String clubName, String description, String imagePath, String activities, String picName, String picContact, String picPosition) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ClubDetailsPage(
  //         clubName: clubName,
  //         description: description,
  //         imagePath: imagePath,
  //         activities: activities,
  //         picName: picName,
  //         picContact: picContact,
  //         picPosition: picPosition,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Club",
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.account_circle, color: Colors.black, size: 30),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Club',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                    return _buildClubCard(
                      clubName: data['clubName'] ?? '',
                      description: data['clubDescription'] ?? '',
                      imagePath: data['clubImageUrl'] ?? '',
                      activities: data['clubActivities'] ?? '',
                      picName: data['picName'] ?? '',
                      picContact: data['picContactNumber'] ?? '',
                      picPosition: data['picPosition'] ?? '',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),


      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Calendar"),
          BottomNavigationBarItem(
              icon: Icon(Icons.public),
              label: "Discover"), // Navigate to DiscoverPage
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        ],
      ),
    );
  }

  Widget _buildClubCard(
      {required String clubName,
      required String description,
      required String imagePath,
      required String activities,
      required String picName,
      required String picContact,
      required String picPosition,}) {
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
                      onPressed: () {},
                      child: const Text("Register",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
