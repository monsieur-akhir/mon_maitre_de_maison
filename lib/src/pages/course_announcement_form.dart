import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mon_maitre_de_maison/src/controller/CourseAnnouncementService.dart';

final CourseAnnouncementService _courseAnnouncementService = CourseAnnouncementService();
class CourseAnnouncementForm extends StatefulWidget {
  @override
  _CourseAnnouncementFormState createState() => _CourseAnnouncementFormState();
}

class _CourseAnnouncementFormState extends State<CourseAnnouncementForm> {

//  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedLevel;
  double? _hourlyRate;
  double? _monthlyRate;
  List<String> _selectedDays = [];
  String? _selectedTimeSlot;
  String? _selectedRateUnit;
  String? _selectedSubject;
  List<String> _subjects = [];


  List<String> _levels = ['Collège', 'Lycée', 'Primaire','Université']; // Ajoutez vos niveaux ici
  List<String> _timeSlots = ['Matin', 'Après-midi', 'Soir']; // Créez vos créneaux horaires ici




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une annonce de cours'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Ajoutez la logique pour revenir en arrière ici
            Navigator.pushReplacementNamed(context, '/annonces');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

          DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Niveau',
            prefixIcon: Icon(Icons.school),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          value: _selectedLevel,
          items: _levels.map((level) {
            return DropdownMenuItem<String>(
              value: level,
              child: Text(level),
            );
          }).toList(),
          onChanged: (level) {
            setState(() {
              _selectedLevel = level;

              // Charger les matières pour le niveau sélectionné depuis Firebase
              _loadSubjectsForLevel(level!);

              // Réinitialiser la matière sélectionnée
              _selectedSubject = null;
            });
          },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner un niveau';
              }
              return null;
            },
        ),
          SizedBox(height: 10.0),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Matière',
              prefixIcon: Icon(Icons.book),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            value: _selectedSubject,
            items: _subjects.map((subject) {
              return DropdownMenuItem<String>(
                value: subject,
                child: Text(subject),
              );
            }).toList(),
            onChanged: (subject) {
              setState(() {
                _selectedSubject = subject;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner une matière';
              }
              return null;
            },
          ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Unité de tarification',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                value: _selectedRateUnit,
                items: ['Par heure', 'Par mois'].map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (unit) {
                  setState(() {
                    _selectedRateUnit = unit;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une unité de tarification';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tarif',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer votre tarif';
                  }

                  if (_selectedRateUnit == 'Par heure') {
                    // Ajoutez une validation spécifique pour le tarif horaire si nécessaire
                  } else if (_selectedRateUnit == 'Par mois') {
                    // Ajoutez une validation spécifique pour le tarif mensuel si nécessaire
                  }

                  return null;
                },
                onSaved: (value) {
                  if (_selectedRateUnit == 'Par heure') {
                    _hourlyRate = double.parse(value!);
                  } else if (_selectedRateUnit == 'Par mois') {
                    _monthlyRate = double.parse(value!);
                  }
                },

              ),

              SizedBox(height: 10.0),
              FormField<bool>(
                builder: (state) {
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text('Jours disponibles'),
                        value: _selectedDays.isNotEmpty,
                        onChanged: (value) {
                          _showDaysDialog();
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      if (state.hasError) ...[
                        SizedBox(height: 5),
                        Text(
                          state.errorText!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  );
                },
                validator: (value) {
                  if (_selectedDays.isEmpty) {
                    return 'Veuillez sélectionner au moins un jour disponible';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Créneau horaire',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                value: _selectedTimeSlot,
                items: _timeSlots.map((timeSlot) {
                  return DropdownMenuItem<String>(
                    value: timeSlot,
                    child: Text(timeSlot),
                  );
                }).toList(),
                onChanged: (timeSlot) {
                  setState(() {
                    _selectedTimeSlot = timeSlot;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un créneau horaire';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20.0),
              ElevatedButton(
                child: Text('Créer une annonce'),
                onPressed: _submitForm,

              ),
            ],
          ),
        ),
      ),
    );
  }
  // Charger les matières depuis Firebase pour un niveau donné
  Future<void> _loadSubjectsForLevel(String level) async {
    try {
      // Remplacez 'cours' par le nom de votre collection Firebase pour les cours
      // et 'matieres' par le nom de votre sous-collection pour les matières
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection('cours').doc(level).collection('matieres').get();

      List<String> subjects = querySnapshot.docs.map((doc) => doc['nom'] as String).toList();

      setState(() {
        _subjects = subjects;
      });
    } catch (e) {
      print('Erreur lors du chargement des matières depuis Firebase: $e');
      // Gérez les erreurs selon vos besoins
    }
  }

  Future<void> _showDaysDialog() async {
    List<String> daysOfWeek = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

    List<bool> selectedDays = List<bool>.filled(daysOfWeek.length, false);

    // Mettez à jour les valeurs initiales pour les jours déjà sélectionnés
    for (int i = 0; i < daysOfWeek.length; i++) {
      if (_selectedDays.contains(daysOfWeek[i])) {
        selectedDays[i] = true;
      }
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sélectionnez les jours'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: List.generate(daysOfWeek.length, (index) {
                  return CheckboxListTile(
                    title: Text(daysOfWeek[index]),
                    value: selectedDays[index],
                    onChanged: (value) {
                      setState(() {
                        _updateSelectedDays(daysOfWeek[index], value!);
                        selectedDays[index] = value;
                      });
                    },
                  );
                }),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _updateSelectedDays(String day, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedDays.add(day);
      } else {
        _selectedDays.remove(day);
      }
    });
  }



  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Exemple d'appel depuis un widget Stateful
      _courseAnnouncementService.saveCourseAnnouncement(
        context: context,
        selectedLevel: _selectedLevel,
        hourlyRate: _hourlyRate,
        monthlyRate: _monthlyRate,
        selectedDays: _selectedDays,
        selectedTimeSlot: _selectedTimeSlot,
        selectedRateUnit: _selectedRateUnit,
        selectedSubject: _selectedSubject,
      );


      // Envoyer les données à votre backend ou effectuer toute autre logique nécessaire
      // N'oubliez pas d'adapter cela en fonction de votre architecture et de vos besoins

      // Exemple de logique d'impression pour le débogage
      print('Niveau: $_selectedLevel');
      print('Matière, $_selectedSubject');
      print('Tarif horaire: $_hourlyRate');
      print('Jours disponibles: $_selectedDays');
      print('Créneau horaire: $_selectedTimeSlot');

      // Ajoutez ici le code pour envoyer les données à votre backend ou effectuer d'autres opérations nécessaires
    }
  }


}


