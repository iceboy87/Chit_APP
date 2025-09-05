import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../controller/member_controller.dart';
import '../models/member_model.dart';
import '../services/pending_api.dart';
import 'package:intl/intl.dart';
import 'edit_member_screen.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final MemberModel m = Get.arguments as MemberModel;
    final c = Get.find<MemberController>();

    final box = Hive.box('memberLocalBox');
    final localData = box.get(m.id, defaultValue: {});
    final profilePath = localData["profileImage"];
    final aadhaarFront = localData["aadhaarFront"];
    final aadhaarBack = localData["aadhaarBack"];

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: Get.back),
        title: const Text('Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final member = m;
              Get.to(() => EditMemberScreen(member: member));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ Profile Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        profilePath != null && File(profilePath).existsSync()
                        ? FileImage(File(profilePath))
                        : null,
                    child:
                        (profilePath == null || !File(profilePath).existsSync())
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => Get.to(() => EditMemberScreen(member: m)),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Member Info
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.person, "Name", m.name),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.phone, "Contact", m.number),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.home, "Address", m.address),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.assignment, "Chit", m.chitType),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Aadhaar Images
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Aadhaar Front",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      aadhaarFront != null && File(aadhaarFront).existsSync()
                          ? Image.file(
                              File(aadhaarFront),
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 120,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.image, size: 40),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Aadhaar Back",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      aadhaarBack != null && File(aadhaarBack).existsSync()
                          ? Image.file(
                              File(aadhaarBack),
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 120,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.image, size: 40),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // ✅ Three Actions
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  final amountController = TextEditingController();
                  final c = Get.find<MemberController>();
                  final serialNo = c.getSerialNumber(m);
                  await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Enter Payment Details"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: amountController,
                            decoration: const InputDecoration(labelText: "Amount"),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final enteredAmount = amountController.text.trim();
                            if (enteredAmount.isEmpty) return;
                            final date = DateFormat('dd/MM/yyyy').format(DateTime.now());
                            await c.markPaid(m.id);
                            final template =
                                "அன்புள்ள {#var#} தேதி {#var#} உங்கள் {#var#} சீட்டின் தொகை {#var#} வெற்றிகரமாக வரவு வைக்கப்பட்டது SRI LAKSHMI AUTO FINANCE";
                            final message = template
                                .replaceFirst("{#var#}", m.name)
                                .replaceFirst("{#var#}", date)
                                .replaceFirst("{#var#}", serialNo.toString())
                                .replaceFirst("{#var#}", enteredAmount);

                            final result = await PendingRepository().sendPendingSms(
                              mobileNo: m.number,
                              text: message,
                            );

                            Navigator.pop(ctx);

                            if (result['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("✅ Pending SMS sent successfully"),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "❌ Failed: ${result['description'] ?? 'Unknown error'}",
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text("Send"),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Paid',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final amountController = TextEditingController();
                  final date = DateFormat('dd/MM/yyyy').format(DateTime.now());
                  final c = Get.find<MemberController>();
                  final serialNo = c.getSerialNumber(m);
                  await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Enter Pending Amount"),
                      content: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Amount",
                          hintText: "Enter pending amount",
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final enteredAmount = amountController.text.trim();
                            if (enteredAmount.isEmpty) return;
                            await c.markPending(m.id);
                            final template =
                                "அன்புள்ள {#var#} chit no {#var#} DATE {#var#}\n"
                                " சீட்டின் தொகை {#var#} செலுத்தாமல் உள்ளது "
                                "தயவுசெய்து உடனடியாக செலுத்தி அபராதத்தை தவிர்க்கவும் "
                                "Shri Lakshmi Auto Finance";
                            final message = template
                                .replaceFirst("{#var#}", m.name)
                                .replaceFirst("{#var#}", serialNo.toString())
                                .replaceFirst("{#var#}", date)
                                .replaceFirst("{#var#}", enteredAmount);
                             print("chit no ${serialNo.toString()}");
                            final result = await PendingRepository().sendPendingSms(
                              mobileNo: m.number,
                              text: message,
                            );

                            Navigator.pop(ctx);

                            if (result['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("✅ Pending SMS sent successfully"),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "❌ Failed: ${result['description'] ?? 'Unknown error'}",
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text("Send"),
                        ),
                      ],
                    ),
                  );
                },
                child: _isSending
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.red,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Pending',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
