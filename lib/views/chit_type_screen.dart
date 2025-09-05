import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/chit_controller.dart';
import '../routes/app_routes.dart';

import 'package:intl/intl.dart';

class ChitTypeScreen extends StatelessWidget {
  const ChitTypeScreen({super.key});

  void logoutaccount() async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ChitController());

    // ⬅️ Get today's date in readable format
    String today = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('CHIT TYPE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        logoutaccount();
                        Get.offAllNamed(AppRoutes.login);
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: c.types.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Delete Chit Type"),
                        content: Text(
                          "Are you sure you want to delete ${c.types[i]}?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              c.deleteChitType(i);
                              Navigator.pop(ctx);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey),
                    ),
                    child: ListTile(
                      subtitle: Text(
                        today,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Amount',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            c.types[i],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        c.selected.value = c.types[i];
                        Get.toNamed(AppRoutes.members);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'assets/money bank.gif',
              height: 200,
              width: 200,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) {
              final controller = TextEditingController();
              return AlertDialog(
                title: const Text("Add Chit Type"),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter chit amount",
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        c.addChitType(controller.text.trim());
                      }
                      Navigator.pop(ctx);
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
