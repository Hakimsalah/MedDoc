import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ Format date sans locale
  String formatDate(DateTime date) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day. toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String formatTime(DateTime date) {
    return '${date.hour. toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String formatDateFull(DateTime date) {
    const months = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF03BE96),
        elevation: 0,
        title:  Text(
          'Mes Rendez-vous',
          style: GoogleFonts.inter(
            fontSize: 20. sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller:  _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          isScrollable: true,
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'Confirmés'),
            Tab(text: 'Terminés'),
            Tab(text:  'Annulés'),
          ],
        ),
      ),
      body: TabBarView(
        controller:  _tabController,
        children:  [
          _buildAppointmentList('pending'),
          _buildAppointmentList('confirmed'),
          _buildAppointmentList('completed'),
          _buildAppointmentList('rejected'),
        ],
      ),
      floatingActionButton: FloatingActionButton. extended(
        onPressed: _showCreateAppointmentDialog,
        backgroundColor: const Color(0xFF03BE96),
        icon: const Icon(Icons.add),
        label: Text('Nouveau RDV', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ✅ 1. Lire les rendez-vous du docteur actuel filtré par doctorId
  Widget _buildAppointmentList(String status) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAppointmentsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (! snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 80, color: Colors.grey[300]),
                SizedBox(height: 2. h),
                Text('Aucun rendez-vous', style: GoogleFonts.inter(fontSize: 18. sp, color: Colors.grey[600])),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: EdgeInsets.all(3.w),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              return _buildAppointmentCard(data, data['id'], status);
            },
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getAppointmentsByStatus(String status) async {
    final snapshot = await FirebaseFirestore. instance
        .collection('appointments')
        .where('doctorId', isEqualTo: user?. uid)
        .where('status', isEqualTo: status)
        .get();

    var docs = snapshot.docs. toList();

    docs.sort((a, b) {
      final aData = a.data();
      final bData = b. data();

      if (aData['date'] != null && bData['date'] != null) {
        final aDate = (aData['date'] as Timestamp).toDate();
        final bDate = (bData['date'] as Timestamp).toDate();
        return (status == 'completed' || status == 'rejected') ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
      }
      return 0;
    });

    return docs. map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Widget _buildAppointmentCard(Map<String, dynamic> data, String docId, String status) {
    final date = (data['date'] as Timestamp).toDate();
    final dateStr = formatDate(date);
    final timeStr = formatTime(date);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'En attente';
        statusIcon = Icons.access_time;
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusText = 'Confirmé';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Terminé';
        statusIcon = Icons. check_circle;
        break;
      case 'rejected': 
        statusColor = Colors.red;
        statusText = 'Annulé';
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Inconnu';
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFF03BE96).withOpacity(0.1),
                          child: Text(
                            (data['patientName'] ??  'P').substring(0, 1).toUpperCase(),
                            style: GoogleFonts.inter(fontSize: 20. sp, fontWeight: FontWeight. bold, color: const Color(0xFF03BE96)),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['patientName'] ?? 'Patient', style: GoogleFonts. inter(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            Text(data['patientEmail'] ?? '', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          SizedBox(width: 1.w),
                          Text(statusText, style: GoogleFonts.inter(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12. sp)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Divider(color: Colors.grey[200]),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                    SizedBox(width: 2.w),
                    Text(dateStr, style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[700])),
                    SizedBox(width: 4.w),
                    Icon(Icons.access_time, size: 18, color: Colors. grey[600]),
                    SizedBox(width: 2.w),
                    Text(timeStr, style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[700])),
                    const Spacer(),
                    // ✅ 2. Bouton modifier l'heure
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: const Color(0xFF03BE96),
                      onPressed:  () => _showEditTimeDialog(data, docId),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Icon(Icons.medical_services, size: 18, color: Colors.grey[600]),
                    SizedBox(width: 2.w),
                    Expanded(child: Text(data['reason'] ?? 'Consultation générale', style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[700]))),
                  ],
                ),
              ],
            ),
          ),
          if (status == 'pending') ...[
            Container(
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton. icon(
                      onPressed:  () => _updateAppointmentStatus(docId, 'confirmed'),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text('Accepter', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF03BE96),
                        foregroundColor: Colors. white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                  SizedBox(width:  2.w),
                  Expanded(
                    child:  OutlinedButton.icon(
                      onPressed: () => _updateAppointmentStatus(docId, 'rejected'),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text('Refuser', style: GoogleFonts. inter(fontWeight: FontWeight. w600)),
                      style:  OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors. red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding:  EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (status == 'confirmed') ...[
            Container(
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: ElevatedButton.icon(
                onPressed: () => _updateAppointmentStatus(docId, 'completed'),
                icon: const Icon(Icons.check_circle, size: 18),
                label: Text('Marquer terminé', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius:  BorderRadius.circular(10)),
                  padding: EdgeInsets. symmetric(vertical: 1.5.h),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ 2. Modifier l'heure
  void _showEditTimeDialog(Map<String, dynamic> data, String docId) {
    final currentDate = (data['date'] as Timestamp).toDate();
    DateTime selectedDate = currentDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(currentDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier l\'heure', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(formatDateFull(selectedDate)),
                  trailing: const Icon(Icons.edit),
                  onTap:  () async {
                    final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime. now().add(const Duration(days: 365)));
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons. edit),
                  onTap:  () async {
                    final picked = await showTimePicker(context: context, initialTime: selectedTime);
                    if (picked != null) setDialogState(() => selectedTime = picked);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler', style: GoogleFonts.inter(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final newDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime. minute);
              await _updateAppointmentTime(docId, newDate);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03BE96)),
            child: Text('Confirmer', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAppointmentTime(String docId, DateTime newDate) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(docId).update({'date':  Timestamp.fromDate(newDate), 'updatedAt': FieldValue.serverTimestamp()});
      if (mounted) {
        ScaffoldMessenger. of(context).showSnackBar(const SnackBar(content: Text('Heure modifiée avec succès'), backgroundColor: Colors.green));
        setState(() {});
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur:  ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  // ✅ 3. Créer un rendez-vous avec un patient existant
  void _showCreateAppointmentDialog() {
    String? selectedPatientId;
    String selectedPatientName = '';
    String selectedPatientEmail = '';
    final reasonCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text('Nouveau rendez-vous', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child:  Column(
                mainAxisSize:  MainAxisSize.min,
                children: [
                  // Sélection patient
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'patient').snapshots(),
                    builder: (context, snapshot) {
                      if (! snapshot.hasData) return const CircularProgressIndicator();

                      List<DropdownMenuItem<String>> patientItems = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(value: doc.id, child: Text(data['name'] ?? 'Patient'));
                      }).toList();

                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Sélectionner un patient', border: OutlineInputBorder(), prefixIcon: Icon(Icons. person)),
                        value: selectedPatientId,
                        items: patientItems,
                        onChanged: (value) {
                          final selectedDoc = snapshot.data!.docs. firstWhere((doc) => doc.id == value);
                          final data = selectedDoc.data() as Map<String, dynamic>;
                          setDialogState(() {
                            selectedPatientId = value;
                            selectedPatientName = data['name'] ?? '';
                            selectedPatientEmail = data['email'] ?? '';
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height:  2.h),
                  ListTile(
                    leading:  const Icon(Icons.calendar_today),
                    title:  Text(formatDateFull(selectedDate)),
                    trailing: const Icon(Icons.edit),
                    onTap:  () async {
                      final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (picked != null) setDialogState(() => selectedDate = picked);
                    },
                  ),
                  ListTile(
                    leading:  const Icon(Icons.access_time),
                    title: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime:  selectedTime);
                      if (picked != null) setDialogState(() => selectedTime = picked);
                    },
                  ),
                  SizedBox(height:  2.h),
                  TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Motif', border: OutlineInputBorder(), prefixIcon: Icon(Icons. medical_services))),
                  SizedBox(height: 2.h),
                  TextField(controller: notesCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes (optionnel)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.note))),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler', style: GoogleFonts.inter(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (selectedPatientId == null || reasonCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.red));
                return;
              }

              final appointmentDate = DateTime(selectedDate.year, selectedDate.month, selectedDate. day, selectedTime.hour, selectedTime.minute);
              await _createAppointment(selectedPatientId!, selectedPatientName, selectedPatientEmail, appointmentDate, reasonCtrl.text, notesCtrl.text);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton. styleFrom(backgroundColor: const Color(0xFF03BE96)),
            child: Text('Créer', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _createAppointment(String patientId, String patientName, String patientEmail, DateTime date, String reason, String notes) async {
    try {
      final doctorDoc = await FirebaseFirestore.instance.collection('users').doc(user?. uid).get();
      final doctorName = doctorDoc.data()?['name'] ?? 'Doctor';

      await FirebaseFirestore.instance.collection('appointments').add({
        'doctorId': user?.uid,
        'doctorName': 'Dr. $doctorName',
        'patientId': patientId,
        'patientName': patientName,
        'patientEmail': patientEmail,
        'date': Timestamp.fromDate(date),
        'reason': reason,
        'notes': notes,
        'status': 'confirmed',
        'createdAt':  FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger. of(context).showSnackBar(const SnackBar(content: Text('Rendez-vous créé! '), backgroundColor: Colors.green));
        setState(() {});
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur:  ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  Future<void> _updateAppointmentStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore. instance.collection('appointments').doc(docId).update({'status': newStatus, 'updatedAt':  FieldValue.serverTimestamp()});

      if (mounted) {
        String message = newStatus == 'confirmed' ?  'Rendez-vous accepté' : newStatus == 'rejected' ? 'Rendez-vous refusé' : 'Rendez-vous terminé';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
        setState(() {});
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:  Text('Erreur: ${e.toString()}'), backgroundColor: Colors. red));
    }
  }
}