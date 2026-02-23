import api from '../utils/api';

const adminService = {
    getStats: async () => {
        try {
            const response = await api.get('/db/platform_admin/stats/');
            return response.data;
        } catch (error) {
            console.error('Error fetching admin stats:', error);
            throw error;
        }
    },

    getSchools: async (status = null, page = 1, pageSize = 10) => {
        try {
            const params = {
                page_number: page,
                page_size: pageSize
            };
            if (status) params.institute_status = status;
            const response = await api.get('/db/platform_admin/get_all_institute_summary/', { params });
            return response.data;
        } catch (error) {
            console.error('Error fetching schools:', error);
            throw error;
        }
    },

    getUsers: async (status = null, page = 1, pageSize = 10) => {
        try {
            const params = {
                page_number: page,
                page_size: pageSize
            };
            if (status) params.user_status = status;
            const response = await api.get('/db/platform_admin/get_all_platform_users/', { params });
            return response.data;
        } catch (error) {
            console.error('Error fetching users:', error);
            throw error;
        }
    }
};

export default adminService;
