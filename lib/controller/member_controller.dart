import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../firebase_services/firestore_service.dart';
import '../models/member_model.dart';

class MemberController extends GetxController {
  final _fs = FirestoreService();
  final _auth = FirebaseAuth.instance;

  final members = <MemberModel>[].obs;
  final search = ''.obs;

  final box = Hive.box('memberLocalBox');

  @override
  void onInit() {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _fs.watchMembers(uid).listen((list) => members.assignAll(list));
    }
    super.onInit();
  }

  int getSerialNumber(MemberModel member) {
    final chitMembers = members
        .where((m) => m.chitType == member.chitType)
        .toList();

    chitMembers.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

    final index = chitMembers.indexWhere((m) => m.id == member.id);
    return index + 1;
  }

  List<MemberModel> get filtered => members
      .where((m) => m.name.toLowerCase().contains(search.value.toLowerCase()))
      .toList();

  Future<void> addMember({
    required String name,
    required String number,
    required String address,
    required String chitType,
  }) async {
    final uid = _auth.currentUser!.uid;

    // Check existing members for this chitType
    final count = members.where((m) => m.chitType == chitType).length;
    if (count >= 20) {
      Get.snackbar('Limit reached', 'Only 20 members allowed per chit type');
      return;
    }
    final chitMembers = members.where((m) => m.chitType == chitType).toList();
    int newId = 1;
    if (chitMembers.isNotEmpty) {
      final ids = chitMembers.map((e) => int.tryParse(e.id) ?? 0).toList();
      newId = (ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b)) + 1;
    }
    final newMember = MemberModel(
      id: newId.toString(),
      name: name,
      number: number,
      address: address,
      chitType: chitType,
    );
    await _fs.addMember(uid, newMember);
    Get.back();
    Get.snackbar('Saved', 'Member added');
  }

  Future<void> markPaid(String id) async {
    final uid = _auth.currentUser!.uid;
    await _fs.updateStatus(uid, id, 'Paid');

    final index = members.indexWhere((m) => m.id == id);
    if (index != -1) {
      members[index] = members[index].copyWith(status: 'Paid');
      members.refresh();
    }
  }

  Future<void> markPending(String id) async {
    final uid = _auth.currentUser!.uid;
    await _fs.updateStatus(uid, id, 'Pending');
    final index = members.indexWhere((m) => m.id == id);
    if (index != -1) {
      members[index] = members[index].copyWith(status: 'Pending');
      members.refresh();
    }
  }

  Future<void> updateMember({
    required String id,
    required String name,
    required String number,
    required String address,
    required String chitType,
    String? status, // optional
  }) async {
    final uid = _auth.currentUser!.uid;
    final existing = members.firstWhereOrNull((m) => m.id == id);
    await _fs.updateMember(
      uid,
      MemberModel(
        id: id,
        name: name,
        number: number,
        address: address,
        chitType: chitType,
        status: status ?? existing?.status ?? "Pending",
      ),
    );
  }

  final firestoreService = FirestoreService();

  Future<void> deleteMember(String id) async {
    final uid = _auth.currentUser!.uid;
    await _fs.deleteMember(uid, id);
    Get.snackbar('Deleted', 'Member removed');
  }
}
