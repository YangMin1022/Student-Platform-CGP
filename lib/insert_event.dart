import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('events').add({
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
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
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
