import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class CourseAnnouncementService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveCourseAnnouncement({
    required BuildContext context,
    required String? selectedLevel,
    required double? hourlyRate,
    required double? monthlyRate,
    required List<String> selectedDays,
    required String? selectedTimeSlot,
    required String? selectedRateUnit,
    required String? selectedSubject,
  }) async {
    try {
      // Vérifiez d'abord si l'utilisateur est connecté
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        // Gérer l'absence d'utilisateur connecté
        throw Exception("Utilisateur non connecté");
      }

      // Créez une référence à la collection des annonces de cours dans Firestore
      CollectionReference courseAnnouncements =
          FirebaseFirestore.instance.collection('course_announcements');

      // Enregistrez les données de l'annonce de cours dans Firebase
      await courseAnnouncements.add({
        'level': selectedLevel,
        'hourlyRate': hourlyRate,
        'monthlyRate': monthlyRate,
        'selectedDays': selectedDays,
        'selectedTimeSlot': selectedTimeSlot,
        'selectedRateUnit': selectedRateUnit,
        'selectedSubject': selectedSubject,
        'userId':
            currentUser.uid, // Associez l'annonce à l'utilisateur connecté
        'timestamp': FieldValue.serverTimestamp(), // Ajoutez un horodatage
      });

      print('Niveau: $selectedLevel');
      print('Matière, $selectedSubject');
      print('Tarif horaire: $hourlyRate');
      print('Jours disponibles: $selectedDays');
      print('Créneau horaire: $selectedTimeSlot');

      showSuccesDialog(context, 'Annonce de cours enregistrée avec succès!');
      print('Annonce de cours enregistrée avec succès!');
    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'annonce de cours: $e');
      showErrorDialog(context, '$e' ?? 'Erreur de connexion');
      // Gérez les erreurs selon vos besoins
    }
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur de Création'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showSuccesDialog(BuildContext context, String succesMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message de Création'),
          content: Text(succesMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/annonces');
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
