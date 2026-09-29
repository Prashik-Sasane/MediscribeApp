import React from 'react';
import { Routes, Route, Navigate, useLocation } from 'react-router-dom';
import Navbar from './components/layout/Navbar';
import Footer from './components/layout/Footer';
import SplashScreen from './screens/SplashScreen';
import LoginScreen from './screens/LoginScreen';
import HomeScreen from './screens/HomeScreen';
import DoctorListScreen from './screens/DoctorListScreen';
import DoctorDetailScreen from './screens/DoctorDetailScreen';
import AppointmentsScreen from './screens/AppointmentsScreen';
import PharmacyScreen from './screens/PharmacyScreen';
import CartScreen from './screens/CartScreen';
import UploadScreen from './screens/UploadScreen';
import ProfileScreen from './screens/ProfileScreen';
import LabTestsScreen from './screens/LabTestsScreen';
import PaymentScreen from './screens/PaymentScreen';
import useAppStore from './store/useAppStore';

const ProtectedRoute = ({ children, requireDoctor = false }) => {
  const { currentUser, isDoctor } = useAppStore();
  const location = useLocation();

  if (!currentUser) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  if (requireDoctor && !isDoctor) {
    return <Navigate to="/home" replace />;
  }

  return children;
};

const PublicOnly = ({ children }) => {
  const { currentUser } = useAppStore();
  if (currentUser) {
    return <Navigate to="/home" replace />;
  }
  return children;
};

const AppLayout = ({ children }) => {
  const location = useLocation();
  const isFullScreen = location.pathname === '/splash' || location.pathname === '/login';

  if (isFullScreen) {
    return <>{children}</>;
  }

  return (
    <div className="min-h-screen flex flex-col bg-gray-50 dark:bg-background-dark">
      <Navbar />
      <main className="flex-1">
        {children}
      </main>
      <Footer />
    </div>
  );
};

const NotFound = () => {
  return (
    <div className="min-h-[60vh] flex items-center justify-center p-4">
      <div className="text-center max-w-md">
        <div className="text-9xl font-black text-primary/10 dark:text-primary-light/10 mb-4 leading-none">
          404
        </div>
        <h1 className="text-3xl font-bold text-text-primary dark:text-text-dark-primary mb-3">
          Page Not Found
        </h1>
        <p className="text-text-secondary dark:text-text-dark-secondary mb-8">
          The page you're looking for doesn't exist or has been moved.
        </p>
        <button
          onClick={() => window.location.href = '/home'}
          className="btn-primary inline-flex items-center gap-2"
        >
          Go to Home
        </button>
      </div>
    </div>
  );
};

const App = () => {
  return (
    <AppLayout>
      <Routes>
        <Route path="/" element={<Navigate to="/splash" replace />} />
        <Route
          path="/splash"
          element={<SplashScreen />}
        />
        <Route
          path="/login"
          element={
            <PublicOnly>
              <LoginScreen />
            </PublicOnly>
          }
        />
        <Route
          path="/home"
          element={
            <ProtectedRoute>
              <HomeScreen />
            </ProtectedRoute>
          }
        />
        <Route
          path="/"
          element={
            <ProtectedRoute>
              <HomeScreen />
            </ProtectedRoute>
          }
        />
        <Route
          path="/doctors"
          element={
            <ProtectedRoute>
              <DoctorListScreen />
            </ProtectedRoute>
          }
        />
        <Route
          path="/doctors/:id"
          element={
            <ProtectedRoute>
              <DoctorDetailScreen />
            </ProtectedRoute>
          }
        />
        <Route
          path="/appointments"
          element={
            <ProtectedRoute>
              <AppointmentsScreen />
            </ProtectedRoute>
          }
        />
        <Route
          path="/pharmacy"
          element={
            <ProtectedRoute>
              <PharmacyScreen />
            </ProtectedRoute>
          }
        />
        <Route
          path="/cart"
          element={
            <ProtectedRoute>
              <CartScreen />
            </ProtectedRoute>
          }
        />
        <Route
          path="/lab-tests"
          element={
            <ProtectedRoute>
              <LabTestsScreen />
            </ProtectedRoute>
          }
        />
        <Route
          path="/upload"
          element={
            <ProtectedRoute>
              <UploadScreen />
            </ProtectedRoute>
          }
        />
        <Route
          path="/profile"
          element={
            <ProtectedRoute>
              <ProfileScreen />
            </ProtectedRoute>
          }
        />
        <Route
          path="/payment"
          element={
            <ProtectedRoute>
              <PaymentScreen />
            </ProtectedRoute>
          }
        />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </AppLayout>
  );
};

export default App;
