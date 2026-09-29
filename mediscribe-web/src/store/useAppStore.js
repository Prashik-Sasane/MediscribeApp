import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { authService } from '../services/authService';
import { appointmentService } from '../services/appointmentService';

export const useAppStore = create(
  persist(
    (set, get) => ({
      currentUser: null,
      token: null,
      appointments: [],
      doctorAppointments: [],
      cart: {},
      bookedLabTests: [],
      lastPrescriptionText: '',
      authLoading: false,
      authError: null,

      get role() {
        return get().currentUser?.role || 'patient';
      },

      get isDoctor() {
        return get().role === 'doctor';
      },

      get cartCount() {
        return Object.values(get().cart).reduce((sum, entry) => sum + entry.quantity, 0);
      },

      get cartSubtotal() {
        return Object.values(get().cart).reduce(
          (sum, entry) => sum + entry.product.price * entry.quantity,
          0
        );
      },

      get cartEntries() {
        return Object.values(get().cart);
      },

      login: async (email, password) => {
        set({ authLoading: true, authError: null });
        try {
          const result = await authService.login(email, password);
          localStorage.setItem('mediscribe_token', result.token);
          localStorage.setItem('mediscribe_user', JSON.stringify(result.user));
          set({
            token: result.token,
            currentUser: result.user,
            authLoading: false,
          });
          await get().loadAppointments();
          return true;
        } catch (error) {
          set({
            authError: error.response?.data?.message || 'Login failed.',
            authLoading: false,
          });
          return false;
        }
      },

      doctorLogin: async (email, password) => {
        set({ authLoading: true, authError: null });
        try {
          const result = await authService.doctorLogin(email, password);
          localStorage.setItem('mediscribe_token', result.token);
          localStorage.setItem('mediscribe_user', JSON.stringify(result.user));
          set({
            token: result.token,
            currentUser: result.user,
            authLoading: false,
          });
          await get().loadDoctorAppointments();
          return true;
        } catch (error) {
          set({
            authError: error.response?.data?.message || 'Login failed.',
            authLoading: false,
          });
          return false;
        }
      },

      signup: async (name, email, password) => {
        set({ authLoading: true, authError: null });
        try {
          const result = await authService.signup(name, email, password);
          localStorage.setItem('mediscribe_token', result.token);
          localStorage.setItem('mediscribe_user', JSON.stringify(result.user));
          set({
            token: result.token,
            currentUser: result.user,
            authLoading: false,
          });
          return true;
        } catch (error) {
          set({
            authError: error.response?.data?.message || 'Signup failed.',
            authLoading: false,
          });
          return false;
        }
      },

      doctorSignup: async (name, email, password, specialty, experience = 0, fee = 500, bio = '') => {
        set({ authLoading: true, authError: null });
        try {
          const result = await authService.doctorSignup(name, email, password, specialty, experience, fee, bio);
          localStorage.setItem('mediscribe_token', result.token);
          localStorage.setItem('mediscribe_user', JSON.stringify(result.user));
          set({
            token: result.token,
            currentUser: result.user,
            authLoading: false,
          });
          return true;
        } catch (error) {
          set({
            authError: error.response?.data?.message || 'Signup failed.',
            authLoading: false,
          });
          return false;
        }
      },

      logout: () => {
        localStorage.removeItem('mediscribe_token');
        localStorage.removeItem('mediscribe_user');
        localStorage.removeItem('mediscribe-storage');
        set({
          token: null,
          currentUser: null,
          appointments: [],
          doctorAppointments: [],
          cart: {},
          bookedLabTests: [],
          authError: null,
        });
      },

      updateUserProfile: (updates) => {
        const { currentUser } = get();
        if (!currentUser) return;
        const updatedUser = { ...currentUser, ...updates };
        localStorage.setItem('mediscribe_user', JSON.stringify(updatedUser));
        set({
          currentUser: updatedUser,
        });
      },

      loadAppointments: async () => {
        const { token } = get();
        if (!token) return;
        try {
          const appointments = await appointmentService.fetchMine();
          set({ appointments });
        } catch (error) {
          console.error('Failed to load appointments:', error);
        }
      },

      loadDoctorAppointments: async () => {
        const { token } = get();
        if (!token) return;
        try {
          const appointments = await appointmentService.fetchDoctorAppointments();
          set({ doctorAppointments: appointments });
        } catch (error) {
          console.error('Failed to load doctor appointments:', error);
        }
      },

      bookAppointment: async (appointment) => {
        const { token, appointments } = get();
        try {
          if (token && appointment.doctorId) {
            const result = await appointmentService.book({
              doctorId: appointment.doctorId,
              dateLabel: appointment.dateLabel,
              timeLabel: appointment.timeLabel,
              type: appointment.type,
              location: appointment.location,
            });
            if (result) {
              set({ appointments: [result, ...appointments] });
              return true;
            }
            return false;
          }
          set({ appointments: [appointment, ...appointments] });
          return true;
        } catch (error) {
          console.error('Failed to book appointment:', error);
          return false;
        }
      },

      cancelAppointment: async (appointmentId) => {
        const { token } = get();
        if (!token) return false;
        try {
          const ok = await appointmentService.updateStatus(appointmentId, 'cancelled');
          if (ok) await get().loadAppointments();
          return ok;
        } catch (error) {
          return false;
        }
      },

      setPrescriptionText: (text) => {
        set({ lastPrescriptionText: text.trim() });
      },

      addToCart: (product) => {
        const { cart } = get();
        const existing = cart[product.id];
        if (existing) {
          set({
            cart: {
              ...cart,
              [product.id]: { ...existing, quantity: existing.quantity + 1 },
            },
          });
        } else {
          set({
            cart: {
              ...cart,
              [product.id]: { product, quantity: 1 },
            },
          });
        }
      },

      removeFromCart: (productId) => {
        const { cart } = get();
        const newCart = { ...cart };
        delete newCart[productId];
        set({ cart: newCart });
      },

      updateQuantity: (productId, quantity) => {
        const { cart } = get();
        const entry = cart[productId];
        if (!entry) return;
        const newCart = { ...cart };
        if (quantity <= 0) {
          delete newCart[productId];
        } else {
          newCart[productId] = { ...entry, quantity };
        }
        set({ cart: newCart });
      },

      clearCart: () => {
        set({ cart: {} });
      },

      bookLabTest: (test) => {
        const { bookedLabTests } = get();
        const alreadyBooked = bookedLabTests.some((t) => t.id === test.id);
        if (!alreadyBooked) {
          set({ bookedLabTests: [test, ...bookedLabTests] });
        }
      },

      clearAuthError: () => {
        set({ authError: null });
      },
    }),
    {
      name: 'mediscribe-storage',
      partialize: (state) => ({
        currentUser: state.currentUser,
        token: state.token,
        cart: state.cart,
        bookedLabTests: state.bookedLabTests,
      }),
    }
  )
);

export default useAppStore;
