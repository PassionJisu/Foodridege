import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sale_provider.dart';
import 'sale_history_screen.dart';

class SaleRegistrationScreen extends StatefulWidget {
  const SaleRegistrationScreen({super.key, required this.branchName});

  final String branchName;

  @override
  State<SaleRegistrationScreen> createState() => _SaleRegistrationScreenState();
}

class _SaleRegistrationScreenState extends State<SaleRegistrationScreen> {
  ProductCategory _selectedCategory = ProductCategory.sidedish;
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController(text: '5000');

  // 신청 대기 품목 리스트
  final List<Map<String, dynamic>> _addedItems = [];

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addItem() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price = int.tryParse(_priceController.text) ?? 0;

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('수량을 입력해 주세요.')));
      return;
    }

    setState(() {
      _addedItems.add({
        'category': _selectedCategory,
        'quantity': quantity,
        'pricePerUnit': price,
      });
      // 입력창 초기화 (카테고리는 유지, 수량만 초기화 예시)
      _quantityController.text = '1';
    });
  }

  void _removeItem(int index) {
    setState(() {
      _addedItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final saleProvider = context.watch<SaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('잉여 식품 등록'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  widget.branchName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                const Text('학생식당 잔반이 조리할 만큼 부족하면 B급 농산물로 식자재를 보충해 주세요.'),
                const SizedBox(height: 32),
                
                // 입력 영역
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('식품 카테고리', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<ProductCategory>(
                        key: ValueKey(_selectedCategory),
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(filled: true, fillColor: Colors.white),
                        items: ProductCategory.values.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat.label));
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v!),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('수량', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    suffixText: '개',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('희망 매입가', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    suffixText: '원',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add),
                          label: const Text('품목 리스트에 추가하기'),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                const Text('추가된 품목 목록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                
                if (_addedItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('추가된 품목이 없습니다.', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...List.generate(_addedItems.length, (index) {
                    final item = _addedItems[index];
                    final category = item['category'] as ProductCategory;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('${category.label} ${item['quantity']}개'),
                        subtitle: Text('개당 ${item['pricePerUnit']}원'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
          
          // 하단 신청 버튼 영역
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (saleProvider.isLoading || _addedItems.isEmpty)
                        ? null
                        : () => _handleSubmit(auth.appUser!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: saleProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('총 ${_addedItems.length}건 매매 신청하기', 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '※ 21:00~21:30 사이에 신청하시면 당일 수거가 진행됩니다.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit(AppUser user) async {
    final success = await context.read<SaleProvider>().submitMultipleSaleRequests(
          restaurantId: user.uid,
          restaurantName: user.name,
          branchName: widget.branchName,
          items: _addedItems,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모든 품목의 매매 신청이 완료되었습니다!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SaleHistoryScreen()),
      );
    }
  }
}
