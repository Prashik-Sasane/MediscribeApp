import apiClient from './apiClient';

export const searchService = {
  searchAll: async (query) => {
    const { data } = await apiClient.get(`/search?q=${encodeURIComponent(query)}`);
    return data.results || [];
  },
};

export default searchService;
