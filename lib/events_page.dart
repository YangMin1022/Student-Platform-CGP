import 'package:flutter/material.dart';
import 'package:flutter_application_1/event_registration_form.dart';
import 'package:flutter_application_1/clubs_page.dart'; // Import the new page

class Event {
  final String title;
  final String date;
  final String time;
  final String organizer;
  final String location;
  final String imageUrl;
  final String registrationUrl;
  final String description;
  final List<Detail> details;

  Event({
    required this.title,
    required this.date,
    required this.time,
    required this.organizer,
    required this.location,
    required this.imageUrl,
    required this.registrationUrl,
    required this.description,
    required this.details,
  });
}

class Detail {
  final IconData icon;
  final String text;

  Detail({required this.icon, required this.text});
}

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Event> events = [
    Event(
      title: "Badminton Tournament",
      date: "Saturday, 25 Jan 2025",
      time: "8am - 5pm",
      organizer: "Sport Club",
      location: "Dewan MPKK Bandar Cassia Batu Kawan",
      imageUrl: "assets/images/badminton_tournament.jpg",
      registrationUrl: "https://example.com/badminton-register",
      description:
          "Join us for an exciting and action-packed Badminton Tournament!",
      details: [
        Detail(icon: Icons.calendar_today, text: "Saturday, 25 Jan 2025"),
        Detail(icon: Icons.location_on, text: "Dewan MPKK, Batu Kawan"),
        Detail(icon: Icons.groups, text: "Singles & Doubles"),
        Detail(icon: Icons.monetization_on, text: "RM 5/Participant"),
      ],
    ),
    Event(
      title: "Tree Planting Event",
      date: "Friday, 31 Jan 2025",
      time: "8am - 1pm",
      organizer: "Environmental Club",
      location: "Green Park, Penang",
      imageUrl: "assets/images/tree_planting_event.jpg",
      registrationUrl: "https://example.com/tree-planting-register",
      description: "Help us make Penang greener! Join our tree planting event.",
      details: [
        Detail(icon: Icons.calendar_today, text: "Friday, 31 Jan 2025"),
        Detail(icon: Icons.location_on, text: "Green Park, Penang"),
        Detail(icon: Icons.eco, text: "Bring your own gloves"),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upcoming Events")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventCard(event: events[index]);
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
                  MaterialPageRoute(builder: (context) => ClubsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 15), // Adjust button height
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              event.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/placeholder.jpg',
                    fit: BoxFit.cover);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text("${event.date} @ ${event.time}",
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 5),
                Text("Organized by: ${event.organizer}",
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 16),
                    const SizedBox(width: 5),
                    Text(event.location,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailsPage(event: event),
                          ),
                        );
                      },
                      child: const Text("More Info"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventRegistrationForm(
                              eventTitle: event.title,
                              onRegistered: () {},
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

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  event.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/images/placeholder.jpg',
                        fit: BoxFit.cover);
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(event.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("${event.date} @ ${event.time}",
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 5),
              Text("Organized by: ${event.organizer}",
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 16),
                  const SizedBox(width: 5),
                  Text(event.location,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 10),
              Text(event.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              const Divider(thickness: 1),
              const SizedBox(height: 10),
              for (var detail in event.details)
                Row(
                  children: [
                    Icon(detail.icon, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text(detail.text),
                  ],
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
