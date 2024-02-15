class Product {
  String? id;
  String? productName;
  String? productCode;
  String? image;
  String? unitPrice;
  String? quantity;
  String? totalPrice;
  String? createdDate;

  Product({
    this.id,
    this.productName,
    this.productCode,
    this.image,
    this.unitPrice,
    this.quantity,
    this.totalPrice,
    this.createdDate,
  });

  Product.fromJson(Map<String, dynamic> Json) {
    id = Json['_id'];
    productName = Json["ProductName"];
    productCode = Json['ProductCode'];
    image = Json["Img"];
    unitPrice = Json["UnitPrice"];
    quantity = Json["Qty"];
    totalPrice = Json["TotalPrice"];
    createdDate = Json["CreatedDate"];
  }

  Map<String, dynamic> toJson() {
    return {
      "Img": image,
      "ProductCode": productCode,
      "ProductName": productName,
      "Qty": quantity,
      "TotalPrice": totalPrice,
      "UnitPrice": unitPrice,
      "_id":id,
    };
  }
}
