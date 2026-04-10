import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/order_service.dart';
import '../../services/auth_api_service.dart'; // Import AuthApiService
import '../../services/payment_service.dart'; // Import PaymentService
import '../../services/cart_service.dart'; // Import CartService
import '../../screens/cart_screen.dart'; // Import CartScreen & MyOrdersScreen
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

import '../../widgets/healthcare/product_card.dart';
import '../../widgets/healthcare/address_picker_sheet.dart';

class UltraHealthShop extends StatefulWidget {
  const UltraHealthShop({super.key});

  @override
  State<UltraHealthShop> createState() => _UltraHealthShopState();
}

class _UltraHealthShopState extends State<UltraHealthShop> {
  int activeCategory = 0;
  int cartCount = 0;
  double totalPrice = 0.0;
  
  // Banner Animation Logic
  late PageController _pageController;
  int _currentBannerPage = 0;
  late Timer _bannerTimer;

  final List<Map<String, String>> promoSlides = [
    {"title": "Choose good\nMedicine", "sub": "Pure care, delivered.", "color": "0xFF2E7DFF"},
    {"title": "Your Health,\nOur Priority", "sub": "Verified Pharmacy.", "color": "0xFF6366F1"},
    {"title": "Fastest Delivery\nin Town", "sub": "Within 30 minutes.", "color": "0xFF10B981"},
  ];

  final List<String> categories = ["All", "Medicines", "Supplements", "Devices", "Personal Care"];

