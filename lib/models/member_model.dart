import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String id;
  final String name;
  final String number;
  final String address;
  final String chitType;
  final String status;

  MemberModel({
    required this.id,
    required this.name,
    required this.number,
    required this.address,
    required this.chitType,
    this.status = "Pending",
  });

  factory MemberModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemberModel(
      id: doc.id,
      name: data['name'] ?? '',
      number: data['number'] ?? '',
      address: data['address'] ?? '',
      chitType: data['chitType'] ?? '',
      status: data['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'number': number,
    'address': address,
    'chitType': chitType,
    'status': status,
  };

  MemberModel copyWith({
    String? id,
    String? name,
    String? number,
    String? address,
    String? chitType,
    String? status,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      address: address ?? this.address,
      chitType: chitType ?? this.chitType,
      status: status ?? this.status,
    );
  }
}


class MemberLocalModel {
  final String memberId;   // Firestore memberId
  final String? profileImage; // local file path
  final String? aadhaarImage; // local file path

  MemberLocalModel({
    required this.memberId,
    this.profileImage,
    this.aadhaarImage,
  });

  // ✅ toMap for Hive
  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'profileImage': profileImage,
      'aadhaarImage': aadhaarImage,
    };
  }

  // ✅ fromMap for Hive
  factory MemberLocalModel.fromMap(Map<dynamic, dynamic> map) {
    return MemberLocalModel(
      memberId: map['memberId'],
      profileImage: map['profileImage'],
      aadhaarImage: map['aadhaarImage'],
    );
  }
}


