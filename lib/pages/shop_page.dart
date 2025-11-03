import 'package:flutter/material.dart';
import 'package:uniperks/pages/product_catalog_page.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    // This is just a wrapper to maintain consistency
    // The actual shopping functionality is in ProductCatalogPage
    return const ProductCatalogPage(username: 'guest');
  }
}
