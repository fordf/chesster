import 'package:cloud_firestore/cloud_firestore.dart';

Future<DocumentSnapshot<Map<String, dynamic>>> queryCache(
    DocumentReference<Map<String, dynamic>> docRef) async {
  final result = await docRef.get(const GetOptions(source: Source.cache));
  if (!result.exists) {
    return docRef.get(const GetOptions(source: Source.server));
  }
  return result;
}
