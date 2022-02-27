import 'package:cloud_firestore/cloud_firestore.dart';

class FundUser{
  /*L'index de l'utilisateur pour la base de donnée*/
  String documentId;
  /*Le prénom de l'utilisateur*/
  String firstname;
  /*Le nom de l'utilisateur.*/
  String lastname;
  /*L'adresse email de l'utilisateur*/
  String email;
  /*Les permissions d'administrateur de l'utilisateur.*/
  bool administrator;

  FundUser({
    this.documentId = "",
    this.firstname = "",
    this.lastname = "",
    required this.email,
    this.administrator = false
  });

  Map<String, dynamic> toMap(){
    return {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'administrator': administrator
    };
  }

    factory FundUser.fromMap(DocumentSnapshot<Map<String, dynamic>> doc){
      Map<String, dynamic>? data = doc.data();

      if(data == null){
        throw new Exception("User not found");
      }

      return FundUser(
          documentId: doc.id,
          firstname: data['firstname'] ?? '',
          lastname: data['lastname'] ?? '',
          email: data['email'] ?? '',
          administrator: data['administrator']
      );
    }

    String get fullname {
      return "$firstname $lastname";
  }
  String get defaultAvatar{
    return "${firstname[0]}${lastname[0]}";
  }
}