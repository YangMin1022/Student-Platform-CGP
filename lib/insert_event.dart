import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InsertEventPage extends StatefulWidget {
  const InsertEventPage({Key? key}) : super(key: key);

  @override
  State<InsertEventPage> createState() => _InsertEventPageState();
}

class _InsertEventPageState extends State<InsertEventPage> {
  // Controllers for text fields
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventOrganizerController = TextEditingController();
  final TextEditingController _eventVenueController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  final TextEditingController _eventCategoryController = TextEditingController();
  final TextEditingController _eventFeeController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _eventTransportationController = TextEditingController();
  final TextEditingController _numParticipantsController = TextEditingController();
  final TextEditingController _eventCoverPicController = TextEditingController();
  final TextEditingController _googleFormLinkController = TextEditingController();

   // Dropdown for club selection
  String? _selectedClubId;
  String? _selectedClubName;
  List<Map<String, dynamic>> _clubs = [];

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchClubs();
  }

  // Fetch clubs from Firestore
  Future<void> _fetchClubs() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').get();
    setState(() {
      _clubs = snapshot.docs.map((doc) {
        Map data = doc.data() as Map<String, dynamic>;
        return {
          'clubId': doc.id,
          'clubName': data['clubName'] ?? 'Unnamed Club',
          'presidentEmail': data['presidentEmail'] ?? '',
        };
      }).toList();
    });
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate() || _selectedClubId == null) return;

    // Get current user's email
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User is not signed in.")),
      );
      return;
    }
    String currentUserEmail = currentUser.email ?? '';

    // Retrieve selected club document to check president email.
    DocumentSnapshot clubDoc = await FirebaseFirestore.instance
        .collection('clubs')
        .doc(_selectedClubId)
        .get();
    if (!clubDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected club not found.")),
      );
      return;
    }
    String clubPresidentEmail = clubDoc.get('presidentEmail');

    // For a non-admin user, the current user's email must match the club president's email.
    // (For simplicity, this example does not include an admin override flag.)
    if (currentUserEmail.toLowerCase() != clubPresidentEmail.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only the club president can add an event for this club.")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Insert the event into a subcollection "events" under the selected club.
      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(_selectedClubId)
          .collection('events')
          .add({
        'eventName': _eventNameController.text.trim(),
        'eventOrganizer': _eventOrganizerController.text.trim(),
        'eventVenue': _eventVenueController.text.trim(),
        'eventDate': _eventDateController.text.trim(),
        'eventTime': _eventTimeController.text.trim(),
        'eventCategory': _eventCategoryController.text.trim(),
        'eventFee': _eventFeeController.text.trim(),
        'eventDescription': _eventDescriptionController.text.trim(),
        'eventTransportation': _eventTransportationController.text.trim(),
        'numParticipants': _numParticipantsController.text.trim(),
        'eventCoverPic': _eventCoverPicController.text.trim(),
        'googleFormLink': _googleFormLinkController.text.trim(),
        'createdAt': Timestamp.now(), // Track creation time
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event added successfully!')),
      );
      // Clear all fields after successful submission
      _eventNameController.clear();
      _eventOrganizerController.clear();
      _eventVenueController.clear();
      _eventDateController.clear();
      _eventTimeController.clear();
      _eventCategoryController.clear();
      _eventFeeController.clear();
      _eventDescriptionController.clear();
      _eventTransportationController.clear();
      _numParticipantsController.clear();
      _eventCoverPicController.clear();
      _googleFormLinkController.clear();
       setState(() {
        _selectedClubId = null;
        _selectedClubName = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add event: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

   Widget _buildClubDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Select Club",
        border: OutlineInputBorder(),
      ),
      value: _selectedClubId,
      items: _clubs.map((club) {
        return DropdownMenuItem<String>(
          value: club['clubId'],
          child: Text(club['clubName']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedClubId = value;
          _selectedClubName = _clubs.firstWhere((club) => club['clubId'] == value)['clubName'];
        });
      },
      validator: (value) => value == null ? "Please select a club" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            _buildClubDropdown(),
            const SizedBox(height: 20),
            _buildTextField('Event Name', _eventNameController),
            _buildTextField('Event Organizer', _eventOrganizerController),
            _buildTextField('Event Venue', _eventVenueController),
            _buildTextField('Event Date', _eventDateController),
            _buildTextField('Event Time', _eventTimeController),
            _buildTextField('Event Category', _eventCategoryController),
            _buildTextField('Event Fee', _eventFeeController),
            _buildTextField('Event Description', _eventDescriptionController),
            _buildTextField('Transportation', _eventTransportationController),
            _buildTextField('Number of Participants', _numParticipantsController, isNumeric: true),
            _buildTextField('Event Cover Picture (URL)', _eventCoverPicController),
            _buildTextField('Google Form Link', _googleFormLinkController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitEvent,
              child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric 
          ? const TextInputType.numberWithOptions(signed: false, decimal: false)
          : TextInputType.text,
        // ONLY allow digits when isNumeric:
        inputFormatters: isNumeric
          ? <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ]
          : null,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (isNumeric && int.tryParse(value) == null) {
            return '$label must be a number';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
