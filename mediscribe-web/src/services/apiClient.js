import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'https://mediscribeapp.onrender.com/api';

const getStoredToken = () => {
  let token = localStorage.getItem('mediscribe_token');
  if (token) return token;
  try {
    const zustandStore = localStorage.getItem('mediscribe-storage');
    if (zustandStore) {
      const parsed = JSON.parse(zustandStore);
      if (parsed.state?.token) return parsed.state.token;
    }
  } catch (e) {}
  return null;
};

const clearAllAuth = () => {
  localStorage.removeItem('mediscribe_token');
  localStorage.removeItem('mediscribe_user');
  localStorage.removeItem('mediscribe-storage');
};

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

apiClient.interceptors.request.use(
  (config) => {
    const token = getStoredToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      clearAllAuth();
      if (!window.location.pathname.includes('/login')) {
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

export default apiClient;
export { API_BASE_URL, clearAllAuth };
