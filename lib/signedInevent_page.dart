import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'models/event.dart';               // <- import the model
import 'event_details_page.dart';
import 'edit_event_page.dart';

final _lowMemCache = CacheManager(
  Config(
    'lowMemKey',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 20,        // only 20 files on disk
    repo: JsonCacheInfoRepository(databaseName: 'lowMemCache'),
    fileService: HttpFileService(),
  ),
);

class SignedInEventsPage extends StatefulWidget {
  final String role;
  const SignedInEventsPage({Key? key, required this.role}) : super(key: key);

  @override
  _SignedInEventsPageState createState() => _SignedInEventsPageState();
}

class _SignedInEventsPageState extends State<SignedInEventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // This will pull every doc in every "events" subcollection under clubs/*
              stream: FirebaseFirestore.instance
                  .collectionGroup('events')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No events available.'));
                }
                // final events = docs.map((d) => Event.fromFirestore(d)).toList();

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    final event = Event.fromFirestore(doc);
                    return EventCard(
                      event: event,
                      role: widget.role,
                      eventId: doc.id,
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
}

class EventCard extends StatelessWidget {
  final Event event;
  final String role;
  final String eventId;
  const EventCard({Key? key, required this.event, required this.role, required this.eventId}) : super(key: key);

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
    final isGuest = role == 'guest';
    final currentEmail = FirebaseAuth.instance.currentUser?.email?.toLowerCase() ?? '';
    return Card(
      margin: const EdgeInsets.all(10),
      child: StreamBuilder<DocumentSnapshot>(
        // fetch the parent club to read presidentEmail
        stream:
            FirebaseFirestore.instance
            .collection('clubs')
            .doc(event.clubId)
            .snapshots(),
        builder: (context, clubSnap) {
          // while loading club info, just show a placeholder
          if (!clubSnap.hasData) return const SizedBox(height: 200);
          final clubData = clubSnap.data!.data() as Map<String, dynamic>;
          final presidentEmail =
              (clubData['presidentEmail'] ?? '').toString().toLowerCase();
          final isAdmin = role == 'admin';
          final isClubAdmin = currentEmail == presidentEmail;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display event cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: event.imageUrl,
                width: double.infinity,
                cacheManager: _lowMemCache,
                memCacheWidth: 400,
                memCacheHeight: 240,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => Container(
                  width: double.infinity,
                  height: 240,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (ctx, url, error) => const Icon(Icons.broken_image, size: 50),
              ),
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
                      // Register Button
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
                    // Edit button only for admin or club president
                    if (isAdmin || isClubAdmin) ...[
                      const Divider(),
                      TextButton.icon(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        label: const Text("Edit Event",
                            style: TextStyle(color: Colors.blue)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditEventPage(
                                clubId: event.clubId,
                                eventId: eventId,
                                existingData: {
                                  'eventName':           event.title,
                                  'eventDate':           event.date,
                                  'eventTime':           event.time,
                                  'eventOrganizer':      event.organizer,
                                  'eventVenue':          event.location,
                                  'eventCategory':       event.eventCategory,
                                  'eventFee':            event.eventFee,
                                  'eventDescription':    event.description,
                                  'eventTransportation': event.eventTransportation,
                                  'numParticipants':     event.numParticipant,
                                  'eventCoverPic':       event.imageUrl,
                                  'googleFormLink':      event.googleFormLink,
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}