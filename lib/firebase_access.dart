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
}


