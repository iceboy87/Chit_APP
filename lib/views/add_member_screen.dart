import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chit_controller.dart';
import '../controller/member_controller.dart';

class AddMemberScreen extends StatelessWidget {
  const AddMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MemberController>();
    final chit = Get.find<ChitController>();

    final name = TextEditingController();
    final number = TextEditingController();
    final address = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("➕ Add New Member"),
        centerTitle: true,
        // backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputCard(Icons.person, "Name", name),
            const SizedBox(height: 16),
            _buildInputCard(Icons.phone, "Number", number, keyboard: TextInputType.phone),
            const SizedBox(height: 16),
            _buildInputCard(Icons.home, "Address", address, maxLines: 2),
            const SizedBox(height: 16),

            // Chit Type Dropdown
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: DropdownButtonFormField<String>(
                  value: chit.selected.value.isEmpty ? null : chit.selected.value,
                  items: chit.types
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => chit.selected.value = v ?? '',
                  decoration: const InputDecoration(
                    labelText: "Chit Type",
                    prefixIcon: Icon(Icons.category, color: Colors.deepPurple),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            GestureDetector(
              onTap: () {
                if (chit.selected.value.isEmpty) {
                  Get.snackbar("⚠️ Missing Info", "Please choose a chit type");
                  return;
                }
                c.addMember(
                  name: name.text.trim(),
                  number: number.text.trim(),
                  address: address.text.trim(),
                  chitType: chit.selected.value,
                );
                Get.back();
                Get.snackbar("✅ Success", "Member added successfully",
                    backgroundColor: Colors.green.shade600, colorText: Colors.white);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  "💾 Save Member",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(
      IconData icon,
      String label,
      TextEditingController controller, {
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
