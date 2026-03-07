import api from '../utils/api';

const studentService = {
    getAssignments: async (learnerId) => {
        try {
            const response = await api.get(`/db/assignments`, {
                params: { learner_id: learnerId }
            });
            return response.data;
        } catch (error) {
            console.error('Error fetching assignments:', error);
            throw error;
        }
    },

    getAssignmentDetails: async (taskId, learnerId = null) => {
        try {
            const params = {};
            if (learnerId) params.learner_id = learnerId;
            const response = await api.get(`/db/assignments/${taskId}`, { params });
            return response.data;
        } catch (error) {
            console.error('Error fetching assignment details:', error);
            throw error;
        }
    },

    submitAssignment: async (learnerTaskId, content, wordCount) => {
        try {
            const response = await api.post('/db/assignments/submit', {
                learner_task_id: learnerTaskId,
                content,
                word_count: wordCount
            });
            return response.data;
        } catch (error) {
            console.error('Error submitting assignment:', error);
            throw error;
        }
    },

    getClasses: async (learnerId) => {
        try {
            const response = await api.get(`/db/classes/learner/${learnerId}`);
            return response.data;
        } catch (error) {
            console.error('Error fetching classes:', error);
            throw error;
        }
    },

    getGradeLevels: async () => {
        try {
            const response = await api.get('/db/grade_levels');
            return response.data;
        } catch (error) {
            console.error('Error fetching grade levels:', error);
            throw error;
        }
    }
};

export default studentService;
