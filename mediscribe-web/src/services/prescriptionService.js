import apiClient from './apiClient';

export const prescriptionService = {
  analyzePrescription: async (imageFile) => {
    const formData = new FormData();
    formData.append('image', imageFile);

    const { data } = await apiClient.post('/prescription/analyze', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return data;
  },

  analyzeText: async (text) => {
    const { data } = await apiClient.post('/prescription/analyze-text', { text });
    return data;
  },

  fetchHistory: async () => {
    const { data } = await apiClient.get('/prescription/history');
    return data.prescriptions || [];
  },
};

export default prescriptionService;
