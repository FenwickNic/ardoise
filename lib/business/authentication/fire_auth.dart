import 'package:ardoise/model/common/app_error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FireAuth {
  static Future<User> signInUsingEmailPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user!;

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          case 'invalid-email':
        throw AppError(
          severity: ESeverityLevel.Error,
          message: "Impossible de se connecter",
          description: "Veuillez vérifier votre utilisateur et mot de passe avant de réessayer."
        );
        case 'wrong-password':
        throw AppError(
            severity: ESeverityLevel.Error,
            message: "Impossible de se connecter",
            description: "Veuillez vérifier votre utilisateur et mot de passe avant de réessayer."
        );
        case 'user-disabled':
          throw AppError(
            severity: ESeverityLevel.Error,
            message: "Impossible de se connecter",
            description: "Veuillez contacter votre administrateur."
          );
        default:
          throw AppError();
      }
    }catch(e){
      throw AppError();
    }
    return user;
  }

  static Future<void> sendPasswordResetEmail(String email) async{
    FirebaseAuth auth = FirebaseAuth.instance;

    try{
      await auth.sendPasswordResetEmail(email: email);
    }on FirebaseAuthException catch(e){
      switch(e.code) {
        case 'auth/invalid-email':
          throw AppError(
              severity: ESeverityLevel.Error,
              message: "Impossible de mettre à jour le mot de passe",
              description: "L'email fourni n'est pas valide veuillez la vérifier avant de nous contacter."
          );
        case 'auth/user-not-found':
          throw AppError(
              severity: ESeverityLevel.Error,
              message: "Impossible de mettre à jour le mot de passe",
              description: "Etes-vous certain que cet utilisateur existe dans notre base de donnée?"
          );
        case 'auth/missing-android-pkg-name':
        case 'auth/missing-ios-bundle-id':
          throw AppError(
              severity: ESeverityLevel.Critical,
              message: "Impossible de mettre à jour le mot de passe",
              description: "Nous n'avons pas pu envoyer l'email. Une erreur s'est produite veuillez mettre à jour l'application."
          );
        case 'auth/missing-continue-uri':
        case 'auth/invalid-continue-uri':
        case 'auth/unauthorized-continue-uri':
          throw AppError(
              severity: ESeverityLevel.Critical,
              message: "Impossible de mettre à jour le mot de passe",
              description: "Nous n'avons pas pu envoyer l'email. Une erreur s'est produite veuillez mettre à jour l'application."
          );
        default:
          throw AppError();
      }
    }catch(e){
      throw AppError();
    }
  }
}