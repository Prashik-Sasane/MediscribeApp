import apiClient from './apiClient';

export const orderService = {
  fetchOrders: async () => {
    const { data } = await apiClient.get('/orders');
    return data.orders || [];
  },

  createOrder: async (orderData) => {
    const { data } = await apiClient.post('/orders', orderData);
    return data.order;
  },

  getOrderById: async (id) => {
    const { data } = await apiClient.get(`/orders/${id}`);
    return data.order;
  },
};

export default orderService;
