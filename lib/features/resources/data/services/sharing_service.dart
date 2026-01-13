import 'package:cloud_firestore/cloud_firestore.dart';

class SharingService {
  final FirebaseFirestore firestore;

  SharingService({required this.firestore});

  Future<String> shareFile({
    required String fileId,
    required String sharedBy,
    required String sharedWith,
    required String accessLevel,
    Duration? expiresIn,
  }) async {
    try {
      final shareId = DateTime.now().millisecondsSinceEpoch.toString();
      final shareLink = _generateShareLink(fileId, shareId);

      await firestore.collection('fileShares').doc(shareId).set({
        'id': shareId,
        'fileId': fileId,
        'sharedBy': sharedBy,
        'sharedWith': sharedWith,
        'accessLevel': accessLevel,
        'shareLink': shareLink,
        'sharedAt': DateTime.now(),
        'expiresAt': expiresIn != null ? DateTime.now().add(expiresIn) : null,
        'isActive': true,
        'revokedAt': null,
      });

      return shareLink;
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  Future<void> revokeAccess(String shareId) async {
    try {
      await firestore.collection('fileShares').doc(shareId).update({
        'isActive': false,
        'revokedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to revoke access: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSharedWith(String fileId) async {
    try {
      final querySnapshot = await firestore
          .collection('fileShares')
          .where('fileId', isEqualTo: fileId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get shares: $e');
    }
  }

  String _generateShareLink(String fileId, String shareId) {
    return 'https://studyplanner.app/share/$fileId/$shareId';
  }
}
