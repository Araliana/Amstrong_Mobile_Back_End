import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    // Responsive values
    double horizontalPadding = isMobile
        ? 16.0
        : (isTablet ? screenWidth * 0.1 : screenWidth * 0.2);
    double verticalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
    double titleFontSize = isMobile ? 24.0 : (isTablet ? 32.0 : 40.0);
    double bodyFontSize = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);
    double spacing = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Product',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  'Kami',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 800 : double.infinity,
              ),
              child: Text(
                "Selain menjual bisa membeli kopi siap minum di kedai kopi kami. Kalian juga dapat membeli biji kopi berkualitas dan produk kopi lainnya dari website ini.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: bodyFontSize,
                  height: 1.6,
                  color: Colors.grey[700],
                ),
              ),
            ),
            SizedBox(height: spacing * 1.5),
            // Product Grid
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
                double cardWidth =
                    (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                    crossAxisCount;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: 8, // Jumlah produk
                  itemBuilder: (context, index) {
                    return _buildProductCard(
                      cardWidth: cardWidth,
                      isMobile: isMobile,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewProductDetail() {
    // Tampilkan dialog atau navigate ke halaman detail
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Product Detail'),
          content: const Text(
            'Coffee Beans Arabica 100%\n\nDetail produk akan ditampilkan di sini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard({
    required double cardWidth,
    required bool isMobile,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Eye Button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    _viewProductDetail();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.coffee,
                    size: isMobile ? 60 : 80,
                    color: Colors.brown[300],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'Coffee Beans\nArabica 100%',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                color: Colors.orange,
                size: isMobile ? 16 : 18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Price
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              children: [
                Text(
                  'IDR 50K',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'IDR 89K',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: isMobile ? 12 : 14,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
