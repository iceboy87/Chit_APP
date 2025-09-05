import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedSeat;
  final List<String> seatPlans = [
    "₹50,000 Seat",
    "₹1,00,000 Seat",
    "₹3,00,000 Seat"
  ];

  final CollectionReference entriesRef =
  FirebaseFirestore.instance.collection('entries');

  Future<void> _addEntry() async {
    if (_formKey.currentState!.validate()) {
      await entriesRef.add({
        "name": _nameController.text,
        "phone": _phoneController.text,
        "seat": _selectedSeat,
        "amount": _amountController.text,
        "timestamp": FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      _phoneController.clear();
      _amountController.clear();
      setState(() {
        _selectedSeat = null;
      });
    }
  }

  List<Map<String, dynamic>> entries = [];

  // void _addEntry() {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       entries.add({
  //         "name": _nameController.text,
  //         "phone": _phoneController.text,
  //         "seat": _selectedSeat,
  //         "amount": _amountController.text,
  //       });
  //       _nameController.clear();
  //       _phoneController.clear();
  //       _amountController.clear();
  //       _selectedSeat = null;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Entry Admin"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? "Enter Name" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? "Enter Phone Number" : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Select Seat Plan",
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedSeat,
                    items: seatPlans.map((seat) {
                      return DropdownMenuItem(
                        value: seat,
                        child: Text(seat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSeat = value;
                      });
                    },
                    validator: (value) =>
                    value == null ? "Select Seat Plan" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? "Enter Amount" : null,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _addEntry,
                    child: const Text("Add Entry"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "All Entries",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: entriesRef.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Error loading data");
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final entry = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text(entry["name"] ?? ""),
                          subtitle: Text(
                              "${entry["phone"]} | ${entry["seat"]} | ₹${entry["amount"]}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}