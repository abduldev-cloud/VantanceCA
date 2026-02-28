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

    getUsers: async (status = null, page = 1, pageSize = 10, instituteId = null) => {
        try {
            const params = {
                page_number: page,
                page_size: pageSize
            };
            if (status) params.user_status = status;
            if (instituteId) params.institute_id = instituteId;
            const response = await api.get('/db/platform_admin/get_all_platform_users/', { params });
            return response.data;
        } catch (error) {
            console.error('Error fetching users:', error);
            throw error;
        }
    },

    bulkImportSchools: async (file) => {
        try {
            const formData = new FormData();
            formData.append('file', file);

            const response = await api.post('/db/platform_admin/bulk_import_schools/', formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                }
            });
            return response.data;
        } catch (error) {
            console.error('Error in bulk import:', error);
            throw error;
        }
    },

    bulkImportUsers: async (file, instituteId = null) => {
        try {
            const formData = new FormData();
            formData.append('file', file);

            const url = instituteId
                ? `/db/platform_admin/bulk_import_users/?institute_id=${instituteId}`
                : '/db/platform_admin/bulk_import_users/';

            const response = await api.post(url, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                }
            });
            return response.data;
        } catch (error) {
            console.error('Error in bulk import users:', error);
            throw error;
        }
    },

    addUser: async (userData) => {
        try {
            const response = await api.post('/db/platform_admin/add_user/', userData);
            return response.data;
        } catch (error) {
            console.error('Error adding user:', error);
            throw error;
        }
    }
};

export default adminService;
