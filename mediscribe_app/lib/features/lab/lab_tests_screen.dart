// import 'package:flutter/material.dart';
// import 'package:mediscribe_app/core/app_state.dart';
// import 'package:mediscribe_app/models/lab_test.dart';
// import 'package:mediscribe_app/services/lab_service.dart';

// class LabTestsScreen extends StatefulWidget {
//   const LabTestsScreen({super.key});

//   @override
//   State<LabTestsScreen> createState() => _LabTestsScreenState();
// }

// class _LabTestsScreenState extends State<LabTestsScreen> {
//   final TextEditingController _search = TextEditingController();
//   final List<String> _categories = const ['All', 'Blood', 'Diabetes', 'Thyroid', 'Full Body'];

//   String _selectedCategory = 'All';
//   bool _loading = true;
//   String? _error;
//   List<LabTest> _tests = const [];

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   @override
//   void dispose() {
//     _search.dispose();
//     super.dispose();
//   }

//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     final tests = await LabService.fetchLabTests(
//       category: _selectedCategory == 'All' ? null : _selectedCategory,
//       query: _search.text.trim(),
//       tag: 'popular',
//     );
//     final all = await LabService.fetchLabTests(
//       category: _selectedCategory == 'All' ? null : _selectedCategory,
//       query: _search.text.trim(),
//     );
//     setState(() {
//       _loading = false;
//       _tests = all;
//       if (all.isEmpty) _error = 'No lab tests found (or backend unreachable).';
//     });
//   }

//   List<LabTest> get _popular =>
//       _tests.where((t) => t.tags.map((e) => e.toLowerCase()).contains('popular')).toList();

//   @override
//   Widget build(BuildContext context) {
//     final appState = AppScope.of(context);
//     final popular = _popular.isEmpty ? _tests.take(6).toList() : _popular;

