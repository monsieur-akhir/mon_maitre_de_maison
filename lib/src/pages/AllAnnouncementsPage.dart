import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mon_maitre_de_maison/firebase_access.dart';

class AllAnnouncementsPage extends StatefulWidget {
  @override
  _AllAnnouncementsPageState createState() => _AllAnnouncementsPageState();
}

class _AllAnnouncementsPageState extends State<AllAnnouncementsPage> {
  TextEditingController _searchController = TextEditingController();
  String? _selectedLevel ;
  String? _selectedRegion;
  String? _selectedCommune;
  String? _quartier;
  String searchText = '';

  // Listes pour stocker les données des régions et des communes depuis Firestore
  List<String> _regions = [];
  Map<String, List<String>> _communes = {};

  firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> _buildQuery() {
    CollectionReference courseAnnouncementsCollection =
    FirebaseFirestore.instance.collection('course_announcements');

    Query query = courseAnnouncementsCollection;

    // Filtrez par matière (selectedSubject) en utilisant CONTAINS
    String searchText = _searchController.text;
    if (searchText.isNotEmpty) {
      query = query.where('selectedSubject', isEqualTo: searchText);
    }
    // Filtrez par niveau (_selectedLevel) en utilisant CONTAINS
    if (_selectedLevel!=null) {
      query = query.where('level', isEqualTo: _selectedLevel);
    }

    // Retournez la requête Firestore
    return query.snapshots();
  }


  @override
  void initState() {
    super.initState();
    // Chargez les données depuis Firestore au moment de l'initialisation de la page
    loadFirebaseData();
  }

