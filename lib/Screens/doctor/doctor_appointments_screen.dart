import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = FirebaseAuth.instance. currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length:  4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors. grey[50],
      appBar: AppBar(
        backgroundColor:  const Color(0xFF03BE96),
        elevation: 0,
        title: Text(
          'Mes Rendez-vous',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors. white,
          indicatorWeight:  3,
          labelColor:  Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          isScrollable: true,
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'Confirmés'),
            Tab(text: 'Terminés'),
            Tab(text: 'Annulés'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentList('pending'),
          _buildAppointmentList('confirmed'),
          _buildAppointmentList('completed'),
          _buildAppointmentList('rejected'),
        ],
      ),
      floatingActionButton: FloatingActionButton. extended(
        onPressed: () {
          // TODO: Add create appointment functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fonctionnalité à venir:  Créer un rendez-vous'),
              backgroundColor: Colors.blue,
            ),
          );
        },
        backgroundColor: const Color(0xFF03BE96),
        icon: const Icon(Icons.add),
        label: Text(
          'Nouveau RDV',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ✅ FIXED: Use FutureBuilder instead of StreamBuilder to avoid Firestore errors
  Widget _buildAppointmentList(String status) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAppointmentsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 80, color: Colors.grey[300]),
                SizedBox(height: 2.h),
                Text(
                  'Aucun rendez-vous',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {}); // Refresh the FutureBuilder
          },
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

  // ✅ NEW: Get appointments by status as Future (no compound queries)
  Future<List<Map<String, dynamic>>> _getAppointmentsByStatus(String status) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo:  user?.uid)
        .where('status', isEqualTo:  status)
        .get();

    var docs = snapshot.docs. toList();

    // Sort by date in memory
    docs.sort((a, b) {
      final aData = a.data();
      final bData = b. data();
      
      if (aData['date'] != null && bData['date'] != null) {
        final aDate = (aData['date'] as Timestamp).toDate();
        final bDate = (bData['date'] as Timestamp).toDate();
        
        // Descending for completed/rejected, ascending for others
        if (status == 'completed' || status == 'rejected') {
          return bDate.compareTo(aDate);
        } else {
          return aDate.compareTo(bDate);
        }
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
    final dateStr = DateFormat('dd MMM yyyy', 'fr_FR').format(date);
    final timeStr = DateFormat('HH:mm').format(date);

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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
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
                            (data['patientName'] ?? 'P').substring(0, 1).toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 20. sp,
                              fontWeight:  FontWeight.bold,
                              color: const Color(0xFF03BE96),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['patientName'] ?? 'Patient',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight. bold,
                              ),
                            ),
                            Text(
                              data['patientEmail'] ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color:  statusColor. withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          SizedBox(width: 1.w),
                          Text(
                            statusText,
                            style: GoogleFonts. inter(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12. sp,
                            ),
                          ),
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
                    Text(
                      dateStr,
                      style: GoogleFonts. inter(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                    SizedBox(width: 2.w),
                    Text(
                      timeStr,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Icon(Icons.medical_services, size: 18, color: Colors.grey[600]),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        data['reason'] ?? 'Consultation générale',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                if (data['notes'] != null && data['notes']. toString().isNotEmpty) ...[
                  SizedBox(height: 1.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 18, color:  Colors.grey[600]),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          data['notes'],
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (status == 'pending') ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius:  const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight:  Radius.circular(15),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton. icon(
                      onPressed:  () => _updateAppointmentStatus(docId, 'confirmed'),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(
                        'Accepter',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF03BE96),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                  SizedBox(width:  2.w),
                  Expanded(
                    child:  OutlinedButton.icon(
                      onPressed: () => _updateAppointmentStatus(docId, 'rejected'),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(
                        'Refuser',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton. styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors. red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (status == 'confirmed') ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius. only(
                  bottomLeft:  Radius.circular(15),
                  bottomRight: Radius. circular(15),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Expanded(
                    child:  ElevatedButton.icon(
                      onPressed: () => _updateAppointmentStatus(docId, 'completed'),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: Text(
                        'Marquer terminé',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style:  ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  IconButton(
                    onPressed:  () {
                      _showAppointmentDetails(data, docId);
                    },
                    icon: const Icon(Icons.edit),
                    color: const Color(0xFF03BE96),
                    iconSize: 28,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ Show appointment details with option to edit
  void _showAppointmentDetails(Map<String, dynamic> data, String docId) {
    showModalBottomSheet(
      context:  context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final date = (data['date'] as Timestamp).toDate();
          return SingleChildScrollView(
            controller:  scrollController,
            child:  Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Détails du rendez-vous',
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  _buildDetailRow(Icons.person, 'Patient', data['patientName'] ?? ''),
                  _buildDetailRow(Icons.email, 'Email', data['patientEmail'] ??  ''),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Date',
                    DateFormat('dd MMMM yyyy', 'fr_FR').format(date),
                  ),
                  _buildDetailRow(
                    Icons. access_time,
                    'Heure',
                    DateFormat('HH:mm').format(date),
                  ),
                  _buildDetailRow(
                    Icons.medical_services,
                    'Motif',
                    data['reason'] ?? 'Consultation',
                  ),
                  if (data['notes'] != null && data['notes'].toString().isNotEmpty)
                    _buildDetailRow(Icons.note, 'Notes', data['notes']),
                  SizedBox(height: 3.h),
                  SizedBox(
                    width:  double.infinity,
                    child: ElevatedButton. icon(
                      onPressed:  () {
                        Navigator.pop(context);
                        _showRescheduleDialog(data, docId);
                      },
                      icon: const Icon(Icons.edit_calendar),
                      label: Text(
                        'Reprogrammer',
                        style:  GoogleFonts.inter(
                          fontWeight: FontWeight. w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      style: ElevatedButton. styleFrom(
                        backgroundColor:  const Color(0xFF03BE96),
                        foregroundColor:  Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: const Color(0xFF03BE96).withOpacity(0.1),
              borderRadius: BorderRadius. circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF03BE96), size: 20),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts. inter(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: GoogleFonts. inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Reschedule appointment dialog
  void _showRescheduleDialog(Map<String, dynamic> data, String docId) {
    final currentDate = (data['date'] as Timestamp).toDate();
    DateTime selectedDate = currentDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(currentDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reprogrammer le rendez-vous',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize:  MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    DateFormat('dd MMMM yyyy', 'fr_FR').format(selectedDate),
                    style: GoogleFonts.inter(),
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap:  () async {
                    final picked = await showDatePicker(
                      context:  context,
                      initialDate:  selectedDate,
                      firstDate: DateTime. now(),
                      lastDate:  DateTime. now().add(const Duration(days: 365)),
                      locale: const Locale('fr', 'FR'),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    selectedTime.format(context),
                    style: GoogleFonts.inter(),
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts. inter(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newDate = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
              
              await _rescheduleAppointment(docId, newDate);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03BE96),
            ),
            child: Text(
              'Confirmer',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rescheduleAppointment(String docId, DateTime newDate) async {
    try {
      await FirebaseFirestore.instance
          . collection('appointments')
          .doc(docId)
          .update({
        'date':  Timestamp.fromDate(newDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rendez-vous reprogrammé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur:  ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateAppointmentStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore. instance
          .collection('appointments')
          .doc(docId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue. serverTimestamp(),
      });

      if (mounted) {
        String message;
        Color bgColor;

        switch (newStatus) {
          case 'confirmed':
            message = 'Rendez-vous accepté avec succès';
            bgColor = Colors.green;
            break;
          case 'rejected':
            message = 'Rendez-vous refusé';
            bgColor = Colors.red;
            break;
          case 'completed':
            message = 'Rendez-vous marqué comme terminé';
            bgColor = Colors.green;
            break;
          default:
            message = 'Statut mis à jour';
            bgColor = Colors.blue;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  Text(message),
            backgroundColor:  bgColor,
          ),
        );
        
        setState(() {}); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}