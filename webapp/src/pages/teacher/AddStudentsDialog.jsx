import React, { useState, useEffect } from 'react';
import { X, Check, RefreshCw, Search } from 'lucide-react';
import teacherService from '../../services/teacherService';
import styles from './AddStudentsDialog.module.css';

const AddStudentsDialog = ({ isOpen, onClose, classId, onStudentsAdded }) => {
    const [learners, setLearners] = useState([]);
    const [selectedIds, setSelectedIds] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [isLoading, setIsLoading] = useState(true);
    const [isEnrolling, setIsEnrolling] = useState(false);

    useEffect(() => {
        if (isOpen && classId) {
            const fetchLearners = async () => {
                setIsLoading(true);
                try {
                    const response = await teacherService.getAvailableLearners(classId);
                    if (response.success) {
                        setLearners(response.data || []);
                    }
                } catch (err) {
                    console.error('Error fetching available learners:', err);
                }
                setIsLoading(false);
            };
            fetchLearners();
            setSelectedIds([]);
            setSearchTerm('');
        }
    }, [isOpen, classId]);

    const toggleStudent = (learnerId) => {
        setSelectedIds(prev =>
            prev.includes(learnerId)
                ? prev.filter(id => id !== learnerId)
                : [...prev, learnerId]
        );
    };

    const handleEnroll = async () => {
        if (selectedIds.length === 0) return;
        setIsEnrolling(true);
        try {
            const response = await teacherService.enrollStudents(classId, selectedIds);
            if (response.success) {
                onStudentsAdded();
                onClose();
            }
        } catch (err) {
            console.error('Error enrolling students:', err);
            alert('Failed to enroll students.');
        }
        setIsEnrolling(false);
    };

    const filteredLearners = learners.filter(l => {
        const term = searchTerm.toLowerCase();
        return (
            `${l.first_name} ${l.last_name}`.toLowerCase().includes(term) ||
            (l.email && l.email.toLowerCase().includes(term)) ||
            (l.learner_code && l.learner_code.toLowerCase().includes(term))
        );
    });

    if (!isOpen) return null;

    return (
        <div className={styles.overlay}>
            <div className={styles.modal}>
                <button className={styles.btnClose} onClick={onClose}><X size={20} /></button>

                <div className={styles.header}>
                    <h2>Add Students</h2>
                    <p>Select students to enroll in this class</p>
                </div>

                <div className={styles.searchBox}>
                    <input
                        className={styles.searchInput}
                        placeholder="Search by name, email, or code..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                </div>

                <div className={styles.studentList}>
                    {isLoading ? (
                        <div className={styles.loadingState}>
                            <RefreshCw className={styles.spin} size={24} color="#004AAD" />
                            <p>Loading students...</p>
                        </div>
                    ) : filteredLearners.length === 0 ? (
                        <div className={styles.noResults}>
                            {learners.length === 0
                                ? 'No available students to add.'
                                : 'No students match your search.'}
                        </div>
                    ) : (
                        filteredLearners.map(learner => (
                            <div
                                key={learner.learner_id}
                                className={styles.studentItem}
                                onClick={() => toggleStudent(learner.learner_id)}
                            >
                                <div className={`${styles.checkbox} ${selectedIds.includes(learner.learner_id) ? styles.checkboxChecked : ''}`}>
                                    {selectedIds.includes(learner.learner_id) && <Check size={14} color="white" />}
                                </div>
                                <div className={styles.studentInfo}>
                                    <div className={styles.studentName}>
                                        {learner.first_name} {learner.last_name}
                                    </div>
                                    <div className={styles.studentMeta}>
                                        {learner.email} · {learner.learner_code || 'N/A'} · {learner.grade_name || 'N/A'}
                                    </div>
                                </div>
                            </div>
                        ))
                    )}
                </div>

                <div className={styles.footer}>
                    <div className={styles.selectedCount}>
                        <strong>{selectedIds.length}</strong> student{selectedIds.length !== 1 ? 's' : ''} selected
                    </div>
                    <button
                        className={styles.btnEnroll}
                        onClick={handleEnroll}
                        disabled={selectedIds.length === 0 || isEnrolling}
                    >
                        {isEnrolling ? 'Enrolling...' : `Add ${selectedIds.length > 0 ? selectedIds.length + ' ' : ''}Student${selectedIds.length !== 1 ? 's' : ''}`}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default AddStudentsDialog;
