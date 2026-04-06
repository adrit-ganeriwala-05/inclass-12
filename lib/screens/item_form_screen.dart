import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class ItemFormScreen extends StatefulWidget {
  final FirestoreService service;
  final Item? item;

  const ItemFormScreen({super.key, required this.service, this.item});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _categoryController =
        TextEditingController(text: widget.item?.category ?? '');
    _quantityController =
        TextEditingController(text: widget.item?.quantity.toString() ?? '');
    _priceController =
        TextEditingController(text: widget.item?.price.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newItem = Item(
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      price: double.parse(_priceController.text.trim()),
    );

    // Pop first, then save — instant navigation regardless of network
    Navigator.pop(context);

    try {
      if (widget.item == null) {
        await widget.service.addItem(newItem);
      } else {
        await widget.service.updateItem(widget.item!.id!, newItem);
      }
    } catch (e) {
      debugPrint('Firestore error: $e');
    }
  }

  String? _validateNotEmpty(String? val) =>
      (val == null || val.trim().isEmpty) ? 'This field is required' : null;

  String? _validateQuantity(String? val) {
    if (val == null || val.trim().isEmpty) return 'Quantity is required';
    final n = int.tryParse(val.trim());
    if (n == null) return 'Must be a whole number';
    if (n < 0) return 'Cannot be negative';
    return null;
  }

  String? _validatePrice(String? val) {
    if (val == null || val.trim().isEmpty) return 'Price is required';
    final n = double.tryParse(val.trim());
    if (n == null) return 'Must be a valid number';
    if (n < 0) return 'Cannot be negative';
    return null;
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFFD600),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          textCapitalization: capitalization,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFFFD600), size: 20),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  const BorderSide(color: Color(0xFFFFD600), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        title: Text(
          isEdit ? 'EDIT ITEM' : 'NEW ITEM',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            color: Color(0xFFFFD600),
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFF333333)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField(
                controller: _nameController,
                label: 'ITEM NAME',
                icon: Icons.inventory_2_outlined,
                validator: _validateNotEmpty,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),
              _buildField(
                controller: _categoryController,
                label: 'CATEGORY',
                icon: Icons.category_outlined,
                validator: _validateNotEmpty,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _quantityController,
                      label: 'QUANTITY',
                      icon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                      validator: _validateQuantity,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      controller: _priceController,
                      label: 'PRICE (\$)',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: _validatePrice,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    isEdit ? 'SAVE CHANGES' : 'ADD ITEM',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}