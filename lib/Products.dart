import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './ProductD.dart';
import 'FavShopBtn.dart';
import 'main.dart';
import 'model/Product.dart';

class Products extends StatefulWidget {
  final Future<List<Product>> Function() getProducts;

  Products({Key? key, required this.getProducts}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductsState();
  }
}

class _ProductsState extends State<Products> {
  late Future<List<Product>> _products;
  late Key _key;

  @override
  void initState() {
    super.initState();
    _products = widget.getProducts();
    _key = UniqueKey();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    return FutureBuilder<List<Product>>(
      key: _key,
      future: _products,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No products to display",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            );
          } else {
            return SingleChildScrollView(
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 0.7,
                padding: EdgeInsets.all(10),
                children: snapshot.data!.map((product) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) {
                            return ProductD(
                              userId: appState.isLogin()
                                  ? appState.getUser()!.id
                                  : -1,
                              product: product,
                            );
                          },
                        ),
                      ).whenComplete(() {
                        setState(() {
                          _key = UniqueKey();
                        });
                      });
                    },
                    child: ProductCard(
                      userId: appState.isLogin()
                          ? appState.getUser()!.id
                          : -1,
                      product: product,
                    ),
                  );
                }).toList(),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _products = widget.getProducts();
                      _key = UniqueKey();
                    });
                  },
                  child: Text("Retry"),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final int userId;
  final Product product;

  ProductCard({required this.userId, required this.product});

  @override
  Widget build(BuildContext context) {
    const double height = 5;
    return SizedBox(
      height: double.infinity,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    product.image!,
                    fit: BoxFit.cover,
                    height: 160,
                    width: double.infinity,
                  ),
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: height),
                  Text(
                    "${product.price} HTG",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  FavShopBtn(
                    userId: userId,
                    productId: product.id,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}