import apiClient from './apiClient';

export const labService = {
  fetchLabTests: async ({ category, query, tag } = {}) => {
    const params = new URLSearchParams();
    if (category) params.append('category', category);
    if (query) params.append('q', query);
    if (tag) params.append('tag', tag);

    const queryString = params.toString();
    const { data } = await apiClient.get(`/labs${queryString ? `?${queryString}` : ''}`);
    return data.labs || [];
  },

  createBooking: async ({ labTestId, address, preferredDate, timeSlot, amount }) => {
    const requestBody = {
      labTestId,
      address: {
        label: address.label || 'Home',
        fullAddress: address.fullAddress || address.street || '',
        lat: address.lat,
        lng: address.lng,
        phone: address.phone || '',
      },
      preferredDate: preferredDate.toISOString(),
      timeSlot,
      paymentMethod: 'stripe',
    };

    const { data } = await apiClient.post('/labs/book', requestBody);
    return data.booking?._id || data.booking?.id || data._id || data.id || data.bookingId;
  },
};

export default labService;
