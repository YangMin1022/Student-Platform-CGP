import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'event_details_page.dart';
import 'clubs_page.dart';
import 'models/event.dart';


class EventsPage extends StatefulWidget {
  final String role;
  // final bool isAdmin;
  const EventsPage({super.key, required this.role});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upcoming Events")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('events')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No events available"));
                }
                final eventsDocs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: eventsDocs.length,
                  itemBuilder: (context, index) {
                    Event event = Event.fromFirestore(eventsDocs[index]);
                    return EventCard(event: event, role: widget.role);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClubsPage(role: widget.role)),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text("Explore Clubs"),
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final String role;
  const EventCard({super.key, required this.event, required this.role});

    Future<void> _launchForm(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the form.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuest = role == 'guest';

    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display event cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
                imageUrl: event.imageUrl,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => Container(
                  width: double.infinity,
                  height: 240,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (ctx, url, error) => const Icon(Icons.broken_image, size: 50),
              ),
            // child: Image.network(
            //   event.imageUrl,
            //   fit: BoxFit.cover,
            //   errorBuilder: (context, error, stackTrace) {
            //     return Image.asset('assets/images/badminton_tournament.jpg', fit: BoxFit.cover);
            //   },
            // ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text("${event.date} @ ${event.time}", style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 5),
                Text("Organized by: ${event.organizer}", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 16),
                    const SizedBox(width: 5),
                    Text(event.location, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // More Info Button
                    ElevatedButton(
                      onPressed: () {
                        print("More Info tapped!");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailsPage(event: event, role: role),
                          ),
                        );
                      },
                      child: const Text("More Info"),
                    ),
                    // Register is disabled for guests
                    ElevatedButton(
                      onPressed: isGuest
                          ? null
                          : () => _launchForm(context, event.googleFormLink),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isGuest ? Colors.grey : null,
                      ),
                      child: Text(isGuest ? "Login to Register" : "Register"),
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
