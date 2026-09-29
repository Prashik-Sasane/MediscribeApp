import apiClient from './apiClient';

export const appointmentService = {
  fetchMine: async () => {
    const { data } = await apiClient.get('/appointments/mine');
    return data.appointments || [];
  },

  fetchDoctorAppointments: async () => {
    const { data } = await apiClient.get('/appointments/doctor');
    return data.appointments || [];
  },

  book: async ({ doctorId, dateLabel, timeLabel, type = 'General checkup', location = 'Clinic' }) => {
    const { data } = await apiClient.post('/appointments', {
      doctorId,
      dateLabel,
      timeLabel,
      type,
      location,
    });
    return data.appointment;
  },

  updateStatus: async (appointmentId, status) => {
    const { data } = await apiClient.patch(`/appointments/${appointmentId}/status`, { status });
    return data;
  },

  rateAppointment: async (appointmentId, rating, review) => {
    const { data } = await apiClient.patch(`/appointments/${appointmentId}/rate`, { rating, review });
    return data;
  },
};

export default appointmentService;
