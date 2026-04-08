import 'package:flutter/material.dart';
import 'package:mediscribe_app/services/auth_api_service.dart';
import 'package:mediscribe_app/services/appointment_service.dart';
import 'package:mediscribe_app/models/product.dart';
import 'package:mediscribe_app/models/lab_test.dart';

class UserProfile {
  UserProfile({
    required this.name,
    required this.email,
    required this.coins,
    this.city = 'Pune',
    this.role = 'patient',
    this.phone = '',
    this.bloodGroup = '',
    this.avatarUrl = '',
    this.specialty = '',
    this.fee = 0,
    this.bio = '',
    this.isOnline = false,
  });

  final String name;
  final String email;
  final int coins;
  final String city;
  final String role;
  final String phone;
  final String bloodGroup;
  final String avatarUrl;
  final String specialty;
  final int fee;
  final String bio;
  final bool isOnline;
}

class Appointment {
  Appointment({
    this.id = '',
    required this.doctorName,
    required this.specialty,
    required this.dateLabel,
    required this.timeLabel,
    required this.type,
    required this.location,
    this.status = 'upcoming',
    this.prescriptionText = '',
    this.doctorId = '',
    this.patientName,
    this.patientPhone,
    this.rating,
    this.review,
  });

  final String id;
  final String doctorName;
  final String specialty;
  final String dateLabel;
  final String timeLabel;
  final String type;
  final String location;
  final String status;
  final String prescriptionText;
  final String doctorId;
  final String? patientName;
  final String? patientPhone;
  final int? rating;
  final String? review;

  factory Appointment.fromApi(ApiAppointment a) => Appointment(
    id: a.id,
    doctorName: a.doctorName,
    specialty: a.specialty,
    dateLabel: a.dateLabel,
    timeLabel: a.timeLabel,
    type: a.type,
    location: a.location,
    status: a.status,
    prescriptionText: a.prescriptionText,
    doctorId: a.doctorId,
  );
}

class AppState extends ChangeNotifier {
  UserProfile? _currentUser;
  String? _token;
  final List<Appointment> _appointments = [];
  final List<Appointment> _doctorAppointments = [];
  final Map<String, _CartEntry> _cart = {};
  final List<LabTest> _bookedLabTests = [];
  String _lastPrescriptionText = '';
  bool _authLoading = false;
  String? _authError;

  UserProfile? get currentUser => _currentUser;
  String? get token => _token;
  String get role => _currentUser?.role ?? 'patient';
  bool get isDoctor => role == 'doctor';
  List<Appointment> get appointments => List.unmodifiable(_appointments);
  List<Appointment> get doctorAppointments => List.unmodifiable(_doctorAppointments);
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

  // ─── AUTH ───────────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (!email.contains('@') || password.length < 6) return false;
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
    _currentUser = _profileFromApi(response.user);
    await loadAppointments();
    notifyListeners();
    return true;
  }

  Future<bool> doctorLogin({
    required String email,
    required String password,
  }) async {
    if (!email.contains('@') || password.length < 6) return false;
    _authLoading = true;
    _authError = null;
    notifyListeners();
    final result = await AuthApiService.doctorLogin(email: email, password: password);
    _authLoading = false;
    if (result.data == null) {
      _authError = result.error ?? 'Login failed';
      notifyListeners();
      return false;
    }
    final response = result.data!;
    _token = response.token;
    _currentUser = _profileFromApi(response.user);
    await loadDoctorAppointments();
    notifyListeners();
    return true;
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().length < 2 || !email.contains('@') || password.length < 6) return false;
    _authLoading = true;
    _authError = null;
    notifyListeners();
    final result = await AuthApiService.signup(name: name, email: email, password: password);
    _authLoading = false;
    if (result.data == null) {
      _authError = result.error ?? 'Signup failed';
      notifyListeners();
      return false;
    }
    final response = result.data!;
    _token = response.token;
    _currentUser = _profileFromApi(response.user);
    notifyListeners();
    return true;
  }

  Future<bool> doctorSignup({
    required String name,
    required String email,
    required String password,
    required String specialty,
    int experience = 0,
    int fee = 500,
    String bio = '',
  }) async {
    if (name.trim().length < 2 || !email.contains('@') || password.length < 6) return false;
    _authLoading = true;
    _authError = null;
    notifyListeners();
    final result = await AuthApiService.doctorSignup(
      name: name, 
      email: email, 
      password: password, 
      specialty: specialty,
      experience: experience,
      fee: fee,
      bio: bio,
    );
    _authLoading = false;
    if (result.data == null) {
      _authError = result.error ?? 'Signup failed';
      notifyListeners();
      return false;
    }
    final response = result.data!;
    _token = response.token;
    _currentUser = _profileFromApi(response.user);
    notifyListeners();
    return true;
  }

  void logout() {
    _token = null;
    _currentUser = null;
    _appointments.clear();
    _doctorAppointments.clear();
    _cart.clear();
    _bookedLabTests.clear();
    notifyListeners();
  }

  UserProfile _profileFromApi(ApiUser u) => UserProfile(
    name: u.name,
    email: u.email,
    coins: u.coins,
    city: u.city,
    role: u.role,
    phone: u.phone,
    bloodGroup: u.bloodGroup,
    avatarUrl: u.avatarUrl,
    specialty: u.specialty,
    fee: u.fee,
    bio: u.bio,
    isOnline: u.isOnline,
  );

  // ─── APPOINTMENTS ─────────────────────────────────────────────
  Future<void> loadAppointments() async {
    if (_token == null) return;
    final list = await AppointmentService.fetchMine(_token!);
    _appointments
      ..clear()
      ..addAll(list.map(Appointment.fromApi));
    notifyListeners();
  }

  Future<void> loadDoctorAppointments() async {
    if (_token == null) return;
    final list = await AppointmentService.fetchDoctorAppointments(_token!);
    _doctorAppointments
      ..clear()
      ..addAll(list.map(Appointment.fromApi));
    notifyListeners();
  }

  Future<bool> bookAppointment(Appointment appointment) async {
    if (_token != null && appointment.doctorId.isNotEmpty) {
      final result = await AppointmentService.book(
        token: _token!,
        doctorId: appointment.doctorId,
        dateLabel: appointment.dateLabel,
        timeLabel: appointment.timeLabel,
        type: appointment.type,
        location: appointment.location,
      );
      if (result != null) {
        _appointments.insert(0, Appointment.fromApi(result));
        notifyListeners();
        return true;
      }
      return false;
    }
    // Fallback: local insert if no doctorId
    _appointments.insert(0, appointment);
    notifyListeners();
    return true;
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    if (_token == null) return false;
    final ok = await AppointmentService.updateStatus(_token!, appointmentId, 'cancelled');
    if (ok) await loadAppointments();
    return ok;
  }

  void setPrescriptionText(String text) {
    _lastPrescriptionText = text.trim();
    notifyListeners();
  }

  // ─── CART ───────────────────────────────────────────────────
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

  // ─── LAB TESTS ──────────────────────────────────────────────
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
