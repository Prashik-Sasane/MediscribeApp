import 'package:flutter/material.dart';

class SearchResultTile extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = result['type'] as String;
    final icon = _getIcon(type);
    final color = _getColor(type);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          image: result['imageUrl'] != null && result['imageUrl'].toString().startsWith('http')
              ? DecorationImage(image: NetworkImage(result['imageUrl']), fit: BoxFit.cover)
              : null,
        ),
        child: result['imageUrl'] == null || !result['imageUrl'].toString().startsWith('http')
            ? Icon(icon, color: color)
            : null,
      ),
      title: Text(
        result['title'] ?? 'Unknown',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        result['subtitle'] ?? '',
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              type.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
          if (result['price'] != null) ...[
            const SizedBox(height: 4),
            Text(
              "₹${result['price']}",
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ]
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'doctor': return Icons.person_search_rounded;
      case 'medicine': return Icons.medication_rounded;
      case 'lab_test': return Icons.science_rounded;
      default: return Icons.search_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'doctor': return Colors.blue;
      case 'medicine': return Colors.green;
      case 'lab_test': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
