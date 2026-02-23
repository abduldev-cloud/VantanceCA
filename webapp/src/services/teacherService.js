import api from '../utils/api';

const teacherService = {
    getStats: async (teacherId) => {
        try {
            const response = await api.get(`/db/teacher/${teacherId}/stats`);
            return response.data;
        } catch (error) {
            console.error('Error fetching teacher stats:', error);
            throw error;
        }
    },

    getClasses: async (teacherId) => {
        try {
            const response = await api.get('/db/classes', {
                params: { teacher_id: teacherId }
            });
            return response.data;
        } catch (error) {
            console.error('Error fetching teacher classes:', error);
            throw error;
        }
    },

    getAssignments: async (teacherId, classId = null) => {
        try {
            const params = { teacher_id: teacherId };
            if (classId) params.class_id = classId;
            const response = await api.get('/db/assignments', { params });
            return response.data;
        } catch (error) {
            console.error('Error fetching assignments:', error);
            throw error;
        }
    },

    getAssignmentDetails: async (taskId) => {
        try {
            const response = await api.get(`/db/assignments/${taskId}`);
            return response.data;
        } catch (error) {
            console.error('Error fetching assignment details:', error);
            throw error;
        }
    },

    getSubmissions: async (taskId) => {
        try {
            const response = await api.get(`/db/assignments/${taskId}/submissions`);
            return response.data;
        } catch (error) {
            console.error('Error fetching submissions:', error);
            throw error;
        }
    },

    getAllSubmissions: async (teacherId) => {
        try {
            const response = await api.get(`/db/teacher/${teacherId}/submissions`);
            return response.data;
        } catch (error) {
            console.error('Error fetching teacher submissions:', error);
            throw error;
        }
    },

    createAssignment: async (assignmentData) => {
        try {
            const response = await api.post('/db/assignments/create', assignmentData);
            return response.data;
        } catch (error) {
            console.error('Error creating assignment:', error);
            throw error;
        }
    },

    createClass: async (classData) => {
        try {
            const response = await api.post('/db/classes/create', classData);
            return response.data;
        } catch (error) {
            console.error('Error creating class:', error);
            throw error;
        }
    }
};

export default teacherService;
