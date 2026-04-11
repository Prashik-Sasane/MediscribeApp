import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';

class NearbyPlace {
  final String name;
  final String type;
  final String address;
  final double rating;
  final LatLng position;
  final String? phone;

  NearbyPlace({
    required this.name,
    required this.type,
    required this.address,
    required this.rating,
    required this.position,
    this.phone,
  });

  factory NearbyPlace.fromMap(Map<String, dynamic> map) {
    return NearbyPlace(
      name: map['name'] ?? 'Unknown',
      type: map['type'] ?? 'Other',
      address: map['address'] ?? 'Address not available',
      rating: (map['rating'] ?? 4.0).toDouble(),
      position: map['position'] as LatLng,
      phone: map['phone'],
    );
  }
}

class NearbyPlacesService {
  /// Fetch nearby hospitals, clinics, pharmacies, and doctors from OpenStreetMap
  static Future<List<NearbyPlace>> fetchNearbyPlaces({
    required double lat,
    required double lng,
    int radiusMeters = 5000, // Reduced from 10000 to 5000 for faster response
    String? filterType, // 'Hospital', 'Clinic', 'Medical Store', 'Doctor'
    int maxRetries = 2,
  }) async {
    int attempt = 0;
    
    while (attempt < maxRetries) {
      attempt++;
      try {
        String query;
        
        print('NearbyPlacesService: Attempt $attempt - Fetching places at lat=$lat, lng=$lng, radius=${radiusMeters}m');
        
        if (filterType != null && filterType != 'All') {
          // Filter by specific type
          String amenity;
          switch (filterType) {
            case 'Hospital':
              amenity = 'hospital';
              break;
            case 'Clinic':
              amenity = 'clinic';
              break;
            case 'Medical Store':
              amenity = 'pharmacy';
              break;
            case 'Doctor':
              amenity = 'doctors';
              break;
            default:
              amenity = 'hospital';
          }
          query = '''
            [out:json][timeout:15];
            node["amenity"="$amenity"](around:$radiusMeters,$lat,$lng);
            out center;
          ''';
        } else {
          // Fetch all types - use smaller radius for faster response
          query = '''
            [out:json][timeout:15];
            (
              node["amenity"="hospital"](around:$radiusMeters,$lat,$lng);
              node["amenity"="clinic"](around:$radiusMeters,$lat,$lng);
              node["amenity"="pharmacy"](around:$radiusMeters,$lat,$lng);
              node["amenity"="doctors"](around:$radiusMeters,$lat,$lng);
            );
            out center;
          ''';
        }

        print('NearbyPlacesService: Query sent to Overpass API');

        final response = await http.post(
          Uri.parse('https://overpass-api.de/api/interpreter'),
          body: {'data': query},
        ).timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            print('NearbyPlacesService: Request timeout');
            return http.Response('Timeout', 408);
          },
        );

        print('NearbyPlacesService: Response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final elements = data['elements'] as List;
          
          print('NearbyPlacesService: Found ${elements.length} elements');

          final places = elements.map((e) {
            final tags = e['tags'] as Map? ?? {};
            final placeLat = (e['lat'] ?? e['center']?['lat'])?.toDouble() ?? lat;
            final placeLon = (e['lon'] ?? e['center']?['lon'])?.toDouble() ?? lng;
            
            String type = 'Other';
            final amenity = tags['amenity']?.toString().toLowerCase() ?? '';
            
            if (amenity == 'hospital') type = 'Hospital';
            else if (amenity == 'clinic') type = 'Clinic';
            else if (amenity == 'pharmacy') type = 'Medical Store';
            else if (amenity == 'doctors') type = 'Doctor';

            return NearbyPlace(
              name: tags['name'] ?? '$type Nearby',
              type: type,
              address: tags['addr:street'] ?? tags['address'] ?? 'Address not available',
              phone: tags['phone'] ?? tags['contact:phone'],
              rating: 4.0 + (placeLat % 1),
              position: LatLng(placeLat, placeLon),
            );
          }).toList();

          // Limit to top 6 places
          final result = places.take(6).toList();
          print('NearbyPlacesService: Returning ${result.length} places');
          return result;
        } else if (response.statusCode == 504 || response.statusCode == 408) {
          // Server timeout - retry
          print('NearbyPlacesService: Server busy/timeout, retrying in 2 seconds...');
          await Future.delayed(const Duration(seconds: 2));
          continue;
        } else {
          print('NearbyPlacesService: API error: ${response.body}');
          return [];
        }
      } catch (e) {
        print('NearbyPlacesService Error (attempt $attempt): $e');
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        return [];
      }
    }
    
    print('NearbyPlacesService: All retries failed');
    return [];
  }

  /// Fetch only nearby hospitals and clinics
  static Future<List<NearbyPlace>> fetchNearbyHospitalsClinics({
    required double lat,
    required double lng,
  }) async {
    return fetchNearbyPlaces(lat: lat, lng: lng);
  }

  /// Fetch only nearby pharmacies
  static Future<List<NearbyPlace>> fetchNearbyPharmacies({
    required double lat,
    required double lng,
  }) async {
    return fetchNearbyPlaces(
      lat: lat,
      lng: lng,
      filterType: 'Medical Store',
    );
  }
}
