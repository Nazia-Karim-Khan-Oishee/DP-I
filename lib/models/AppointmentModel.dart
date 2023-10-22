class Appointment {
  final String patientId;
  final String patientName;
  final bool isPaid;
  final String issue;
  final String doctorId;
  final String date;
  final String startTime;
  final String endTime;
  final String sessionType;


  Appointment({
    required this.patientId,
    required this.patientName,
    required this.isPaid,
    required this.issue,
    required this.doctorId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.sessionType,
  });
}