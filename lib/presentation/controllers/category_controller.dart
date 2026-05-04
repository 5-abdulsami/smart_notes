import 'package:get/get.dart';
import '../../data/models/category_model.dart';
import '../../data/services/storage_service.dart';

class CategoryController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxString selectedCategoryId = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  void loadCategories() {
    final list = _storage.categories.values.toList();
    list.sort((a, b) => a.order.compareTo(b.order!));
    categories.value = list;
  }

  Future<void> addCategory(String name, {int colorValue = 0xFF2196F3}) async {
    final category = CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      colorValue: colorValue,
      order: categories.length,
      createdAt: DateTime.now(),
    );
    await _storage.addCategory(category);
    loadCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _storage.updateCategory(category);
    loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _storage.deleteCategory(id);
    if (selectedCategoryId.value == id) {
      selectedCategoryId.value = 'all';
    }
    loadCategories();
  }

  void selectCategory(String id) {
    selectedCategoryId.value = id;
  }
}
