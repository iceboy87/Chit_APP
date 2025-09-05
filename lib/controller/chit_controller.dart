import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ChitController extends GetxController {
  var types = <String>[].obs;
  var selected = "".obs;

  late Box chitBox;

  @override
  void onInit() {
    super.onInit();
    chitBox = Hive.box('chitTypeBox');
    loadChitTypes();
  }

  void loadChitTypes() {
    final saved = chitBox.get('types', defaultValue: <String>[]);
    types.assignAll(List<String>.from(saved));
  }

  void addChitType(String type) {
    types.add(type);
    chitBox.put('types', types.toList());
  }

  void deleteChitType(int index) {
    types.removeAt(index);
    chitBox.put('types', types.toList());
  }
}
