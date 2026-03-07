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

    getAnalytics: async () => {
        try {
            const response = await api.get('/db/platform_admin/analytics');
            return response.data;
        } catch (error) {
            console.error('Error fetching analytics:', error);
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
    },

    // System Dictionary Endpoints
    getGradeLevels: async () => {
        try {
            const response = await api.get('/db/dictionary/grade_levels');
            return response.data;
        } catch (error) {
            console.error('Error fetching grades:', error);
            throw error;
        }
    },

    addGradeLevel: async (gradeData) => {
        try {
            const response = await api.post('/db/dictionary/grade_levels', gradeData);
            return response.data;
        } catch (error) {
            console.error('Error adding grade:', error);
            throw error;
        }
    },

    deleteGradeLevel: async (gradeId) => {
        try {
            const response = await api.delete(`/db/dictionary/grade_levels/${gradeId}`);
            return response.data;
        } catch (error) {
            console.error('Error deleting grade:', error);
            throw error;
        }
    },

    getTaskTypes: async () => {
        try {
            const response = await api.get('/db/dictionary/task_types');
            return response.data;
        } catch (error) {
            console.error('Error fetching task types:', error);
            throw error;
        }
    },

    addTaskType: async (taskTypeData) => {
        try {
            const response = await api.post('/db/dictionary/task_types', taskTypeData);
            return response.data;
        } catch (error) {
            console.error('Error adding task type:', error);
            throw error;
        }
    },

    deleteTaskType: async (typeId) => {
        try {
            const response = await api.delete(`/db/dictionary/task_types/${typeId}`);
            return response.data;
        } catch (error) {
            console.error('Error deleting task type:', error);
            throw error;
        }
    },

    getAuditLogs: async (page = 1, pageSize = 20) => {
        try {
            const params = { page_number: page, page_size: pageSize };
            const response = await api.get('/db/platform_admin/audit_logs', { params });
            return response.data;
        } catch (error) {
            console.error('Error fetching audit logs:', error);
            throw error;
        }
    },

    updateSchoolBranding: async (instituteId, formData) => {
        try {
            // formData is a standard browser FormData object with primary_color and an optional logo file
            const response = await api.put(`/db/platform_admin/institute/${instituteId}/branding`, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                }
            });
            return response.data;
        } catch (error) {
            console.error('Error updating school branding:', error);
            throw error;
        }
    },

    getApiQuotas: async () => {
        try {
            const response = await api.get('/db/platform_admin/api_quotas');
            return response.data;
        } catch (error) {
            console.error('Error fetching api quotas:', error);
            throw error;
        }
    }
};

export default adminService;
