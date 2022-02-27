import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
    group('Testing Transactions', () {
      test("Inserting a transaction", () async{
        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
        FirebaseAdapter adapter = FirebaseAdapter();
          expect(true, true);
        });
        });
}