//     return Scaffold(
//       backgroundColor: const Color(0xFF0B1220),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0B1220),
//         title: const Text("Home Lab Tests"),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _load,
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
//           children: [
//             _SearchBar(
//               controller: _search,
//               hint: 'Search lab tests...',
//               onChanged: (_) => _load(),
//             ),
//             const SizedBox(height: 14),
//             const _GradientBanner(
//               title: 'Flat 20% OFF',
//               subtitle: 'Home sample collection in 60 mins',
//               icon: Icons.biotech_outlined,
//               colors: [Color(0xFF00C9A7), Color(0xFF3B82F6)],
//             ),
//             const SizedBox(height: 18),
//             _SectionTitle(title: 'Categories'),
//             const SizedBox(height: 12),
//             SizedBox(
//               height: 44,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: _categories.length,
//                 separatorBuilder: (_, __) => const SizedBox(width: 10),
//                 itemBuilder: (context, i) {
//                   final c = _categories[i];
//                   final selected = c == _selectedCategory;
//                   return ChoiceChip(
//                     label: Text(c),
//                     selected: selected,
//                     onSelected: (_) {
//                       setState(() => _selectedCategory = c);
//                       _load();
//                     },
//                     labelStyle: TextStyle(
//                       color: selected ? Colors.white : Colors.white70,
//                       fontWeight: FontWeight.w700,
//                     ),
//                     selectedColor: const Color(0xFF00C9A7),
//                     backgroundColor: Colors.white.withOpacity(0.06),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(999),
//                       side: BorderSide(color: Colors.white.withOpacity(0.08)),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 18),
//             if (_loading)
//               const Padding(
//                 padding: EdgeInsets.only(top: 30),
//                 child: Center(child: CircularProgressIndicator()),
//               )
//             else if (_error != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 30),
//                 child: Center(
//                   child: Column(
//                     children: [
//                       Text(_error!, style: const TextStyle(color: Colors.white70)),
//                       const SizedBox(height: 12),
//                       ElevatedButton(onPressed: _load, child: const Text('Retry')),
//                     ],
//                   ),
//                 ),
//               )
//             else ...[
//               const _SectionTitle(title: 'Popular Tests'),
//               const SizedBox(height: 12),
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: popular.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   mainAxisExtent: 270,
//                   crossAxisSpacing: 14,
//                   mainAxisSpacing: 14,
//                 ),
//                 itemBuilder: (context, index) {
//                   final t = popular[index];
//                   final booked = appState.bookedLabTests.any((b) => b.id == t.id);
//                   return _LabCard(
//                     test: t,
//                     booked: booked,
//                     onBook: booked
//                         ? null
//                         : () {
//                             appState.bookLabTest(t);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Booked: ${t.name}')),
//                             );
//                           },
//                   );
//                 },
//               ),
//               const SizedBox(height: 18),
//               const _SectionTitle(title: 'All Tests'),
//               const SizedBox(height: 12),
//               ..._tests.map((t) {
//                 final booked = appState.bookedLabTests.any((b) => b.id == t.id);
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: _LabListTile(
//                     test: t,
//                     booked: booked,
//                     onBook: booked
//                         ? null
//                         : () {
//                             appState.bookLabTest(t);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Booked: ${t.name}')),
//                             );
//                           },
//                   ),
//                 );
//               }),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   const _SectionTitle({required this.title});
//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title,
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 18,
//         fontWeight: FontWeight.w800,
//       ),
//     );
//   }
// }

// class _SearchBar extends StatelessWidget {
//   const _SearchBar({
//     required this.controller,
//     required this.hint,
//     required this.onChanged,
//   });

//   final TextEditingController controller;
//   final String hint;
//   final ValueChanged<String> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.06),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.white.withOpacity(0.08)),
//       ),
//       child: TextField(
//         controller: controller,
//         style: const TextStyle(color: Colors.white),
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(color: Colors.white54),
//           prefixIcon: const Icon(Icons.search, color: Colors.white70),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         ),
//       ),
//     );
//   }
// }

// class _GradientBanner extends StatelessWidget {
//   const _GradientBanner({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.colors,
//   });

//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final List<Color> colors;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 132,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(22),
//         gradient: LinearGradient(colors: colors),
//         boxShadow: [
//           BoxShadow(
//             color: colors.last.withOpacity(0.35),
//             blurRadius: 18,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(18),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(color: Colors.white70, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               height: 56,
//               width: 56,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: Icon(icon, color: Colors.white, size: 30),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _LabCard extends StatelessWidget {
//   const _LabCard({required this.test, required this.booked, required this.onBook});
//   final LabTest test;
//   final bool booked;
//   final VoidCallback? onBook;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF111B2E),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.06)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Image.network(
//                   test.imageUrl,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     color: Colors.white.withOpacity(0.05),
//                     child: const Center(
//                       child: Icon(Icons.biotech_outlined, color: Colors.white54),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               test.name,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               test.description,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(color: Colors.white60, fontSize: 12),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Text(
//                   '₹${test.price}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const Spacer(),
//                 SizedBox(
//                   height: 36,
//                   child: ElevatedButton(
//                     onPressed: onBook,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: booked ? Colors.white24 : const Color(0xFF00C9A7),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: Text(booked ? 'Booked' : 'Book'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _LabListTile extends StatelessWidget {
//   const _LabListTile({required this.test, required this.booked, required this.onBook});
//   final LabTest test;
//   final bool booked;
//   final VoidCallback? onBook;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF111B2E),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: Colors.white.withOpacity(0.06)),
//       ),
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(14),
//             child: Image.network(
//               test.imageUrl,
//               height: 66,
//               width: 66,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Container(
//                 height: 66,
//                 width: 66,
//                 color: Colors.white.withOpacity(0.05),
//                 child: const Icon(Icons.biotech_outlined, color: Colors.white54),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   test.name,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   test.description,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(color: Colors.white60, fontSize: 12),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '₹${test.price}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           SizedBox(
//             height: 38,
//             child: ElevatedButton(
//               onPressed: onBook,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: booked ? Colors.white24 : const Color(0xFF00C9A7),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 elevation: 0,
//               ),
//               child: Text(booked ? 'Booked' : 'Book'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
