import 'package:flutter/material.dart';

InputDecoration appInput(String label) => InputDecoration(
  labelText: label,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
);

Widget primaryButton(String text, VoidCallback onTap) => SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(onPressed: onTap, child: Text(text)),
);
