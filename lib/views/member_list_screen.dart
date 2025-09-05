import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../controller/chit_controller.dart';
import '../controller/member_controller.dart';
import '../routes/app_routes.dart';
import '../models/member_model.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final selectedIds = <String>[].obs;
  late Box memberBox;

  @override
  void initState() {
    super.initState();
    memberBox = Hive.box('memberLocalBox');
  }


  Future<void> saveLocalImages(MemberModel m, String profile, String aadhaar) async {
    await memberBox.put(m.id, {
      "memberId": m.id,
      "profileImage": profile,
      "aadhaarImage": aadhaar,
    });
  }


  Future<void> updateAadhaar(MemberModel m, String aadhaar) async {
    final data = memberBox.get(m.id, defaultValue: {});
    await memberBox.put(m.id, {
      "memberId": m.id,
      "profileImage": data["profileImage"],
      "aadhaarImage": aadhaar,
    });
  }

  String? getProfile(MemberModel m) {

  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MemberController());
    final chit = Get.find<ChitController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (selectedIds.isNotEmpty) {
            return Text("${selectedIds.length} selected");
          }
          return Text(chit.selected.value.isEmpty ? 'Members' : chit.selected.value);
        }),
        actions: [
          if (selectedIds.isEmpty) ...[
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.addMember),
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.message),
              icon: const Icon(Icons.message),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Members"),
                    content: Text("Are you sure you want to delete ${selectedIds.length} members?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
                    ],
                  ),
                );
                if (confirm == true) {
                  await Future.wait(
                    selectedIds.map((id) => c.deleteMember(id)),
                  );
                  selectedIds.clear();
                }
              },
            ),
          ]
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
              ),
              onChanged: (v) => c.search.value = v,
            ),
          ),
          Expanded(
            child: Obx(() {
              final chitType = Get.find<ChitController>().selected.value;
              final membersList = c.filtered.where((m) => m.chitType == chitType).toList();

              return ListView.builder(
                itemCount: membersList.length,
                itemBuilder: (_, i) {
                  final m = membersList[i];
                  final serialNo = i + 1;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text(m.name),
                      subtitle: Text(m.number),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: m.status == 'Paid' ? Colors.green.withOpacity(.15) : Colors.red.withOpacity(.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          m.status,
                          style: TextStyle(
                            color: m.status == 'Paid' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () => Get.toNamed(AppRoutes.details, arguments: m),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
