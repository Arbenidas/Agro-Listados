class ListItem {
  final int? id;
  final int listId;
  final int productId;
  final double price;
  final int quantity;
  final double subtotal;

  ListItem({
    this.id,
    required this.listId,
    required this.productId,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'list_id': listId,
      'product_id': productId,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory ListItem.fromMap(Map<String, dynamic> map) {
    return ListItem(
      id: map['id']?.toInt(),
      listId: map['list_id']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity']?.toInt() ?? 0,
      subtotal: (map['subtotal'] ?? 0).toDouble(),
    );
  }

  ListItem copyWith({
    int? id,
    int? listId,
    int? productId,
    double? price,
    int? quantity,
    double? subtotal,
  }) {
    return ListItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  String toString() {
    return 'ListItem(id: $id, listId: $listId, productId: $productId, price: $price, quantity: $quantity, subtotal: $subtotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListItem &&
        other.id == id &&
        other.listId == listId &&
        other.productId == productId &&
        other.price == price &&
        other.quantity == quantity &&
        other.subtotal == subtotal;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        listId.hashCode ^
        productId.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        subtotal.hashCode;
  }
}
