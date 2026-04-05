import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/models/product.dart';
import 'package:mediscribe_app/screens/cart_screen.dart';
import 'package:mediscribe_app/services/product_service.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final TextEditingController _search = TextEditingController();
  final List<String> _categories = const [
    'All',
    'Medicines',
    'Supplements',
    'Devices',
    'Personal Care',
  ];

  String _selectedCategory = 'All';
  bool _loading = true;
  String? _error;
  List<Product> _products = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final products = await ProductService.fetchProducts(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      query: _search.text.trim(),
    );
    setState(() {
      _loading = false;
      _products = products;
      if (products.isEmpty) {
        _error = 'No products found (or backend unreachable).';
      }
    });
  }

  List<Product> _filterTag(String tag) => _products
      .where((p) => p.tags.map((t) => t.toLowerCase()).contains(tag))
      .toList();

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final trending = _filterTag('trending');
    final bestseller = _filterTag('bestseller');

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: _buildAppBar(appState),
      floatingActionButton: appState.cartCount == 0
          ? null
          : _buildFloatingCartButton(appState),
      body: RefreshIndicator(
        onRefresh: _load,
        color: const Color(0xFF2E7DFF),
        backgroundColor: const Color(0xFF111B2E),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          children: [
            _SearchBar(
              controller: _search,
              hint: 'Search medicines, supplements...',
              onChanged: (_) => _load(),
            ),
            const SizedBox(height: 14),
            const _GradientBanner(
              title: '15% OFF',
              subtitle: 'Medicines at your doorstep',
              icon: Icons.local_shipping_outlined,
              colors: [Color(0xFF2E7DFF), Color(0xFF6D5BFF)],
            ),
            const SizedBox(height: 18),
            _SectionTitle(
              title: 'Categories',
              trailing: Text(
                _selectedCategory,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final c = _categories[i];
                  final selected = c == _selectedCategory;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = c);
                      _load();
                    },
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                    selectedColor: const Color(0xFF2E7DFF),
                    backgroundColor: Colors.white.withOpacity(0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7DFF))),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.white54),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7DFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              const _SectionTitle(title: 'Trending Products'),
              const SizedBox(height: 12),
              _ProductStrip(
                products: trending.isEmpty ? _products.take(6).toList() : trending,
                onAdd: (p) => _animateAddToCart(context, () => appState.addToCart(p)),
              ),
              const SizedBox(height: 18),
              const _SectionTitle(title: 'Bestseller Products'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (bestseller.isEmpty ? _products : bestseller).length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 262,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final list = bestseller.isEmpty ? _products : bestseller;
                  final product = list[index];
                  final qty = appState.cartItems[product.id] ?? 0;
                  return _ProductGridCard(
                    product: product,
                    quantity: qty,
                    onAdd: () => _animateAddToCart(context, () => appState.addToCart(product)),
                    onMinus: qty == 0
                        ? null
                        : () => appState.updateQuantity(product.id, qty - 1),
                    onPlus: () => appState.updateQuantity(product.id, qty + 1),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppState appState) {
    return AppBar(
      backgroundColor: const Color(0xFF0B1220),
      title: const Text(
        "Health Shop",
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      elevation: 0,
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              tooltip: 'View Cart',
            ),
            if (appState.cartCount > 0)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7DFF),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    appState.cartCount > 99 ? '99+' : '${appState.cartCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildFloatingCartButton(AppState appState) {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xFF2E7DFF),
      foregroundColor: Colors.white,
      elevation: 8,
      // shadowColor: const Color(0xFF2E7DFF).withOpacity(0.5),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_outlined),
          const SizedBox(width: 8),
          Text('Cart (${appState.cartCount})'),
        ],
      ),
    );
  }

  Future<void> _animateAddToCart(BuildContext context, VoidCallback action) async {
    action();
    await Future.delayed(const Duration(milliseconds: 60));
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Added to cart'),
            ],
          ),
          backgroundColor: const Color(0xFF2E7DFF),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          isDense: true,
        ),
      ),
    );
  }
}

class _GradientBanner extends StatelessWidget {
  const _GradientBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductStrip extends StatelessWidget {
  const _ProductStrip({required this.products, required this.onAdd});
  final List<Product> products;
  final ValueChanged<Product> onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = products[index];
          return SizedBox(
            width: 240,
            child: InkWell(
              onTap: () => onAdd(p),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111B2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        p.imageUrl,
                        height: 110,
                        width: 92,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 110,
                          width: 92,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.medication_outlined,
                              color: Colors.white54, size: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.category,
                            style: const TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                '₹${p.price}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹${p.mrp}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2E7DFF), Color(0xFF1E5BBF)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2E7DFF).withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'ADD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onMinus,
    required this.onPlus,
  });

  final Product product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.medication_outlined, 
                          color: Colors.white54, size: 32),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '₹${product.price}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${product.mrp}',
                  style: const TextStyle(
                    color: Colors.white54,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: quantity == 0
                  ? SizedBox(
                      width: double.infinity,
                      height: 42,
                      key: const ValueKey('add_button'),
                      child: ElevatedButton(
                        onPressed: onAdd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7DFF),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color(0xFF2E7DFF).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Add to cart',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                    )
                  : Container(
                      height: 42,
                      key: const ValueKey('quantity_container'),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: onMinus,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                          ),
                          Expanded(
                            child: Text(
                              '$quantity',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: onPlus,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}