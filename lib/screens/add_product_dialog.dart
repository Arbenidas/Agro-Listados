import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logitruck_app/model/product.dart';

class AddProductDialog extends StatefulWidget {
  final List<Product> availableProducts;
  final Function(Map<String, dynamic>) onProductAdded;

  const AddProductDialog({
    Key? key,
    required this.availableProducts,
    required this.onProductAdded,
  }) : super(key: key);

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  Product? _selectedProduct;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isFormValid() {
    return _selectedProduct != null &&
        _priceController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty;
  }

  void _addProduct() {
    if (_formKey.currentState!.validate() && _isFormValid()) {
      final productData = {
        'product': _selectedProduct!.name,
        'price': _priceController.text,
        'unit': _selectedProduct!.unit,
        'quantity': _quantityController.text,
      };

      // Cerrar el diálogo primero
      Navigator.pop(context);

      // Luego llamar al callback
      widget.onProductAdded(productData);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Producto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Producto:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Product>(
                decoration: const InputDecoration(
                  hintText: 'Seleccionar producto',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  border: OutlineInputBorder(),
                ),
                value: _selectedProduct,
                items: widget.availableProducts.map((product) {
                  return DropdownMenuItem<Product>(
                    value: product,
                    child: Text('${product.name} (${product.unit})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduct = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona un producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Precio por ${_selectedProduct?.unit ?? 'unidad'}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  hintText: 'Precio por unidad',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Ingresa un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Cantidad:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  hintText: 'Cantidad',
                  prefixIcon: const Icon(Icons.numbers),
                  suffixText: _selectedProduct?.unit ?? '',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cantidad';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Ingresa una cantidad válida';
                  }
                  return null;
                },
              ),
              if (_selectedProduct != null &&
                  _priceController.text.isNotEmpty &&
                  _quantityController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Producto: ${_selectedProduct!.name}'),
                      Text(
                          'Cantidad: ${_quantityController.text} ${_selectedProduct!.unit}'),
                      Text('Precio unitario: \$${_priceController.text}'),
                      const Divider(),
                      Text(
                        'Subtotal: \$${(double.tryParse(_priceController.text) ?? 0) * (int.tryParse(_quantityController.text) ?? 0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: _addProduct,
          child: const Text('AGREGAR'),
        ),
      ],
    );
  }
}
