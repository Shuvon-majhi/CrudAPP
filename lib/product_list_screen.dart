import 'dart:convert';

import 'package:basicrestapi/add_new_product_screen.dart';
import 'package:basicrestapi/edit_product_screen.dart';
import 'package:basicrestapi/productclass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

enum PopupMenuType {
  edit,
  delete,
}

class productListScreen extends StatefulWidget {
  const productListScreen({super.key});

  @override
  State<productListScreen> createState() => _productListScreenState();
}

class _productListScreenState extends State<productListScreen> {
  List<Product> productList = [];
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    getProductListFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product List"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getProductListFromApi();
        },
        child: Visibility(
          visible: _inProgress == false,
          replacement: const Center(child: CircularProgressIndicator()),
          child: ListView.builder(
            itemCount: productList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(productList[index].image ?? ''),
                ),
                title: Text('Product name ${productList[index].productName}'),
                subtitle: Wrap(
                  spacing: 16,
                  children: [
                    Text(
                        'Product code ${productList[index].productCode ?? 'Unknown'}'),
                    Text(
                        'Unit price ${productList[index].unitPrice ?? 'Unknown'}'),
                    Text(
                        'Total price ${productList[index].totalPrice ?? 'Unknown'}'),
                    Text(
                        'Quantity ${productList[index].quantity ?? 'Unknown'}'),
                  ],
                ),
                trailing: PopupMenuButton<PopupMenuType>(
                  onSelected: (type) =>
                      onTapPopUpMenuButton(type, productList[index]),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: PopupMenuType.edit,
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(
                            width: 8,
                          ),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: PopupMenuType.delete,
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(
                            width: 8,
                          ),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNewProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> onTapPopUpMenuButton(PopupMenuType type, Product product) async {
    switch (type) {
      case PopupMenuType.edit:
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProductScreen(
              product: product,
            ),
          ),
        );
        if (result != null && result == true) {
          getProductListFromApi();
        }
        break;
      case PopupMenuType.delete:
        _showDeleteDialog(product.id!);
        break;
    }
  }

  void _showDeleteDialog(String productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content:
              const Text('Are you sure that you want to delete this product'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(productId);
                Navigator.pop(context);
              },
              child: const Text(
                'Yes, Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    _inProgress = true;
    setState(() {});

    Uri uri = Uri.parse(
        'https://crud.teamrabbil.com/api/v1/DeleteProduct/${productId}');
    Response response = await get(uri);
    if (response.statusCode == 200) {
      productList.removeWhere((element) => element.id == productId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deletion failed! Try again'),
        ),
      );
    }
    _inProgress = false;
    setState(() {});
  }

  Future<void> getProductListFromApi() async {
    _inProgress = true;
    setState(() {});
    //step 1: Make Uri
    Uri uri = Uri.parse('https://crud.teamrabbil.com/api/v1/ReadProduct');
    // step 2: call api
    Response response = await get(uri);
    // step 3: show response
    if (response.statusCode == 200) {
      productList.clear();
      var decodeResponse = jsonDecode(response.body);
      if (decodeResponse['status'] == 'success') {
        var list = decodeResponse['data'];
        for (var item in list) {
          Product product = Product.fromJson(item);
          productList.add(product);
          //setState(() {});
        }
        _inProgress = false;
        setState(() {});
      }
    }
  }
}
