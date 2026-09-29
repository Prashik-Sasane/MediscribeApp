import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Stethoscope,
  Mail,
  Lock,
  User,
  Briefcase,
  DollarSign,
  FileText,
  Eye,
  EyeOff,
} from 'lucide-react';
import Button from '../components/common/Button';
import Input from '../components/common/Input';
import Card from '../components/common/Card';
import useAppStore from '../store/useAppStore';
import clsx from 'clsx';

const LoginScreen = () => {
  const navigate = useNavigate();
  const { login, signup, doctorLogin, doctorSignup, authLoading, authError, clearAuthError, currentUser } = useAppStore();
  const [isSignup, setIsSignup] = useState(false);
  const [isDoctor, setIsDoctor] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    specialty: '',
    experience: '',
    fee: '500',
    bio: '',
  });

  const [errors, setErrors] = useState({});

  React.useEffect(() => {
    if (currentUser) {
      navigate('/home');
    }
    return () => clearAuthError();
  }, [currentUser, navigate, clearAuthError]);

  const validate = () => {
    const newErrors = {};

    if (isSignup && !formData.name.trim()) {
      newErrors.name = 'Name is required';
    }
    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!formData.email.includes('@')) {
      newErrors.email = 'Invalid email format';
    }
    if (!formData.password) {
      newErrors.password = 'Password is required';
    } else if (formData.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters';
    }
    if (isDoctor && isSignup) {
      if (!formData.specialty.trim()) newErrors.specialty = 'Specialty is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validate()) return;

    let success;
    if (isDoctor) {
      success = isSignup
        ? await doctorSignup(
            formData.name,
            formData.email,
            formData.password,
            formData.specialty,
            parseInt(formData.experience) || 0,
            parseInt(formData.fee) || 500,
            formData.bio
          )
        : await doctorLogin(formData.email, formData.password);
    } else {
      success = isSignup
        ? await signup(formData.name, formData.email, formData.password)
        : await login(formData.email, formData.password);
    }

    if (success) {
      navigate('/home');
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: '' }));
    }
  };

  const fillDemoCredentials = () => {
    setFormData({
      ...formData,
      email: 'demo.user@gmail.com',
      password: 'google-demo-123',
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-login-bgDark via-background-dark to-login-bg">
      <div className="min-h-screen flex items-center justify-center px-4 py-8">
        <div className="w-full max-w-md">
          <div className="text-center mb-8 animate-slide-up">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-accent-saffron to-accent-warmGold mb-4 shadow-xl">
              <Stethoscope className="w-9 h-9 text-white" />
            </div>
            <h1 className="text-3xl font-bold text-white mb-2">
              {isSignup ? 'Create Account' : 'Welcome Back'}
            </h1>
            <p className="text-text-dark-secondary">
              {isSignup
                ? 'Join Mediscribe for better healthcare access'
                : 'Sign in to access your healthcare dashboard'}
            </p>
          </div>

          <Card className="p-8 animate-fade-in">
            <div className="mb-6">
              <div className="flex p-1 bg-gray-100 dark:bg-surface-dark rounded-xl">
                <button
                  onClick={() => setIsDoctor(false)}
                  className={clsx(
                    'flex-1 py-2.5 px-4 rounded-lg font-semibold text-sm transition-all duration-200',
                    !isDoctor
                      ? 'bg-primary-light text-white shadow-md'
                      : 'text-text-secondary dark:text-text-dark-secondary hover:text-text-primary dark:hover:text-text-dark-primary'
                  )}
                >
                  Patient
                </button>
                <button
                  onClick={() => setIsDoctor(true)}
                  className={clsx(
                    'flex-1 py-2.5 px-4 rounded-lg font-semibold text-sm transition-all duration-200',
                    isDoctor
                      ? 'bg-primary-light text-white shadow-md'
                      : 'text-text-secondary dark:text-text-dark-secondary hover:text-text-primary dark:hover:text-text-dark-primary'
                  )}
                >
                  Doctor
                </button>
              </div>
            </div>

            {authError && (
              <div className="mb-4 p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl text-red-700 dark:text-red-400 text-sm">
                {authError}
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-4">
              {isSignup && (
                <div className="relative">
                  <User className="absolute left-3 top-10 w-5 h-5 text-text-secondary dark:text-text-dark-secondary" />
                  <Input
                    name="name"
                    label="Full Name"
                    placeholder="Dr. John Doe"
                    value={formData.name}
                    onChange={handleChange}
                    error={errors.name}
                    className="pl-10"
                  />
                </div>
              )}

              <div className="relative">
                <Mail className="absolute left-3 top-10 w-5 h-5 text-text-secondary dark:text-text-dark-secondary" />
                <Input
                  name="email"
                  type="email"
                  label="Email Address"
                  placeholder="you@example.com"
                  value={formData.email}
                  onChange={handleChange}
                  error={errors.email}
                  className="pl-10"
                />
              </div>

              <div className="relative">
                <Lock className="absolute left-3 top-10 w-5 h-5 text-text-secondary dark:text-text-dark-secondary" />
                <div className="relative">
                  <Input
                    name="password"
                    type={showPassword ? 'text' : 'password'}
                    label="Password"
                    placeholder="Enter your password"
                    value={formData.password}
                    onChange={handleChange}
                    error={errors.password}
                    className="pl-10 pr-10"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-10 text-text-secondary dark:text-text-dark-secondary hover:text-text-primary dark:hover:text-text-dark-primary"
                  >
                    {showPassword ? (
                      <EyeOff className="w-5 h-5" />
                    ) : (
                      <Eye className="w-5 h-5" />
                    )}
                  </button>
                </div>
              </div>

              {isDoctor && isSignup && (
                <>
                  <div className="relative">
                    <Briefcase className="absolute left-3 top-10 w-5 h-5 text-text-secondary dark:text-text-dark-secondary" />
                    <Input
                      name="specialty"
                      label="Specialty"
                      placeholder="Cardiologist, Dentist, etc."
                      value={formData.specialty}
                      onChange={handleChange}
                      error={errors.specialty}
                      className="pl-10"
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="relative">
                      <FileText className="absolute left-3 top-10 w-5 h-5 text-text-secondary dark:text-text-dark-secondary" />
                      <Input
                        name="experience"
                        type="number"
                        label="Experience (yrs)"
                        placeholder="5"
                        value={formData.experience}
                        onChange={handleChange}
                        className="pl-10"
                      />
                    </div>
                    <div className="relative">
                      <DollarSign className="absolute left-3 top-10 w-5 h-5 text-text-secondary dark:text-text-dark-secondary" />
                      <Input
                        name="fee"
                        type="number"
                        label="Consultation Fee"
                        placeholder="500"
                        value={formData.fee}
                        onChange={handleChange}
                        className="pl-10"
                      />
                    </div>
                  </div>
                  <Input
                    name="bio"
                    label="Bio"
                    as="textarea"
                    placeholder="Tell us about yourself..."
                    value={formData.bio}
                    onChange={handleChange}
                    className="min-h-[80px] resize-y"
                  />
                </>
              )}

              <Button
                type="submit"
                loading={authLoading}
                className="w-full mt-2"
                size="lg"
              >
                {isSignup
                  ? `Create ${isDoctor ? 'Doctor' : 'Patient'} Account`
                  : `Sign in as ${isDoctor ? 'Doctor' : 'Patient'}`}
              </Button>
            </form>

            {!isSignup && (
              <div className="mt-4">
                <button
                  type="button"
                  onClick={fillDemoCredentials}
                  className="w-full text-sm text-primary-light hover:text-primary font-medium transition-colors py-2"
                >
                  Use Demo Credentials
                </button>
              </div>
            )}

            <div className="mt-6 pt-6 border-t border-border dark:border-border-dark text-center">
              <p className="text-text-secondary dark:text-text-dark-secondary">
              {isSignup ? 'Already have an account? ' : "Don't have an account? "}
                <button
                  type="button"
                  onClick={() => {
                    setIsSignup(!isSignup);
                    setErrors({});
                    clearAuthError();
                  }}
                  className="text-primary-light hover:text-primary font-semibold ml-1"
                >
                  {isSignup ? 'Sign In' : 'Sign Up'}
                </button>
              </p>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default LoginScreen;
