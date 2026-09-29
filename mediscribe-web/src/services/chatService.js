import apiClient from './apiClient';

export const chatService = {
  fetchConversations: async () => {
    const { data } = await apiClient.get('/chat/conversations');
    return data.conversations || [];
  },

  fetchMessages: async (conversationId) => {
    const { data } = await apiClient.get(`/chat/${conversationId}/messages`);
    return data.messages || [];
  },

  sendMessage: async (conversationId, message) => {
    const { data } = await apiClient.post(`/chat/${conversationId}/messages`, { message });
    return data.message;
  },

  createConversation: async (doctorId) => {
    const { data } = await apiClient.post('/chat/conversations', { doctorId });
    return data.conversation;
  },
};

export default chatService;
