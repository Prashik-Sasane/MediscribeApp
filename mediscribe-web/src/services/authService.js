import apiClient from './apiClient';

export const authService = {
  login: async (email, password) => {
    const { data } = await apiClient.post('/auth/login', { email, password });
    return data;
  },

  signup: async (name, email, password) => {
    const { data } = await apiClient.post('/auth/signup', { name, email, password });
    return data;
  },

  doctorLogin: async (email, password) => {
    const { data } = await apiClient.post('/auth/doctor/login', { email, password });
    return data;
  },

  doctorSignup: async (name, email, password, specialty, experience = 0, fee = 500, bio = '') => {
    const { data } = await apiClient.post('/auth/doctor/signup', {
      name,
      email,
      password,
      specialty,
      experience,
      fee,
      bio,
    });
    return data;
  },

  getAddresses: async () => {
    const { data } = await apiClient.get('/auth/addresses');
    return data.addresses || [];
  },

  addAddress: async (address) => {
    const { data } = await apiClient.post('/auth/addresses', address);
    return data.addresses || [];
  },
};

export default authService;
