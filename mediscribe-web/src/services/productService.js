import apiClient from './apiClient';

export const productService = {
  fetchProducts: async ({ category, query, tag } = {}) => {
    const params = new URLSearchParams();
    if (category) params.append('category', category);
    if (query) params.append('q', query);
    if (tag) params.append('tag', tag);

    const queryString = params.toString();
    const { data } = await apiClient.get(`/products${queryString ? `?${queryString}` : ''}`);
    return data.products || [];
  },
};

export default productService;
