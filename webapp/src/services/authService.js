import api from '../utils/api';

const authService = {
    login: async (username, password) => {
        try {
            const response = await api.post('/users/login', { username, password });
            if (response.data && response.data.access_token) {
                localStorage.setItem('token', response.data.access_token);
                return response.data;
            }
            throw new Error('Invalid login response');
        } catch (error) {
            console.error('Login error:', error);
            throw error;
        }
    },

    getUserDetails: async (userId) => {
        try {
            const response = await api.get(`/db/users/get_user_entity_details/${userId}`);
            if (response.data && response.data.items && response.data.items.length > 0) {
                return response.data.items[0];
            }
            throw new Error('User details not found');
        } catch (error) {
            console.error('Get user details error:', error);
            throw error;
        }
    },

    logout: () => {
        localStorage.removeItem('token');
        localStorage.removeItem('userRole');
        localStorage.removeItem('userData');
    }
};

export default authService;
