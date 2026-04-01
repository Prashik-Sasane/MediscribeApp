import 'package:flutter/material.dart';

class LabTestsScreen extends StatelessWidget {
  const LabTestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Home Lab Tests"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.location_on_outlined),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔎 SEARCH
            TextField(
              decoration: InputDecoration(
                hintText: "Search lab tests...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🎁 BANNER
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff00C9A7), Color(0xff5BE7C4)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Home Sample Collection\nFlat 20% OFF",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.biotech,
                        color: Colors.white, size: 50)
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// 🧩 CATEGORIES
            _sectionTitle("Categories"),
            const SizedBox(height: 14),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _categoryItem(Icons.bloodtype, "Blood"),
                  _categoryItem(Icons.monitor_heart, "Diabetes"),
                  _categoryItem(Icons.science, "Thyroid"),
                  _categoryItem(Icons.health_and_safety, "Full Body"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// 🧪 POPULAR TESTS
            _sectionTitle("Popular Tests"),
            const SizedBox(height: 14),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 210,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                return _testCard();
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const Text("See All", style: TextStyle(color: Colors.grey))
      ],
    );
  }
}

class _categoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _categoryItem(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Color(0xff00C9A7), size: 28),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12))
        ],
      ),
    );
  }
}

class _testCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Center(
              child: Icon(Icons.biotech,
                  size: 60, color: Colors.white),
            ),
          ),
          const Text("Complete Blood Count",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("₹499",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Book Test"),
          )
        ],
      ),
    );
  }
}
