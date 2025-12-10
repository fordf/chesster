import 'package:cloud_firestore/cloud_firestore.dart';

Future<DocumentSnapshot<Map<String, dynamic>>> queryCache(
    DocumentReference<Map<String, dynamic>> docRef) {
  final result = docRef.get(const GetOptions(source: Source.cache)).then(
        (res) => res,
        onError: (e) => docRef.get(const GetOptions(source: Source.server)),
      );
  return result;
}
