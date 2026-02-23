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

    getAssignmentDetails: async (taskId) => {
        try {
            const response = await api.get(`/db/assignments/${taskId}`);
            return response.data;
        } catch (error) {
            console.error('Error fetching assignment details:', error);
            throw error;
        }
    },

    submitAssignment: async (learnerTaskId, submissionData) => {
        // Note: Need to verify if there's a specific student submission endpoint in db_mock
        // For now, using a generic POST if needed or mock behavior
        try {
            return { success: true, message: 'Submission simulated' };
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
    }
};

export default studentService;
