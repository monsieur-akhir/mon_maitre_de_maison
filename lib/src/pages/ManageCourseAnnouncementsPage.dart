import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageCourseAnnouncementsPage extends StatefulWidget {
  @override
  _ManageCourseAnnouncementsPageState createState() => _ManageCourseAnnouncementsPageState();
}

class _ManageCourseAnnouncementsPageState extends State<ManageCourseAnnouncementsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _courseAnnouncements = FirebaseFirestore.instance.collection('course_announcements');

  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes annonces de cours'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/annonces');
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _courseAnnouncements.where('userId', isEqualTo: _currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Aucune annonce de cours trouvée.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var announcement = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(announcement['level']),
                  subtitle: Text(announcement['selectedSubject']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(announcement.id);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_red_eye_sharp),
                        onPressed: () {
                          _showEditDialog(announcement);
                        },

                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteAnnouncement(String announcementId) async {
    try {
      await _courseAnnouncements.doc(announcementId).delete();
      print('Annonce de cours supprimée avec succès!');
    } catch (e) {
      print('Erreur lors de la suppression de l\'annonce de cours: $e');
    }
  }

  void _showDeleteConfirmationDialog(String announcementId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer cette annonce de cours?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer la boîte de dialogue
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _deleteAnnouncement(announcementId);
                Navigator.pop(context); // Fermer la boîte de dialogue après la suppression
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(QueryDocumentSnapshot<Object?> announcement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détail sur l\'annonce cours', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Niveau: ${announcement['level']}', style: TextStyle(fontSize: 16)),
              Text('Matière: ${announcement['selectedSubject']}', style: TextStyle(fontSize: 16)),
              Text('Créneau horaire: ${announcement['selectedTimeSlot']}', style: TextStyle(fontSize: 16)),
              Text('Tarif: ${announcement['hourlyRate'] != null ? '${announcement['hourlyRate']} Fcfa / heure' : '${announcement['monthlyRate']} Fcfa / mois'}', style: TextStyle(fontSize: 16)),
              Text('Jour disponible: ${announcement['selectedDays']}', style: TextStyle(fontSize: 16)),

              // Ajoutez d'autres champs ici en fonction de vos données
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer la boîte de dialogue
              },
              child: Text('Fermer', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                // Ajoutez ici la logique pour la modification de l'annonce
                // Utilisez les données de 'announcement' pour effectuer les modifications nécessaires
                Navigator.pop(context); // Fermer la boîte de dialogue après la modification
              },
              child: Text('Modifier', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

}