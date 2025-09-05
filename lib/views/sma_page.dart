import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/sms21_service.dart';
import '../controller/member_controller.dart';

class SmsPage extends StatefulWidget {
  const SmsPage({super.key});

  @override
  State<SmsPage> createState() => _SmsPageState();
}

class _SmsPageState extends State<SmsPage> {
  final SmsApiService smsService = SmsApiService();

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _chitNoController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _perHeadController = TextEditingController();
  final TextEditingController _payableController = TextEditingController();

  bool _isSending = false;

  void _clearForm() {
    _mobileController.clear();
    _nameController.clear();
    _chitNoController.clear();
    _amountController.clear();
    _discountController.clear();
    _perHeadController.clear();
    _payableController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📩 Send SMS"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildField(
                      "Mobile Number",
                      _mobileController,
                      type: TextInputType.phone,
                      icon: Icons.phone,
                    ),
                    _buildField("Name", _nameController, icon: Icons.person),
                    _buildField(
                      "Chit No",
                      _chitNoController,
                      icon: Icons.confirmation_number,
                    ),
                    _buildField(
                      "Amount",
                      _amountController,
                      type: TextInputType.number,
                      icon: Icons.money,
                    ),
                    _buildField(
                      "Discount",
                      _discountController,
                      type: TextInputType.number,
                      icon: Icons.percent,
                    ),
                    _buildField(
                      "Per Head Discount",
                      _perHeadController,
                      type: TextInputType.number,
                      icon: Icons.people,
                    ),
                    _buildField(
                      "Payable Amount",
                      _payableController,
                      type: TextInputType.number,
                      icon: Icons.payments,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            /// ✅ Single SMS Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _onSendPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _isSending
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text("Sending..."),
                        ],
                      )
                    : const Text("Send Single SMS"),
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ Send to All Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _onSendToAllPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _isSending
                    ? const Text("Sending to All...")
                    : const Text("📢 Send to All Members"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Send to single entered number
  Future<void> _onSendPressed() async {
    final mobile = _mobileController.text.trim();
    final name = _nameController.text.trim();
    final chitNo = _chitNoController.text.trim();
    final amount = _amountController.text.trim();
    final discount = _discountController.text.trim();
    final perHead = _perHeadController.text.trim();
    final payable = _payableController.text.trim();

    if ([
      mobile,
      name,
      chitNo,
      amount,
      discount,
      perHead,
      payable,
    ].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all fields")),
      );
      return;
    }

    final date = DateTime.now().toString().split(' ')[0];

    /// ✅ Build final text
    final text =
        '''
அன்புள்ள $name Date $date chit no $chitNo
சீட்டின் தொகை Rs: $amount
சீட்டின் தள்ளுபடி Rs: $discount
ஒரு நபரின் தள்ளுபடி : Rs: $perHead
கட்ட வேண்டிய தொகை Rs: $payable
உடனடியாக செலுத்தி அபராதத்தை தவிர்க்கவும்
SRI LAKSHMI AUTO FINANCE
''';

    setState(() => _isSending = true);
    final result = await smsService.sendSms(mobileNo: mobile, text: text);
    setState(() => _isSending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['status'] == 'success'
              ? '✅ SMS sent successfully!'
              : '❌ Failed: ${result['description']}',
        ),
      ),
    );

    _clearForm();
  }

  /// 🔹 Send to all members from controller
  Future<void> _onSendToAllPressed() async {
    final memberController = Get.find<MemberController>();
    final members = memberController.filtered;
    final chitNo = _chitNoController.text.trim();
    final amount = _amountController.text.trim();
    final discount = _discountController.text.trim();
    final perHead = _perHeadController.text.trim();
    final payable = _payableController.text.trim();

    if (members.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("⚠️ No members found")));
      return;
    }

    setState(() => _isSending = true);

    final date = DateTime.now().toString().split(' ')[0];

    for (final m in members) {
      final text = ''' 
அன்புள்ள ${m.name} Date $date chit no $chitNo
சீட்டின் தொகை Rs: $amount
சீட்டின் தள்ளுபடி Rs: $discount
ஒரு நபரின் தள்ளுபடி :Rs: $perHead
கட்ட வேண்டிய தொகை Rs: $payable உடனடியாக செலுத்தி அபராதத்தை தவிர்க்கவும்
SRI LAKSHMI AUTO FINANCE
''';


      await smsService.sendSms(mobileNo: m.number, text: text);
    }

    setState(() => _isSending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Messages sent to all members")),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.deepPurple)
              : null,
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
      ),
    );
  }
}
