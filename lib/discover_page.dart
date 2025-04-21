import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        final discoverSnapshot = await clubDoc.reference.collection('discover').get();
        for (var doc in discoverSnapshot.docs) {
          final data = doc.data();
          data['clubName'] = clubDoc['clubName']; // add club name for filtering/display
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
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
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
