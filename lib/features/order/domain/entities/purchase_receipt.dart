class PurchaseReceipt {
  final String orderId;
  final String orderDate;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;
  final List<dynamic> items;
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
    String _s(String a, String b) => (json[a] ?? json[b] ?? '').toString();
    double _d(String a, String b) {
      final v = json[a] ?? json[b] ?? 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int _i(String a, String b) {
      final v = json[a] ?? json[b] ?? 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    List<dynamic> _l(String a, String b) =>
        (json[a] ?? json[b] ?? []) as List<dynamic>;

    return PurchaseReceipt(
      orderId: _s('orderId', 'order_id'),
      orderDate: _s('orderDate', 'order_date'),
      customerName: _s('customerName', 'customer_name'),
      customerEmail: _s('customerEmail', 'customer_email'),
      customerPhone: _s('customerPhone', 'customer_phone'),
      shippingAddress: _s('shippingAddress', 'shipping_address'),
      items: _l('items', 'items'),
      subtotal: _d('subtotal', 'subtotal'),
      shippingCost: _d('shippingCost', 'shipping_cost'),
      tax: _d('tax', 'tax'),
      discount: _d('discount', 'discount'),
      totalAmount: _d('totalAmount', 'total_amount'),
      paymentMethod: _s('paymentMethod', 'payment_method'),
      paymentStatus: _s('paymentStatus', 'payment_status'),
      purchaseStructure: _s('purchaseStructure', 'purchase_structure'),
      installmentMonths: _i('installmentMonths', 'installment_months'),
      installmentAmount: _d('installmentAmount', 'installment_amount'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderDate': orderDate,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'items': items,
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'tax': tax,
      'discount': discount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'purchaseStructure': purchaseStructure,
      'installmentMonths': installmentMonths,
      'installmentAmount': installmentAmount,
    };
  }
}
