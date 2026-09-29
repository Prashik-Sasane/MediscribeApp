import apiClient from './apiClient';

export const paymentService = {
  createStripePayment: async ({ amount, orderType, orderId }) => {
    const { data } = await apiClient.post('/payment/create-order', {
      amount,
      currency: 'usd',
      orderType,
      orderId,
    });
    return data.success ? data : null;
  },

  verifyStripePayment: async ({ paymentIntentId, orderId, orderType }) => {
    const { data } = await apiClient.post('/payment/verify', {
      paymentIntentId,
      orderId,
      orderType,
    });
    return data.success === true;
  },
};

export default paymentService;
