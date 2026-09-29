import React from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import {
  Home,
  Calendar,
  FileScan,
  User,
  LogOut,
  ShoppingCart,
  Stethoscope,
  Pill,
  Menu,
  X,
} from 'lucide-react';
import clsx from 'clsx';
import useAppStore from '../../store/useAppStore';

const Navbar = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { currentUser, logout, isDoctor, cartCount } = useAppStore();
  const [mobileMenuOpen, setMobileMenuOpen] = React.useState(false);

  const patientNavItems = [
    { path: '/', label: 'Home', icon: Home },
    { path: '/doctors', label: 'Doctors', icon: Stethoscope },
    { path: '/appointments', label: 'Appointments', icon: Calendar },
    { path: '/pharmacy', label: 'Pharmacy', icon: Pill },
    { path: '/upload', label: 'Scan', icon: FileScan },
  ];

  const doctorNavItems = [
    { path: '/', label: 'Dashboard', icon: Home },
    { path: '/appointments', label: 'Appointments', icon: Calendar },
    { path: '/upload', label: 'Scan', icon: FileScan },
  ];

  const navItems = isDoctor ? doctorNavItems : patientNavItems;

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const isActive = (path) => {
    if (path === '/home') {
      return location.pathname === '/home' || location.pathname === '/';
    }
    return location.pathname.startsWith(path);
  };

  if (!currentUser) return null;

  return (
    <nav className="sticky top-0 z-50 bg-white/80 dark:bg-background-dark/80 backdrop-blur-lg border-b border-border dark:border-border-dark">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex items-center">
            <Link to="/home" className="flex items-center gap-2">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-primary to-primary-light flex items-center justify-center">
                <Stethoscope className="w-6 h-6 text-white" />
              </div>
              <span className="text-xl font-bold text-primary dark:text-primary-light hidden sm:block">
                Mediscribe
              </span>
            </Link>

            <div className="hidden md:flex ml-10 space-x-1">
              {navItems.map((item) => (
                <Link
                  key={item.path}
                  to={item.path}
                  className={clsx(
                    'nav-link',
                    isActive(item.path) && 'nav-link-active'
                  )}
                >
                  <item.icon className="w-4 h-4" />
                  <span className="font-medium">{item.label}</span>
                </Link>
              ))}
            </div>
          </div>

          <div className="flex items-center gap-4">
            {!isDoctor && (
              <Link
                to="/cart"
                className="relative p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-surface-dark transition-colors"
              >
                <ShoppingCart className="w-5 h-5 text-text-secondary dark:text-text-dark-secondary" />
                {cartCount > 0 && (
                  <span className="absolute -top-1 -right-1 w-5 h-5 bg-primary text-white text-xs font-bold rounded-full flex items-center justify-center">
                    {cartCount}
                  </span>
                )}
              </Link>
            )}

            <Link
              to="/profile"
              className="flex items-center gap-2 p-1 rounded-lg hover:bg-gray-100 dark:hover:bg-surface-dark transition-colors"
            >
              {currentUser.avatarUrl ? (
                <img
                  src={currentUser.avatarUrl}
                  alt={currentUser.name}
                  className="w-9 h-9 rounded-full object-cover"
                />
              ) : (
                <div className="w-9 h-9 rounded-full bg-primary/10 flex items-center justify-center">
                  <User className="w-5 h-5 text-primary dark:text-primary-light" />
                </div>
              )}
              <div className="hidden sm:block">
                <p className="text-sm font-medium text-text-primary dark:text-text-dark-primary leading-tight">
                  {currentUser.name}
                </p>
                <p className="text-xs text-text-secondary dark:text-text-dark-secondary capitalize">
                  {currentUser.role}
                </p>
              </div>
            </Link>

            <button
              onClick={handleLogout}
              className="hidden sm:flex items-center gap-1 p-2 text-text-secondary dark:text-text-dark-secondary hover:text-red-600 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors"
              title="Logout"
            >
              <LogOut className="w-5 h-5" />
            </button>

            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-surface-dark transition-colors"
            >
              {mobileMenuOpen ? (
                <X className="w-6 h-6" />
              ) : (
                <Menu className="w-6 h-6" />
              )}
            </button>
          </div>
        </div>
      </div>

      {mobileMenuOpen && (
        <div className="md:hidden border-t border-border dark:border-border-dark bg-white dark:bg-background-dark">
          <div className="px-4 py-3 space-y-1">
            {navItems.map((item) => (
              <Link
                key={item.path}
                to={item.path}
                onClick={() => setMobileMenuOpen(false)}
                className={clsx(
                  'nav-link',
                  isActive(item.path) && 'nav-link-active'
                )}
              >
                <item.icon className="w-5 h-5" />
                <span className="font-medium">{item.label}</span>
              </Link>
            ))}
            {!isDoctor && (
              <Link
                to="/cart"
                onClick={() => setMobileMenuOpen(false)}
                className={clsx(
                  'nav-link',
                  isActive('/cart') && 'nav-link-active'
                )}
              >
                <ShoppingCart className="w-5 h-5" />
                <span className="font-medium">Cart ({cartCount})</span>
              </Link>
            )}
            <Link
              to="/profile"
              onClick={() => setMobileMenuOpen(false)}
              className={clsx(
                'nav-link',
                isActive('/profile') && 'nav-link-active'
              )}
            >
              <User className="w-5 h-5" />
              <span className="font-medium">Profile</span>
            </Link>
            <button
              onClick={() => {
                handleLogout();
                setMobileMenuOpen(false);
              }}
              className="nav-link w-full text-left text-red-600 dark:text-red-400"
            >
              <LogOut className="w-5 h-5" />
              <span className="font-medium">Logout</span>
            </button>
          </div>
        </div>
      )}
    </nav>
  );
};

export default Navbar;
