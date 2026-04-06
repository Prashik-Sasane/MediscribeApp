import 'dart:async';
import 'package:flutter/material.dart';

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

  final List<String> categories = ["All", "Medicines", "Vitamins", "Skincare", "First Aid"];

  // FIXED BRAND LOGOS
  final List<Map<String, String>> topBrands = [
    {"name": "Pfizer", "logo": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/Pfizer_logo.svg/2560px-Pfizer_logo.svg.png"},
    {"name": "Bayer", "logo": "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Bayer_logo.svg/1200px-Bayer_logo.svg.png"},
    {"name": "Abbott", "logo": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Abbott_Laboratories_logo.svg/1280px-Abbott_Laboratories_logo.svg.png"},
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _pageController.dispose();
    _bannerTimer.cancel();
    super.dispose();
  }

  void _addToCart() {
    setState(() {
      cartCount++;
      totalPrice += 120.00;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1222),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildAnimatedPromoSlider()),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildSectionHeader("Top Company")),
              SliverToBoxAdapter(child: _buildBrandList()),
              const SliverToBoxAdapter(child: SizedBox(height: 15)),
              SliverToBoxAdapter(child: _buildCategoryList()),
              SliverToBoxAdapter(child: _buildSectionHeader("Popular Products")),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildProductCard(index),
                    childCount: 4,
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
                    Positioned(
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                            child: const Text("Buy now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          return Container(
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
          );
        },
      ),
    );
  }

  // ... (Keep existing Appbar, SearchBar, SectionHeader, CategoryList, ProductCard, CartBar and TrackingSheet from previous code) ...

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=a"),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Hello, Anton!", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Good Morning", style: TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
        IconButton(icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white), onPressed: () {}),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
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
            onTap: () => setState(() => activeCategory = index),
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

  Widget _buildProductCard(int index) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300"), fit: BoxFit.contain),
                  ),
                ),
                Positioned(right: 15, top: 15, child: const Icon(Icons.favorite_border, color: Colors.red, size: 20)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Covid-19 Vaccine", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const Text("By Biocon", style: TextStyle(color: Colors.white38, fontSize: 10)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("\$120.00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    GestureDetector(
                      onTap: _addToCart,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFF2E7DFF), shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnimatedCartBar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      bottom: 20, left: 20, right: 20,
      child: InkWell(
        onTap: () => _showTrackingSheet(context),
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7DFF),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
          ),
          child: Row(
            children: [
              const Icon(Icons.track_changes, color: Colors.white),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$cartCount Items in Cart", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Text("Tap to Track Order", style: TextStyle(color: Colors.white70, fontSize: 12)),
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