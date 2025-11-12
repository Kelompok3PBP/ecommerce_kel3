class PurchaseReceipt {
  String _orderId;
  String _orderDate;
  String _customerName;
  String _customerEmail;
  String _customerPhone;
  String _shippingAddress;
  List<ReceiptItem> _items;
  double _subtotal;
  double _shippingCost;
  double _tax;
  double _discount;
  double _totalAmount;
  String _paymentMethod;
  String _paymentStatus;
  String _purchaseStructure;
  int _installmentMonths;
  double _installmentAmount;

  PurchaseReceipt({
    required String orderId,
    required String orderDate,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String shippingAddress,
    required List<ReceiptItem> items,
    required double subtotal,
    required double shippingCost,
    required double tax,
    required double discount,
    required double totalAmount,
    required String paymentMethod,
    required String paymentStatus,
    required String purchaseStructure,
    required int installmentMonths,
    required double installmentAmount,
  }) : _orderId = orderId,
       _orderDate = orderDate,
       _customerName = customerName,
       _customerEmail = customerEmail,
       _customerPhone = customerPhone,
       _shippingAddress = shippingAddress,
       _items = items,
       _subtotal = subtotal,
       _shippingCost = shippingCost,
       _tax = tax,
       _discount = discount,
       _totalAmount = totalAmount,
       _paymentMethod = paymentMethod,
       _paymentStatus = paymentStatus,
       _purchaseStructure = purchaseStructure,
       _installmentMonths = installmentMonths,
       _installmentAmount = installmentAmount;

  // Getters
  String get orderId => _orderId;
  String get orderDate => _orderDate;
  String get customerName => _customerName;
  String get customerEmail => _customerEmail;
  String get customerPhone => _customerPhone;
  String get shippingAddress => _shippingAddress;
  List<ReceiptItem> get items => List.unmodifiable(_items);
  double get subtotal => _subtotal;
  double get shippingCost => _shippingCost;
  double get tax => _tax;
  double get discount => _discount;
  double get totalAmount => _totalAmount;
  String get paymentMethod => _paymentMethod;
  String get paymentStatus => _paymentStatus;
  String get purchaseStructure => _purchaseStructure;
  int get installmentMonths => _installmentMonths;
  double get installmentAmount => _installmentAmount;

  // Setters
  set orderId(String v) => _orderId = v;
  set orderDate(String v) => _orderDate = v;
  set customerName(String v) => _customerName = v;
  set customerEmail(String v) => _customerEmail = v;
  set customerPhone(String v) => _customerPhone = v;
  set shippingAddress(String v) => _shippingAddress = v;
  set items(List<ReceiptItem> v) => _items = v;
  set subtotal(double v) => _subtotal = v;
  set shippingCost(double v) => _shippingCost = v;
  set tax(double v) => _tax = v;
  set discount(double v) => _discount = v;
  set totalAmount(double v) => _totalAmount = v;
  set paymentMethod(String v) => _paymentMethod = v;
  set paymentStatus(String v) => _paymentStatus = v;
  set purchaseStructure(String v) => _purchaseStructure = v;
  set installmentMonths(int v) => _installmentMonths = v;
  set installmentAmount(double v) => _installmentAmount = v;

  factory PurchaseReceipt.fromJson(Map<String, dynamic> json) {
    return PurchaseReceipt(
      orderId: json['order_id'] ?? '',
      orderDate: json['order_date'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      shippingAddress: json['shipping_address'] ?? '',
      items:
          (json['items'] as List?)
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
      installmentAmount:
          (json['installment_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': _orderId,
      'order_date': _orderDate,
      'customer_name': _customerName,
      'customer_email': _customerEmail,
      'customer_phone': _customerPhone,
      'shipping_address': _shippingAddress,
      'items': _items.map((item) => item.toJson()).toList(),
      'subtotal': _subtotal,
      'shipping_cost': _shippingCost,
      'tax': _tax,
      'discount': _discount,
      'total_amount': _totalAmount,
      'payment_method': _paymentMethod,
      'payment_status': _paymentStatus,
      'purchase_structure': _purchaseStructure,
      'installment_months': _installmentMonths,
      'installment_amount': _installmentAmount,
    };
  }
}

class ReceiptItem {
  String _productId;
  String _productName;
  String _productImage;
  int _quantity;
  double _price;
  double _subtotal;

  ReceiptItem({
    required String productId,
    required String productName,
    required String productImage,
    required int quantity,
    required double price,
    required double subtotal,
  }) : _productId = productId,
       _productName = productName,
       _productImage = productImage,
       _quantity = quantity,
       _price = price,
       _subtotal = subtotal;

  // getters
  String get productId => _productId;
  String get productName => _productName;
  String get productImage => _productImage;
  int get quantity => _quantity;
  double get price => _price;
  double get subtotal => _subtotal;

  // setters
  set productId(String v) => _productId = v;
  set productName(String v) => _productName = v;
  set productImage(String v) => _productImage = v;
  set quantity(int v) => _quantity = v;
  set price(double v) => _price = v;
  set subtotal(double v) => _subtotal = v;

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
      'product_id': _productId,
      'product_name': _productName,
      'product_image': _productImage,
      'quantity': _quantity,
      'price': _price,
      'subtotal': _subtotal,
    };
  }
}
