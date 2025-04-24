import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_discover_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _discoverItems = [];

  @override
  void initState() {
    super.initState();
    _fetchDiscoverData();
  }

  Future<void> _fetchDiscoverData() async {
    try {
      final clubsSnapshot = await FirebaseFirestore.instance.collection('clubs').get();

      List<Map<String, dynamic>> tempDiscoverList = [];

      for (var clubDoc in clubsSnapshot.docs) {
        final clubId = clubDoc.id;
        final presEmail = (clubDoc['presidentEmail'] ?? '').toString().toLowerCase();

        final discoverSnapshot = await clubDoc.reference.collection('discover').get();
        for (var doc in discoverSnapshot.docs) {
          final data = doc.data();
          data['clubName'] = clubDoc['clubName']; // add club name for filtering/display
          data['clubId']         = clubId;
          data['discId']         = doc.id;
          data['presidentEmail'] = presEmail;
          tempDiscoverList.add(data);
        }
      }

      setState(() {
        _discoverItems = tempDiscoverList;
      });
    } catch (e) {
      print("Error fetching discover data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEmail = FirebaseAuth.instance.currentUser?.email?.toLowerCase();
    List<Map<String, dynamic>> filteredList = _discoverItems.where((item) {
      final club = item['clubName']?.toLowerCase() ?? '';
      final content = item['discoverContent']?.toLowerCase() ?? '';
      return club.contains(_searchQuery) || content.contains(_searchQuery);
    }).toList();

    return Scaffold(
      body: RefreshIndicator(
      onRefresh: _fetchDiscoverData,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: "Search Discover",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Discover List
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(child: Text("No discover content found."))
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final clubId = item['clubId'] as String;
                          final discId = item['discId'] as String;
                          final isClubAdmin = currentEmail != null && currentEmail == item['presidentEmail'];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item['discoverImageUrl'] != null && item['discoverImageUrl'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),                        
                                  child: CachedNetworkImage(
                                    imageUrl: item['discoverImageUrl'],
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                                  ),
                                  // child: Image.network(
                                  //   item['discoverImageUrl'],
                                  //   height: 180,
                                  //   width: double.infinity,
                                  //   fit: BoxFit.cover,
                                  //   errorBuilder: (context, error, stackTrace) =>
                                  //       const Icon(Icons.broken_image),
                                  // ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['clubName'] ?? 'Unknown Club',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(item['discoverContent'] ?? ''),
                                  ],
                                ),
                              ),
                                // Edit/Delete for club admin
                                if (isClubAdmin)
                                  OverflowBar(
                                    alignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        label: const Text('Edit',
                                            style: TextStyle(color: Colors.blue)),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditDiscoverPage(
                                                clubId: clubId,
                                                discId: discId,
                                                existingData: item,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        label: const Text('Delete',
                                            style: TextStyle(color: Colors.red)),
                                        onPressed: () async {
                                          final yes = await showDialog<bool>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text('Delete Post'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this post?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context, false),
                                                      child: const Text('No'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context, true),
                                                      child: const Text('Yes'),
                                                    ),
                                                  ],
                                                ),
                                              ) ??
                                              false;
                                          if (yes) {
                                            await FirebaseFirestore.instance
                                                .collection('clubs')
                                                .doc(clubId)
                                                .collection('discover')
                                                .doc(discId)
                                                .delete();
                                            _fetchDiscoverData();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
