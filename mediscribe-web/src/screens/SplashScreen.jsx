import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Stethoscope } from 'lucide-react';
import useAppStore from '../store/useAppStore';

const SplashScreen = () => {
  const navigate = useNavigate();
  const { currentUser } = useAppStore();

  const hasStoredAuth = () => {
    if (currentUser) return true;
    if (localStorage.getItem('mediscribe_token')) return true;
    try {
      const zustandStore = localStorage.getItem('mediscribe-storage');
      if (zustandStore) {
        const parsed = JSON.parse(zustandStore);
        if (parsed.state?.currentUser) return true;
      }
    } catch (e) {}
    return false;
  };

  useEffect(() => {
    const timer = setTimeout(() => {
      if (hasStoredAuth()) {
        navigate('/home', { replace: true });
      } else {
        navigate('/login', { replace: true });
      }
    }, 1500);

    return () => clearTimeout(timer);
  }, [navigate, currentUser]);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-br from-primary via-primary-dark to-background-dark animate-fade-in">
      <div className="text-center animate-slide-up">
        <div className="relative mb-8">
          <div className="w-28 h-28 rounded-3xl bg-gradient-to-br from-accent-saffron to-accent-warmGold flex items-center justify-center shadow-2xl animate-pulse-slow">
            <Stethoscope className="w-16 h-16 text-white" />
          </div>
          <div className="absolute -bottom-2 -right-2 w-10 h-10 rounded-full bg-accent-softGreen flex items-center justify-center shadow-lg">
            <span className="text-white text-xl">+</span>
          </div>
        </div>

        <h1 className="text-5xl font-extrabold text-white mb-3 tracking-tight">
          Mediscribe
        </h1>
        <p className="text-xl text-primary-light/80 mb-2">
          AI-Powered Healthcare Platform
        </p>
        <p className="text-sm text-gray-400">
          Prescription Digitization & Telemedicine
        </p>

        <div className="mt-12 flex flex-col items-center">
          <div className="flex gap-1.5">
            {[0, 1, 2].map((i) => (
              <div
                key={i}
                className="w-2.5 h-2.5 rounded-full bg-primary-light animate-bounce"
                style={{ animationDelay: `${i * 0.15}s` }}
              />
            ))}
          </div>
        </div>
      </div>

      <div className="absolute bottom-8 text-center">
        <p className="text-gray-500 text-sm">&copy; {new Date().getFullYear()} Mediscribe</p>
      </div>
    </div>
  );
};

export default SplashScreen;
