import apiClient from './apiClient';

export const doctorService = {
  getAllDoctors: async ({ specialty = '', searchQuery = '', page = 1 } = {}) => {
    const params = new URLSearchParams();
    params.append('page', page.toString());
    if (specialty) params.append('specialty', specialty);
    if (searchQuery) params.append('q', searchQuery);

    const { data } = await apiClient.get(`/doctors?${params.toString()}`);
    return data.doctors || [];
  },

  getNearbyDoctors: async (lat, lng) => {
    try {
      const { data } = await apiClient.get(`/doctors/nearby?lat=${lat}&lng=${lng}&radiusKm=50`);
      if (data.doctors && data.doctors.length > 0) {
        return data.doctors;
      }
      return await doctorService.getAllDoctors();
    } catch (error) {
      console.error('Nearby doctors error:', error);
      return await doctorService.getAllDoctors();
    }
  },

  getDoctorById: async (id) => {
    const { data } = await apiClient.get(`/doctors/${id}`);
    return data.doctor;
  },
};

export default doctorService;
