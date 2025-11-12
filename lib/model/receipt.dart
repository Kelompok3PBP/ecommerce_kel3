class PurchaseReceipt {
  final String orderId;
  final String orderDate;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;
  final List<ReceiptItem> items;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double discount;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String purchaseStructure;
  final int installmentMonths;
  final double installmentAmount;

  PurchaseReceipt({
    required this.orderId,
    required this.orderDate,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.discount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.purchaseStructure,
    required this.installmentMonths,
    required this.installmentAmount,
  });

  factory PurchaseReceipt.fromJson(Map<String, dynamic> json) {
    return PurchaseReceipt(
      orderId: json['order_id'] ?? '',
      orderDate: json['order_date'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      shippingAddress: json['shipping_address'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => ReceiptItem.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      purchaseStructure: json['purchase_structure'] ?? '',
      installmentMonths: json['installment_months'] ?? 0,
      installmentAmount: (json['installment_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_date': orderDate,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'shipping_address': shippingAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'tax': tax,
      'discount': discount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'purchase_structure': purchaseStructure,
      'installment_months': installmentMonths,
      'installment_amount': installmentAmount,
    };
  }
}

class ReceiptItem {
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final double subtotal;

  ReceiptItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}