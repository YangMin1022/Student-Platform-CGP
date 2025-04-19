// lib/signedInevent_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models/event.dart';               // <- import the model
import 'event_details_page.dart';
import 'event_registration_form.dart';

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
                final events =
                    docs.map((d) => Event.fromFirestore(d)).toList();

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (_, i) => EventCard(event: events[i], role: widget.role),
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
  const EventCard({Key? key, required this.event, required this.role}) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    final isGuest = role == 'guest';
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display event cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              event.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/badminton_tournament.jpg', fit: BoxFit.cover);
              },
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
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EventRegistrationForm(
                                        eventTitle: event.title,
                                        onRegistered: () {},
                                      ),
                                ),
                              );
                            },
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
