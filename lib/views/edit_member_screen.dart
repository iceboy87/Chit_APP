import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/member_controller.dart';
import '../models/member_model.dart';

class EditMemberScreen extends StatefulWidget {
  final MemberModel member;
  const EditMemberScreen({super.key, required this.member});

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController numberCtrl;
  late TextEditingController addressCtrl;

  final box = Hive.box('memberLocalBox');

  String? profilePath;
  String? aadhaarFront;
  String? aadhaarBack;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.member.name);
    numberCtrl = TextEditingController(text: widget.member.number);
    addressCtrl = TextEditingController(text: widget.member.address);

    final localData = box.get(widget.member.id, defaultValue: {});
    profilePath = localData["profileImage"];
    aadhaarFront = localData["aadhaarFront"];
    aadhaarBack = localData["aadhaarBack"];
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (type == "profile") {
          profilePath = pickedFile.path;
        } else if (type == "aadhaarFront") {
          aadhaarFront = pickedFile.path;
        } else if (type == "aadhaarBack") {
          aadhaarBack = pickedFile.path;
        }
      });

      // ✅ save paths in Hive
      box.put(widget.member.id, {
        "memberId": widget.member.id,
        "profileImage": profilePath,
        "aadhaarFront": aadhaarFront,
        "aadhaarBack": aadhaarBack,
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final c = Get.find<MemberController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Member", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ Profile Image
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: profilePath != null && File(profilePath!).existsSync()
                        ? FileImage(File(profilePath!))
                        : null,
                    child: (profilePath == null || !File(profilePath!).existsSync())
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _pickImage("profile"),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildInputCard(icon: Icons.person, controller: nameCtrl, label: "Name"),
            const SizedBox(height: 16),
            _buildInputCard(icon: Icons.phone, controller: numberCtrl, label: "Phone Number", keyboard: TextInputType.phone),
            const SizedBox(height: 16),
            _buildInputCard(icon: Icons.home, controller: addressCtrl, label: "Address", maxLines: 2),
            const SizedBox(height: 20),

            // ✅ Aadhaar Images
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text("Aadhaar Front", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _pickImage("aadhaarFront"),
                        child: aadhaarFront != null && File(aadhaarFront!).existsSync()
                            ? Image.file(File(aadhaarFront!), height: 120, fit: BoxFit.cover)
                            : Container(
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.camera_alt, size: 40)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      const Text("Aadhaar Back", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _pickImage("aadhaarBack"),
                        child: aadhaarBack != null && File(aadhaarBack!).existsSync()
                            ? Image.file(File(aadhaarBack!), height: 120, fit: BoxFit.cover)
                            : Container(
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.camera_alt, size: 40)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ✅ Save Button
            GestureDetector(
              onTap: () async {
                await c.updateMember(
                  id: widget.member.id,
                  name: nameCtrl.text,
                  number: numberCtrl.text,
                  address: addressCtrl.text,
                  chitType: widget.member.chitType,
                  status: widget.member.status,
                );
                Get.back();
                Get.snackbar("Updated", "Member details updated",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.shade600,
                    colorText: Colors.white);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text("💾 Save Changes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required IconData icon,
    required TextEditingController controller,
    required String label,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.deepPurple.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.deepPurple),
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
