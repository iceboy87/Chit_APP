import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> membersCol(String uid) =>
      _db.collection('users').doc(uid).collection('members');

  Future<String> addMember(String uid, MemberModel m) async {
    final snapshot = await membersCol(uid)
        .where('chitType', isEqualTo: m.chitType)
        .get();

    if (snapshot.docs.length >= 20) {
      return 'limit_reached';
    }

    final ref = membersCol(uid).doc();
    final member = m.copyWith(id: ref.id);
    await ref.set(member.toJson());
    return 'success';
  }


  Stream<List<MemberModel>> watchMembers(String uid) {
    return membersCol(uid)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => MemberModel.fromDoc(d)).toList());
  }

  Future<MemberModel?> getMember(String uid, String id) async {
    final doc = await membersCol(uid).doc(id).get();
    if (!doc.exists) return null;
    return MemberModel.fromDoc(doc);
  }

  Future<void> updateStatus(String uid, String id, String status) async {
    await membersCol(uid).doc(id).update({'status': status});
  }

  Future<void> updateMember(String uid, MemberModel member) async {
    await membersCol(uid).doc(member.id).update(member.toJson());
  }
  Future<void> deleteMember(String uid, String id) async {
    await membersCol(uid).doc(id).delete();
  }
}
