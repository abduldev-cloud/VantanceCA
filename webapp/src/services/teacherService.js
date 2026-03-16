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
    },

    getClassDetails: async (classId) => {
        try {
            const response = await api.get(`/db/classes/${classId}`);
            return response.data;
        } catch (error) {
            console.error('Error fetching class details:', error);
            throw error;
        }
    },

    getClassStudents: async (classId) => {
        try {
            const response = await api.get(`/db/classes/${classId}/students`);
            return response.data;
        } catch (error) {
            console.error('Error fetching class students:', error);
            throw error;
        }
    },

    getAvailableLearners: async (classId, instituteId = null) => {
        try {
            const params = { exclude_class_id: classId };
            if (instituteId) params.institute_id = instituteId;
            const response = await api.get('/db/learners', { params });
            return response.data;
        } catch (error) {
            console.error('Error fetching available learners:', error);
            throw error;
        }
    },

    enrollStudents: async (classId, learnerIds) => {
        try {
            const response = await api.post(`/db/classes/${classId}/enroll`, {
                learner_ids: learnerIds
            });
            return response.data;
        } catch (error) {
            console.error('Error enrolling students:', error);
            throw error;
        }
    },

    getStudyMaterials: async (filters = {}) => {
        try {
            const response = await api.get('/db/study-materials', { params: filters });
            return response.data;
        } catch (error) {
            console.error('Error fetching study materials:', error);
            throw error;
        }
    },

    createStudyMaterial: async (data) => {
        try {
            const response = await api.post('/db/study-materials/create', data);
            return response.data;
        } catch (error) {
            console.error('Error creating study material:', error);
            throw error;
        }
    },

    getGradeLevels: async () => {
        try {
            const response = await api.get('/db/grade_levels');
            return response.data;
        } catch (error) {
            throw error;
        }
    },

    uploadStudyMaterial: async (file) => {
        try {
            const formData = new FormData();
            formData.append('file', file);
            const response = await api.post('/db/study-materials/upload', formData, {
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
            });
            return response.data;
        } catch (error) {
            throw error;
        }
    },

    submitGrade: async (learnerTaskId, grade, feedback = '') => {
        try {
            const response = await api.post('/db/assignments/grade', {
                learner_task_id: learnerTaskId,
                score: grade,
                feedback: feedback
            });
            return response.data;
        } catch (error) {
            console.error('Error submitting grade:', error);
            throw error;
        }
    },

    getChatHistory: async (learnerTaskId) => {
        try {
            const response = await api.get(`/db/assignments/${learnerTaskId}/chat`);
            return response.data;
        } catch (error) {
            console.error('Error fetching chat history:', error);
            throw error;
        }
    },

    autoGrade: async (learnerTaskId) => {
        try {
            const response = await api.post(`/db/assignments/${learnerTaskId}/auto-grade`);
            return response.data;
        } catch (error) {
            console.error('Error auto-grading submission:', error);
            throw error;
        }
    }
};

export default teacherService;
