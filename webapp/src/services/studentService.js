import api from '../utils/api';

const studentService = {
    getAssignments: async (learnerId, classId = null) => {
        try {
            const params = { learner_id: learnerId };
            if (classId) params.class_id = classId;
            const response = await api.get(`/db/assignments`, {
                params
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

    saveAssignmentDraft: async (learnerTaskId, content) => {
        try {
            const response = await api.post('/db/assignments/save_draft', {
                learner_task_id: learnerTaskId,
                content
            });
            return response.data;
        } catch (error) {
            console.error('Error saving assignment draft:', error);
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

    sendChatMessage: async (learnerTaskId, message) => {
        try {
            const response = await api.post(`/db/assignments/${learnerTaskId}/chat`, { message });
            return response.data;
        } catch (error) {
            console.error('Error sending chat message:', error);
            throw error;
        }
    }
};

export default studentService;
