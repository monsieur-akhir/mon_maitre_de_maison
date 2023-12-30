import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllAnnouncementsPage extends StatefulWidget {
  @override
  _AllAnnouncementsPageState createState() => _AllAnnouncementsPageState();
}

class _AllAnnouncementsPageState extends State<AllAnnouncementsPage> {
  TextEditingController _searchController = TextEditingController();
  String _selectedLevel = '';
  String _selectedCommune = '';
  String _selectedMatiere = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Annonces Disponibles'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par niveau, matière ou commune...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _updateAnnouncementsList();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucune annonce trouvée.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var announcement = snapshot.data!.docs[index];
                      return _buildAnnouncementCard(announcement);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _buildQuery() {
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    Query query = FirebaseFirestore.instance.collection('course_announcements');

    if (_selectedLevel.isNotEmpty) {
      query = query.where('level', isEqualTo: _selectedLevel);
    }

    if (_selectedCommune.isNotEmpty) {
      query = query.where('commune', isEqualTo: _selectedCommune);
    }
    if (_selectedCommune.isNotEmpty) {
      query = query.where('selectedSubject', isEqualTo: _selectedMatiere);
    }
    return query.snapshots();
  }

  Widget _buildAnnouncementCard(QueryDocumentSnapshot<Object?> announcement) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(announcement['selectedSubject']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Niveau: ${announcement['level']}'),
            Text('Créneau horaire: ${announcement['selectedTimeSlot']}'),
            Text('Jours disponibles: ${announcement['selectedDays']}'),
            Text('Tarif: ${_buildRateText(announcement)}'),
            FutureBuilder(
              future: _fetchUserData(announcement['userId']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Chargement des informations de l\'utilisateur...');
                } else if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  var userData = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nom: ${userData?['firstName']} ${userData?['lastName']}'),
                      Text('Région: ${userData?['region']}'),
                      Text('Commune: ${userData?['commune']}'),
                    ],
                  );
                } else {
                  return Text('Aucune information utilisateur disponible.');
                }
              },
            ),
          ],
        ),
        onTap: () {
          _showAnnouncementDetailsDialog(announcement);
        },
      ),
    );
  }

  String _buildRateText(QueryDocumentSnapshot<Object?> announcement) {
    return announcement['hourlyRate'] != null
        ? '${announcement['hourlyRate']} Fcfa par heure'
        : '${announcement['monthlyRate']} Fcfa par mois';
  }

  void _showAnnouncementDetailsDialog(QueryDocumentSnapshot<Object?> announcement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails de l\'annonce'),
          content: Column(
            children: [

              Text('Niveau: ${announcement['level']}'),
              Text('Matière: ${announcement['selectedSubject']}'),
              Text('Créneau horaire: ${announcement['selectedTimeSlot']}'),
              Text('Jours disponibles: ${announcement['selectedDays']}'),
              Text('Tarif: ${_buildRateText(announcement)}'),
              FutureBuilder(
                future: _fetchUserData(announcement['userId']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Chargement des informations de l\'utilisateur...');
                  } else if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    var userData = snapshot.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text('Nom: ${userData?['firstName']} ${userData?['lastName']}'),
                        Text('Région: ${userData?['region']}'),
                        Text('Commune: ${userData?['commune']}'),
                      ],
                    );
                  } else {
                    return Text('Aucune information utilisateur disponible.');
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer la boîte de dialogue
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    var userData = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userData.data() as Map<String, dynamic>;
  }

  void _updateAnnouncementsList() {
    setState(() {
      if(_selectedLevel != ''){
        _selectedLevel = _searchController.text;
      }
      if(_selectedCommune != ''){
        _selectedCommune = _searchController.text;
      }
      if(_selectedMatiere != ''){
        _selectedMatiere = _searchController.text;
      }


    });
  }
}