  void loadFirebaseData() async {
    Map<String, List<String>> data =
        await FirebaseAccess.loadRegionsAndCommunes();

    setState(() {
      _regions = data.keys.toList();
      _communes = data;
    });
  }

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barre de recherche et bouton de filtrage
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher par matière...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _updateAnnouncementsList();
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    _showFilterModal(context);
                  },
                  child: Icon(Icons.filter_alt),
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Champ de recherche
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
      ),
    );
  }
  Future<void> _showFilterModal(BuildContext context) async {
    double screenHeight = MediaQuery.of(context).size.height;
    double modalHeight = screenHeight * 0.6;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: modalHeight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDropdown(
                    value: _selectedLevel,
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value!;
                      });
                    },
                    items: ['', 'Primaire', 'Collège', 'Lycée'],
                    labelText: 'Niveau',
                    prefixIcon: Icons.school,
                  ),
                  SizedBox(height: 16.0),

                  _buildDropdown(
                    value: _selectedRegion,
                    onChanged: (value) {
                      setState(() {
                        _selectedRegion = value!;
                        _selectedCommune = null;
                      });
                    },
                    items: _regions,
                    labelText: 'Sélectionnez votre région',
                    prefixIcon: Icons.add_location_alt_outlined,
                  ),
                  SizedBox(height: 16.0),

                  // Dropdown pour la commune
                  if (_selectedRegion != null)
                    _buildDropdown(
                      value: _selectedCommune,
                      onChanged: (value) {
                        setState(() {
                          _selectedCommune = value!;
                        });
                      },
                      items: [''] + _communes[_selectedRegion!]!,
                      labelText: 'Sélectionnez votre commune',
                      prefixIcon: Icons.map_sharp,
                    ),
                  SizedBox(height: 16.0),

                  // Champ de texte pour le quartier
                  if (_selectedCommune != null)
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Quartier',
                        prefixIcon: Icon(Icons.location_city_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _quartier = value;
                        });
                      },
                    ),
                  SizedBox(height: 16.0),

                  ElevatedButton(
                    onPressed: () {
                      _updateAnnouncementsList();
                      Navigator.pop(context); // Ferme la modalité après validation
                    },
                    child: Text('Valider'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementCard(QueryDocumentSnapshot<Object?> announcement) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
        //  _showAnnouncementDetailsDialog(announcement);
        },
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                announcement['selectedSubject'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Couleur du titre
                ),
              ),
              SizedBox(height: 8),
              Text('Niveau: ${announcement['level']}'),
              Text('Tarif: ${_buildRateText(announcement)}'),
              FutureBuilder(
                future: _fetchUserData(announcement['userId']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Chargement des informations de l'utilisateur...");
                  } else if (snapshot.hasError) {
                    return Text("Erreur: ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    var userData = snapshot.data as Map<String, dynamic>?;

                    var userFullName = userData?['firstName'] + ' ' + userData?['lastName'];
                    var userCommune = userData?['commune'] ?? '';
                    var profilePhotoPath = userData?['profilePhotoPath'] ?? '';

                    return ListTile(
                      title: Text(
                        userFullName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userCommune),
                        ],
                      ),
                      leading: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(profilePhotoPath),
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (userData != null) {
                                _toggleFavorite(announcement.id);
                              }
                            },
                            child: Icon(
                              Icons.favorite,
                              color: _isFavorite(userData, announcement.id) ? Colors.red : Colors.grey,
                            ),
                          ),

                          SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              // Logique pour voir plus
                              _showAnnouncementDetailsDialog(announcement);
                            },
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.green, // Couleur du bouton Voir plus
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text("Aucune information utilisateur disponible.");
                  }
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
  String _buildRateText(QueryDocumentSnapshot<Object?> announcement) {
    return announcement['hourlyRate'] != null
        ? '${announcement['hourlyRate']} Fcfa par heure'
        : '${announcement['monthlyRate']} Fcfa par mois';
  }

  void _showAnnouncementDetailsDialog(
      QueryDocumentSnapshot<Object?> announcement) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails de l\'annonce',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 16),
                _buildDetailRow(
                  Icons.school,
                  'Niveau',
                  announcement['level'],
                ),
                _buildDetailRow(
                  Icons.subject,
                  'Matière',
                  announcement['selectedSubject'],
                ),
                _buildDetailRow(
                  Icons.access_time,
                  'Créneau horaire',
                  announcement['selectedTimeSlot'],
                ),
                _buildDetailRow(
                  Icons.event,
                  'Jours disponibles',
                  announcement['selectedDays'],
                ),
                _buildDetailRow(
                  Icons.attach_money,
                  'Tarif',
                  _buildRateText(announcement),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FutureBuilder(
                        future: _fetchUserData(announcement['userId']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              'Chargement des informations de l\'utilisateur...',
                              style: TextStyle(fontSize: 16),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Erreur: ${snapshot.error}',
                              style: TextStyle(fontSize: 16),
                            );
                          } else if (snapshot.hasData) {
                            var userData = snapshot.data;

                            // Affichage des informations utilisateur avec le style de Jobs_Models
                            return ListTile(
                              title: Text(
                                userData?['firstName'] + ' ' + userData?['lastName'],
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userData?['commune'] ?? '',
                                    style: TextStyle(fontSize: 15, color: Colors.grey),
                                  ),
                                  // Ajoutez d'autres informations utilisateur si nécessaire
                                ],

                              ),

                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    userData?['profilePhotoPath'] ?? '',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Text(
                              'Aucune information utilisateur disponible.',
                              style: TextStyle(fontSize: 16),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Logique du deuxième bouton
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepPurple,
                        onPrimary: Colors.white, // Couleur du texte
                      ),
                      icon: Icon(Icons.phone_rounded),
                      label: Text(
                        'Contacter',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),



                  ],

                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _rateUser(announcement['userId']);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.yellow,
                    onPrimary: Colors.white,
                  ),
                  icon: Icon(Icons.star),
                  label: Text(
                    'Noter',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _rateUser(String ratedUserId) async {
    double? rating = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Noter cet utilisateur'),
          content: Column(
            children: [
              Text('Choisissez une note de 1 à 5'),
              SizedBox(height: 16),
              RatingBar.builder(
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  Navigator.pop(context, rating);
                },
              ),
            ],
          ),
        );
      },
    );

    if (rating != null) {
      await FirebaseAccess.rateUser(FirebaseAuth.instance.currentUser?.uid ?? '', ratedUserId, rating);
      setState(() {});
    }
  }

  Widget _buildDetailRow(IconData icon, String label, dynamic value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.deepPurple,
          size: 20,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              // Convertir une liste en chaîne
              Text(
                value is List ? value.join(', ') : value.toString(),
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    var userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userData.data() as Map<String, dynamic>;
  }

  void _updateAnnouncementsList() {
    setState(() {
      // Appliquez la recherche principalement sur la matière
      _searchController.text = _searchController.text.trim();
    });
  }

  Widget _buildDropdown({
    required String? value,
    required Function(String?) onChanged,
    required List<String> items,
    required String labelText,
    required IconData prefixIcon,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }


  void _toggleFavorite(String announcementId) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    Map<String, dynamic> userData = await _fetchUserData(userId);

    List<String> favoriteAnnouncements = List<String>.from(userData['favoriteAnnouncements'] ?? []);

    if (favoriteAnnouncements.contains(announcementId)) {
      // Retirer des favoris
      favoriteAnnouncements.remove(announcementId);
    } else {
      // Ajouter aux favoris
      favoriteAnnouncements.add(announcementId);
    }

    // Mettre à jour la liste des favoris dans Firestore pour l'utilisateur
    await FirebaseAccess.updateUserFavoriteAnnouncements(userId, favoriteAnnouncements);

    // Actualiser l'interface utilisateur
    setState(() {
      userData['favoriteAnnouncements'] = favoriteAnnouncements;
    });
  }

  bool _isFavorite(Map<String, dynamic>? userData, String announcementId) {
    return userData != null &&
        userData['favoriteAnnouncements'] is List<String> &&
        userData['favoriteAnnouncements'].contains(announcementId);
  }







}
