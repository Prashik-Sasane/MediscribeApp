/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#1E3A8A',
          light: '#2E7DFF',
          dark: '#0F172A',
        },
        secondary: {
          DEFAULT: '#1E40AF',
        },
        button: {
          DEFAULT: '#1E40AF',
          dark: '#3B82F6',
        },
        background: {
          DEFAULT: '#FFFFFF',
          dark: '#0F172A',
        },
        surface: {
          DEFAULT: '#FFFFFF',
          dark: '#1E293B',
        },
        text: {
          primary: '#111827',
          secondary: '#6B7280',
          dark: {
            primary: '#F1F5F9',
            secondary: '#94A3B8',
          }
        },
        border: {
          DEFAULT: '#E5E7EB',
          dark: '#334155',
        },
        login: {
          bg: '#8BA3B8',
          bgDark: '#040A12',
        },
        accent: {
          saffron: '#5DB3E8',
          saffronLight: '#8ECDF5',
          saffronDark: '#3A9AD9',
          earthy: '#6B8CAE',
          softGreen: '#4A9EC7',
          warmGold: '#7AC4E8',
        }
      },
      borderRadius: {
        'lg': '12px',
      },
      boxShadow: {
        'card': '0 2px 8px rgba(0, 0, 0, 0.08)',
        'card-hover': '0 4px 16px rgba(0, 0, 0, 0.12)',
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
}
