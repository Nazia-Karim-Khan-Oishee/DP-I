import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/patientInterface/viewAppointment/appointmentList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../components/virtualConsultation/call.dart';
import '../../../models/AppointmentModel.dart';
class ViewAppointmentDetailsPage extends StatefulWidget {
  final Appointment appointment;
  final String ID;

  ViewAppointmentDetailsPage({super.key, required this.appointment,
  required this.ID});


  @override
  State<ViewAppointmentDetailsPage> createState() => _ViewAppointmentDetailsPageState();
}

class _ViewAppointmentDetailsPageState extends State<ViewAppointmentDetailsPage> {

  late  Map<String, dynamic>? doctorData ;
  late  Map<String, dynamic>? patientData ;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final  userDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
  Future username = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) => value.data()!['name']);
  String userName = '';

  String generateCallID() {
    String callID = '';
    callID = widget.appointment.doctorId;
    return callID;
  }

  Future<void> fetchDocInfo()
  async {
    doctorData = null;
    final doctorReference = FirebaseFirestore.instance.collection('doctors').doc(widget.appointment.doctorId);
    final doctorSnapshot = await doctorReference.get();

    if (doctorSnapshot.exists) {
      setState(() {

       doctorData = doctorSnapshot.data() as Map<String, dynamic>;
      });

    }
  }


  Future<void> fetchPatientInfo()
  async {
    patientData = null;
    final patientReference = FirebaseFirestore.instance.collection('patients').
    doc(FirebaseAuth.instance.currentUser?.uid ?? ''
    );
    final patientSnapshot = await patientReference.get();

    if (patientSnapshot.exists) {
      setState(() {

        patientData = patientSnapshot.data() as Map<String, dynamic>;
      });

    }
  }


  @override
  void initState()
  {
    fetchDocInfo();
    fetchPatientInfo();
    setState(() {
      username.then((value) => userName = value.toString());
    });

  }
  Appointment get appointment => widget.appointment;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // colors: [Colors.white70, Colors.blue.shade200],
            colors: [Colors.white70, Colors.blue.shade200],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Patient Name: ${appointment.patientName}'),
              ),
              ListTile(
                leading: Icon(Icons.medical_services),
                title: Text('Health Issue: ${appointment.issue.isNotEmpty ? appointment.issue :  'No issue specified'}'),

              ),
              ListTile(
                leading: Icon(Icons.health_and_safety),
                title: Text('Pre existing medical conditions: ${patientData?['preExistingConditions']?.join(', ')}'),

              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Doctor Name: ${doctorData?['name']}'),
              ),
              ListTile(
                leading: Icon(Icons.timer),
                title: Text('Estimated Time: ${appointment.startTime} - ${appointment.endTime}'),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Date: ${appointment.date}'),
              ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Payment Status: ${appointment.isPaid ? 'Paid' : 'Not Paid'}'),
            trailing: !appointment.isPaid
                ? ElevatedButton(
              onPressed: () {
                updatePayment();
                Fluttertoast.showToast(
                  msg: 'Payment Status updated',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.blue,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppointmentListPage()),
                );
              },
              child: Text('Pay Now'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue.shade900  ,
              ),
            )
                : null,
          ),
          SizedBox(height: 16),
              if (appointment.sessionType == 'Online')
                Center(
                  child: ElevatedButton(
                    onPressed: () {

                      Navigator.push(context, MaterialPageRoute(builder: (context) => CallPage(callID: generateCallID() , userID: userId , userName: userName)));

                    },
                    child: Text('Join Session'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue.shade900  ,
                    )
                  ),
                ),
              if (appointment.sessionType == 'Offline')
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('Chamber Address : ${doctorData?['chamberAddress']}'),
                ),

            ],
          ),
        ),
      ),
    );
  }

  Future<void> updatePayment() async {
    try {
      final appointmentsCollection = FirebaseFirestore.instance.collection('Appointments');

      // Reference to the specific appointment document using its ID
      final appointmentDoc = appointmentsCollection.doc(widget.ID);

      // Update the payment status
      await appointmentDoc.update({
        'isPaid': !widget.appointment.isPaid,
      });

      print('Payment status updated for appointment');
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }
}
