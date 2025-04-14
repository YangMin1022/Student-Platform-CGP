import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'event_details_page.dart';
import 'event_registration_form.dart';
import 'clubs_page.dart';

// Event model class (optional: you can work directly with Map<String, dynamic>)
class Event {
  final String title;
  final String date;
  final String time;
  final String organizer;
  final String location;
  final String imageUrl;
  final String registrationUrl;
  final String description;
  final String eventFee;
  final String eventTransportation;
  final String eventCategory;
  final String googleFormLink;
  final String numParticipant;

  Event({
    required this.title,
    required this.date,
    required this.time,
    required this.organizer,
    required this.location,
    required this.imageUrl,
    required this.registrationUrl,
    required this.description,
    required this.eventFee,
    required this.eventTransportation,
    required this.eventCategory,
    required this.googleFormLink,
    required this.numParticipant,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Event(
      title: data['eventName'] ?? 'No Title',
      date: data['eventDate'] ?? 'No Date',
      time: data['eventTime'] ?? '',
      organizer: data['eventOrganizer'] ?? '',
      location: data['eventVenue'] ?? '',
      imageUrl: data['eventCoverPic'] ?? '',
      registrationUrl: data['googleFormLink'] ?? '',
      description: data['eventDescription'] ?? '',
      eventFee: data['eventFee'] ?? 'N/A',
      eventTransportation: data['eventTransportation'] ?? 'N/A',
      eventCategory: data['eventCategory'] ?? 'N/A',
      googleFormLink: data['googleFormLink'] ?? 'N/A',
      numParticipant: data['numParticipants'] ?? 'N/A',
    );
  }
}

class EventsPage extends StatefulWidget {
  final bool isAdmin;
  const EventsPage({super.key, required this.isAdmin});

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
              stream: FirebaseFirestore.instance.collection('events').snapshots(),
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
                    return EventCard(event: event);
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
                  MaterialPageRoute(builder: (context) => ClubsPage(isAdmin: widget.isAdmin)),
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

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
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
                            builder: (context) => EventDetailsPage(event: event),
                          ),
                        );
                      },
                      child: const Text("More Info"),
                    ),
                    // Register Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventRegistrationForm(
                              eventTitle: event.title,
                              onRegistered: () {
                                // Optionally update registration status
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text("Register"),
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
