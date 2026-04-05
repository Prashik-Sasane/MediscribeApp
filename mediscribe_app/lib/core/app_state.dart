import 'package:flutter/material.dart';
import 'package:mediscribe_app/services/auth_api_service.dart';
import 'package:mediscribe_app/models/product.dart';
import 'package:mediscribe_app/models/lab_test.dart';

class UserProfile {
  UserProfile({
    required this.name,
    required this.email,
    required this.coins,
    this.city = 'Pune',
  });

  final String name;
  final String email;
  final int coins;
  final String city;
}

class Appointment {
  Appointment({
    required this.doctorName,
    required this.specialty,
    required this.dateLabel,
    required this.timeLabel,
    required this.type,
    required this.location,
  });

  final String doctorName;
  final String specialty;
  final String dateLabel;
  final String timeLabel;
  final String type;
  final String location;
}

class AppState extends ChangeNotifier {
  UserProfile? _currentUser;
  String? _token;
  final List<Appointment> _appointments = [];
  final Map<String, _CartEntry> _cart = {};
  final List<LabTest> _bookedLabTests = [];
  String _lastPrescriptionText = '';
  bool _authLoading = false;
  String? _authError;

  UserProfile? get currentUser => _currentUser;
  String? get token => _token;
  List<Appointment> get appointments => List.unmodifiable(_appointments);
  String get lastPrescriptionText => _lastPrescriptionText;
  bool get authLoading => _authLoading;
  String? get authError => _authError;
  Map<String, int> get cartItems =>
      Map.unmodifiable(_cart.map((k, v) => MapEntry(k, v.quantity)));
  int get cartCount => _cart.values.fold(0, (sum, e) => sum + e.quantity);
  int get cartSubtotal =>
      _cart.values.fold(0, (sum, e) => sum + (e.product.price * e.quantity));
  List<_CartEntry> get cartEntries => List.unmodifiable(_cart.values);
  List<LabTest> get bookedLabTests => List.unmodifiable(_bookedLabTests);

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (!email.contains('@') || password.length < 6) {
      return false;
    }
    _authLoading = true;
    _authError = null;
    notifyListeners();
    final result = await AuthApiService.login(email: email, password: password);
    _authLoading = false;
    if (result.data == null) {
      _authError = result.error ?? 'Login failed';
      notifyListeners();
      return false;
    }
    final response = result.data!;
    _token = response.token;
    _currentUser = UserProfile(
      name: response.user.name,
      email: response.user.email,
      coins: response.user.coins,
      city: response.user.city,
    );
    _appointments
      ..clear()
      ..addAll(response.user.appointments);
    notifyListeners();
    return true;
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().length < 2 || !email.contains('@') || password.length < 6) {
      return false;
    }
    _authLoading = true;
    _authError = null;
    notifyListeners();
    final result = await AuthApiService.signup(
      name: name,
      email: email,
      password: password,
    );
    _authLoading = false;
    if (result.data == null) {
      _authError = result.error ?? 'Signup failed';
      notifyListeners();
      return false;
    }
    final response = result.data!;
    _token = response.token;
    _currentUser = UserProfile(
      name: response.user.name,
      email: response.user.email,
      coins: response.user.coins,
      city: response.user.city,
    );
    _appointments
      ..clear()
      ..addAll(response.user.appointments);
    notifyListeners();
    return true;
  }

  void setPrescriptionText(String text) {
    _lastPrescriptionText = text.trim();
    notifyListeners();
  }

  void bookAppointment(Appointment appointment) {
    _appointments.insert(0, appointment);
    notifyListeners();
  }

  void addToCart(Product product) {
    final existing = _cart[product.id];
    if (existing == null) {
      _cart[product.id] = _CartEntry(product: product, quantity: 1);
    } else {
      existing.quantity += 1;
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final entry = _cart[productId];
    if (entry == null) return;
    if (quantity <= 0) {
      _cart.remove(productId);
    } else {
      entry.quantity = quantity;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void bookLabTest(LabTest test) {
    final alreadyBooked = _bookedLabTests.any((t) => t.id == test.id);
    if (!alreadyBooked) {
      _bookedLabTests.insert(0, test);
      notifyListeners();
    }
  }
}

class _CartEntry {
  _CartEntry({required this.product, required this.quantity});
  final Product product;
  int quantity;
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState appState,
    required Widget child,
  }) : super(notifier: appState, child: child);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing in widget tree.');
    return scope!.notifier!;
  }
}