  // FIXED BRAND LOGOS
  final List<Map<String, String>> topBrands = [
    {"name": "Pfizer", "logo": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/Pfizer_logo.svg/2560px-Pfizer_logo.svg.png"},
    {"name": "Bayer", "logo": "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Bayer_logo.svg/1200px-Bayer_logo.svg.png"},
    {"name": "Abbott", "logo": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Abbott_Laboratories_logo.svg/1280px-Abbott_Laboratories_logo.svg.png"},
  ];

  List<Product> _products = [];
  bool _isLoading = false;
  final List<Product> _cartItems = [];
  Map<String, dynamic>? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchDefaultAddress();
    _loadCartFromService();
    _pageController = PageController(initialPage: 0);
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentBannerPage < 2) {
        _currentBannerPage++;
      } else {
        _currentBannerPage = 0;
      }
      _pageController.animateToPage(
        _currentBannerPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Future<void> _loadCartFromService() async {
    final cartItems = await CartService.getCartItems();
    final cartCount = await CartService.getCartCount();
    final cartTotal = await CartService.getCartTotal();
    
    setState(() {
      _cartItems.clear();
      _cartItems.addAll(cartItems.map((item) => item.product));
      this.cartCount = cartCount;
      totalPrice = cartTotal.toDouble();
    });
  }

  Future<void> _fetchDefaultAddress() async {
    try {
      final token = AppScope.of(context).token;
      if (token == null) return;
      
      final addresses = await AuthApiService.getAddresses(token);
      if (mounted && addresses.isNotEmpty) {
        final defaultAddr = addresses.firstWhere(
          (a) => a['isDefault'] == true, 
          orElse: () => addresses.first,
        );
        setState(() => _selectedAddress = Map<String, dynamic>.from(defaultAddr));
      }
    } catch (e) {
      print('Error fetching address: $e');
      // Don't block UI if address fetch fails
    }
  }

  void _onSelectAddress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressPickerSheet(
        onSelected: (addr) {
          setState(() => _selectedAddress = addr);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _fetchProducts({String? query, String? category}) async {
    setState(() => _isLoading = true);
    final products = await ProductService.fetchProducts(
      query: query,
      category: category == "All" ? null : category,
    );
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  void _onCategoryChanged(int index) {
    setState(() => activeCategory = index);
    _fetchProducts(category: categories[index]);
  }

  void _onSearch(String q) {
    _fetchProducts(query: q, category: categories[activeCategory]);
  }

  void _addToCart(Product product) async {
    // Add to CartService (SharedPreferences)
    await CartService.addToCart(product);
    
    // Update local state for UI
    setState(() {
      _cartItems.add(product);
      cartCount = _cartItems.length;
      totalPrice += product.price;
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} added to cart"),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF2E7DFF),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    final state = AppScope.of(context);
    final token = state.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to place order")),
      );
      return;
    }

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty")),
      );
      return;
    }

    // Show Payment / Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Confirm Order", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total: \$${totalPrice.toStringAsFixed(2)}", 
                style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Payment Method:", style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7DFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2E7DFF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Color(0xFF2E7DFF)),
                  const SizedBox(width: 8),
                  const Text("Stripe (Card Payment)", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7DFF)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Pay with Stripe"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing payment...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Create order first to get orderId
      final items = _cartItems.map((p) => OrderItem(
        productId: p.id,
        name: p.name,
        qty: 1,
        price: p.price,
      )).toList();

      final orderId = await OrderService.createOrder(
        token: token,
        items: items,
        total: totalPrice.toInt(),
      );

      if (orderId == null) {
        Navigator.pop(context); // Close loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to create order")),
          );
        }
        return;
      }

      // Process Stripe Payment
      final result = await PaymentService.processStripePayment(
        token: token,
        amount: totalPrice,
        orderType: 'pharmacy',
        orderId: orderId,
        publishableKey: 'pk_test_your_stripe_key_here', // Replace with your test key
      );

      Navigator.pop(context); // Close loading

      if (result['success'] == true) {
        setState(() {
          _cartItems.clear();
          cartCount = 0;
          totalPrice = 0.0;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment successful! Order placed."),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to My Orders
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? "Payment failed"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _paymentMethodTile(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7DFF), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          const Icon(Icons.radio_button_off_rounded, color: Colors.white24, size: 16),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bannerTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1222),
      appBar: _buildAppBar(user),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildAddressBar()),
              SliverToBoxAdapter(child: _buildAnimatedPromoSlider()),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildSectionHeader("Top Company")),
              SliverToBoxAdapter(child: _buildBrandList()),
              const SliverToBoxAdapter(child: SizedBox(height: 15)),
              SliverToBoxAdapter(child: _buildCategoryList()),
              SliverToBoxAdapter(child: _buildSectionHeader("Popular Products")),
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0xFF2E7DFF)),
                    ),
                  ),
                )
              else if (_products.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("No products found", style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(
                        product: _products[index],
                        onAddToCart: () => _addToCart(_products[index]),
                      ),
                      childCount: _products.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          if (cartCount > 0) _buildAnimatedCartBar(),
        ],
      ),
    );
  }

  Widget _buildAddressBar() {
    return InkWell(
      onTap: _onSelectAddress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: Color(0xFF2E7DFF), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedAddress != null ? "Delivering to ${_selectedAddress!['label']}" : "Deliver to...",
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _selectedAddress != null ? _selectedAddress!['fullAddress'] : "Tap to select address",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPromoSlider() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (int page) => setState(() => _currentBannerPage = page),
        itemCount: promoSlides.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      Color(int.parse(promoSlides[index]['color']!)),
                      Color(int.parse(promoSlides[index]['color']!)).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      right: -20, bottom: -20,
                      child: Opacity(
                        opacity: 0.3,
                        child: Icon(Icons.medication_liquid, size: 150, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(promoSlides[index]['title']!, 
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.1)),
                          const SizedBox(height: 8),
                          Text(promoSlides[index]['sub']!, 
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: () {
                              // Filter to the relevant category
                              final cat = index == 0 ? "Medicines" : index == 1 ? "Supplements" : "Devices";
                              final catIndex = categories.indexOf(cat);
                              if (catIndex != -1) _onCategoryChanged(catIndex);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                              child: const Text("Buy now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBrandList() {
    return SizedBox(
      height: 65,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: topBrands.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Search for products from this brand (simplified)
              _onSearch(topBrands[index]['name']!);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Image.network(
                    topBrands[index]['logo']!, 
                    width: 45, 
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.grey),
                  ),
                  const SizedBox(width: 10),
                  Text(topBrands[index]['name']!, 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B1222))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("See more", style: TextStyle(color: Colors.blueAccent, fontSize: 13)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(UserProfile? user) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(user?.avatarUrl.isNotEmpty == true 
                ? user!.avatarUrl 
                : "https://i.pravatar.cc/150?u=a"),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello, ${user?.name ?? 'User'}!", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text("Good Morning", style: TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
          ),
        ),
        IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: _onSearch,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          hintText: "Search medicine...",
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = activeCategory == index;
          return GestureDetector(
            onTap: () => _onCategoryChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7DFF) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(categories[index], style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: FontWeight.bold))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedCartBar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      bottom: 20, left: 20, right: 20,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ).then((_) => _loadCartFromService()); // Reload cart when returning
        },
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7DFF),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart_checkout, color: Colors.white),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$cartCount Items in Cart", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Text("Tap to Checkout", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              const Spacer(),
              Text("\$${totalPrice.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  void _showTrackingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("Live Track", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.blueGrey.withOpacity(0.2),
                  image: const DecorationImage(
                    image: NetworkImage("https://miro.medium.com/v2/resize:fit:1400/1*q3Z7uS6E-v3J5fN-1m_EGA.png"),
                    fit: BoxFit.cover
                  )
                ),
                child: Center(
                  child: Icon(Icons.location_on, color: Color(0xFF2E7DFF), size: 50),
                ),
              ),
            ),
            _buildDeliveryInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 25, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=b")),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Marek Piwnicki", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Delivery Partner • 4.9 ★", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              const CircleAvatar(backgroundColor: Color(0xFF2E7DFF), child: Icon(Icons.call, color: Colors.white)),
            ],
          ),
          const Divider(height: 40, color: Colors.white10),
          Row(
            children: [
              const Icon(Icons.location_searching, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Drop Point", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  Text("17 R.M.S Society, Ahmedabad", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              const Text("16:30", style: TextStyle(color: Colors.white38)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7DFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text("Order Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}