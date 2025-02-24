import 'package:flutter/material.dart';
import 'discover_page.dart'; // Import Discover Page
import 'club_details_page.dart'; // Import Club Details Page

class ClubsPage extends StatefulWidget {
  const ClubsPage({Key? key}) : super(key: key);

  @override
  _ClubsPageState createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
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

  void _navigateToClubDetails(
      String clubName, String description, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubDetailsPage(
          clubName: clubName,
          description: description,
          imagePath: imagePath,
        ),
      ),
    );
  }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Search Club",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // SPORTS CLUB
            _buildClubCard(
              clubName: "SPORTS CLUB",
              description:
                  "We specialize in organizing top-tier sports events and tournaments that bring together athletes, sports enthusiasts, and fans from all walks of life.",
              imagePath: "assets/images/sports_club.jpg",
            ),
            const SizedBox(height: 20),

            // CULTURE CLUB
            _buildClubCard(
              clubName: "CULTURE CLUB",
              description:
                  "Our cultural club promotes diversity, creativity, and inclusivity through exciting events, performances, and community engagement activities.",
              imagePath: "assets/images/cultural_club.jpg",
            ),
          ],
        ),
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
      required String imagePath}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Club Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(imagePath,
                width: double.infinity, height: 150, fit: BoxFit.cover),
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
                        _navigateToClubDetails(
                            clubName, description, imagePath);
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
