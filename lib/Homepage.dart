import 'package:flutter/material.dart';
import 'package:my_shop/product_details.dart';

class HomeScreen extends StatefulWidget {

  final List<Map<String, dynamic>> products;
  final Function(Map<String, dynamic>) onAddToCart;

  const HomeScreen({
    super.key,
    required this.products,
    required this.onAddToCart,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String searchText = '';
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {

    final filteredProducts =
        widget.products.where((product) {

      final matchesSearch =
          product['name']
              .toString()
              .toLowerCase()
              .contains(
                searchText.toLowerCase(),
              );

      final matchesCategory =
          selectedCategory == 'All' ||
          product['category'] ==
              selectedCategory;

      return matchesSearch &&
          matchesCategory;

    }).toList();

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          '🛍️ My Shop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          // Search
          Padding(
            padding: const EdgeInsets.all(10),

            child: TextField(

              onChanged: (value) {

                setState(() {
                  searchText = value;
                });

              },

              decoration: InputDecoration(
                hintText: 'Search product...',
                prefixIcon:
                    const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Categories
          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,

            child: Row(
              children: [

                'All',
                'Food',
                'Drink',
                'Electronics',

              ].map((category) {

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 5,
                  ),

                  child: ChoiceChip(

                    label: Text(category),

                    selected:
                        selectedCategory ==
                            category,

                    onSelected: (value) {

                      setState(() {
                        selectedCategory =
                            category;
                      });

                    },
                  ),
                );

              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Products
          Expanded(
            child: GridView.builder(

              padding:
                  const EdgeInsets.all(10),

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.70,
              ),

              itemCount:
                  filteredProducts.length,

              itemBuilder:
                  (context, index) {

                final product =
                    filteredProducts[index];

                return Card(
                   child: InkWell(
                                    onTap: () {

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailsScreen(
                                            product: product,
                                            onAddToCart: widget.onAddToCart,
                                          ),
                                        ),
                                      );

                                    },

                  

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // Image
                      Expanded(
                        child: SizedBox(
                          width:
                              double.infinity,

                          child:
                              Image.network(
                            product['image'],

                            fit: BoxFit.cover,

                            errorBuilder:
                                (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Icon(
                                Icons
                                    .image_not_supported,
                                size: 50,
                              );
                            },
                          ),
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.all(
                          8,
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              product['name'],
                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              '৳${product['price']}',
                              style:
                                  const TextStyle(
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            SizedBox(
                              width:
                                  double.infinity,

                              child:
                                  ElevatedButton(
                                onPressed: () {

                                  widget
                                      .onAddToCart(
                                    product,
                                  );

                                  ScaffoldMessenger
                                      .of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(
                                        '${product['name']} added to cart',
                                      ),
                                    ),
                                  );

                                },

                                child:
                                    const Text(
                                  'Add to Cart',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                   )
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}