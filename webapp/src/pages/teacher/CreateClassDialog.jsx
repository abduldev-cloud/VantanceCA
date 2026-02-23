import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import teacherService from '../../services/teacherService';
import studentService from '../../services/studentService';
import styles from './CreateClassDialog.module.css';

const CreateClassDialog = ({ isOpen, onClose, onClassCreated }) => {
    const [isLoading, setIsLoading] = useState(false);
    const [gradeLevels, setGradeLevels] = useState([]);
    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    const teacherId = userData.role_entity_id;

    const [formData, setFormData] = useState({
        class_name: '',
        grade_level_id: '',
        academic_year: new Date().getFullYear().toString(),
        term: 'Semester 1'
    });

    useEffect(() => {
        if (isOpen) {
            const fetchGrades = async () => {
                try {
                    const response = await studentService.getGradeLevels();
                    if (response.success) {
                        setGradeLevels(response.data);
                    }
                } catch (err) {
                    console.error('Error fetching grades:', err);
                }
            };
            fetchGrades();
        }
    }, [isOpen]);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!formData.class_name || !formData.grade_level_id) {
            alert('Please fill in all required fields.');
            return;
        }

        setIsLoading(true);
        try {
            await teacherService.createClass({
                ...formData,
                teacher_id: teacherId
            });
            onClassCreated();
            onClose();
            setFormData({
                class_name: '',
                grade_level_id: '',
                academic_year: new Date().getFullYear().toString(),
                term: 'Semester 1'
            });
        } catch (err) {
            console.error('Error creating class:', err);
            alert('Failed to create class.');
        } finally {
            setIsLoading(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className={styles.overlay}>
            <div className={styles.modal}>
                <button className={styles.btnClose} onClick={onClose}><X size={24} /></button>

                <div className={styles.header}>
                    <h2>Create New Class</h2>
                    <p>Set up a new class to manage students and assignments</p>
                </div>

                <form onSubmit={handleSubmit} className={styles.form}>
                    <div className={styles.field}>
                        <label>Class Name *</label>
                        <input
                            name="class_name"
                            className={styles.input}
                            placeholder="e.g. Grade 10 English"
                            value={formData.class_name}
                            onChange={handleChange}
                            required
                        />
                    </div>

                    <div className={styles.field}>
                        <label>Grade Level *</label>
                        <select
                            name="grade_level_id"
                            className={styles.select}
                            value={formData.grade_level_id}
                            onChange={handleChange}
                            required
                        >
                            <option value="">Select Grade</option>
                            {gradeLevels.map(grade => (
                                <option key={grade.grade_level_id} value={grade.grade_level_id}>
                                    {grade.grade_name}
                                </option>
                            ))}
                        </select>
                    </div>

                    <div className={styles.row}>
                        <div className={styles.field}>
                            <label>Academic Year</label>
                            <input
                                name="academic_year"
                                className={styles.input}
                                placeholder="e.g. 2025"
                                value={formData.academic_year}
                                onChange={handleChange}
                            />
                        </div>
                        <div className={styles.field}>
                            <label>Term</label>
                            <select
                                name="term"
                                className={styles.select}
                                value={formData.term}
                                onChange={handleChange}
                            >
                                <option value="Semester 1">Semester 1</option>
                                <option value="Semester 2">Semester 2</option>
                                <option value="Full Year">Full Year</option>
                            </select>
                        </div>
                    </div>

                    <div className={styles.footer}>
                        <button
                            type="submit"
                            className={styles.btnSubmit}
                            disabled={isLoading}
                        >
                            {isLoading ? 'Creating...' : 'Create Class'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default CreateClassDialog;
