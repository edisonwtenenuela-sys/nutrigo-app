import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';

class FirebaseService {
  static final Logger _logger = Logger('FirebaseService');

  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  static bool _initialized = false;

  static Future<void> initializeFirebase() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();

      _initialized = true;
      _logger.info('Firebase inicializado correctamente');
    } catch (e, st) {
      _logger.severe('Error inicializando Firebase', e, st);
      rethrow;
    }
  }
}








