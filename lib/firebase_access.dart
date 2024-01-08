import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAccess {
  static Future<Map<String, List<String>>> loadRegionsAndCommunes() async {
    Map<String, List<String>> data = {};

    CollectionReference regionsCollection =
    FirebaseFirestore.instance.collection('regions');

    QuerySnapshot regionsSnapshot = await regionsCollection.get();

    regionsSnapshot.docs.forEach((doc) {
      String region = doc.id; // Utilisez doc.id pour obtenir le nom de la région
      List<String> communes = (doc['communes'] as List<dynamic>)
          .map((communeData) => communeData.toString())
          .toList();

      data[region] = communes;
    });



    return data;
  }

// Ajoutez d'autres fonctions Firebase ici si nécessaire

  static Future<void> addToFavorites(String userId, String announcementId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'favorites.$announcementId': true,
    });
  }

  static Future<void> updateUserFavorites(String userId, List<String> favorites) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'favorites': favorites,
    });
  }


  static Future<void> rateUser(String userId, String ratedUserId, double rating) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'ratings.$ratedUserId': rating,
    });
  }

  static Future<void> removeFromFavorites(String userId, String announcementId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'favorites.$announcementId': FieldValue.delete(),
    });
  }
  static Future<void> updateUserFavoriteAnnouncements(String userId, List<String> favoriteAnnouncements) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'favoriteAnnouncements': favoriteAnnouncements,
      });
    } catch (error) {
      print('Erreur lors de la mise à jour des favoris de l\'utilisateur : $error');
      // Gérer l'erreur selon vos besoins
    }
  }

}


