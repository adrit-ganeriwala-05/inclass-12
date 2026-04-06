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
  bool _isLoading = false;

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
    setState(() => _isLoading = true);

    final newItem = Item(
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      price: double.parse(_priceController.text.trim()),
    );

    try {
      if (widget.item == null) {
        await widget.service.addItem(newItem);
      } else {
        await widget.service.updateItem(widget.item!.id!, newItem);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Item' : 'Add Item'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  prefixIcon: Icon(Icons.label_outline),
                  border: OutlineInputBorder(),
                ),
                validator: _validateNotEmpty,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: _validateNotEmpty,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validateQuantity,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validatePrice,
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(isEdit ? 'Save Changes' : 'Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
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