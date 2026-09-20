import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onAddToCart;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Product Image
            SizedBox(
              width: double.infinity,
              height: 300,
              child: Image.network(
                product['image'],
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // Product Name
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Price
                  Text(
                    '৳${product['price']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Category
                  Text(
                    'Category: ${product['category']}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Rating
                  Row(
                    children: [

                      const Icon(
                        Icons.star,
                        size: 25,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        '${product['rating'] ?? 4.0}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product['description'] ??
                        'This is a high quality product. '
                        'You can add this product to your cart '
                        'and continue shopping.',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Add To Cart
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      onPressed: () {

                        onAddToCart(product);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product['name']} added to cart',
                            ),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.shopping_cart,
                      ),

                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
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