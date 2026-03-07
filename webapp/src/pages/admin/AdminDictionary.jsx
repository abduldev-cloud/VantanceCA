import React, { useState, useEffect } from 'react';
import { Plus, Trash2, X, BookOpen, Layers } from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import adminService from '../../services/adminService';
import styles from './AdminDictionary.module.css';

const AdminDictionary = () => {
    const [grades, setGrades] = useState([]);
    const [taskTypes, setTaskTypes] = useState([]);

    // Modals
    const [isGradeModalOpen, setIsGradeModalOpen] = useState(false);
    const [isTaskModalOpen, setIsTaskModalOpen] = useState(false);

    // Forms
    const [gradeForm, setGradeForm] = useState({ grade_name: '', grade_order: '' });
    const [taskForm, setTaskForm] = useState({ task_type: '', task_type_description: '' });

    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState('');
    const [toastMessage, setToastMessage] = useState('');

    const fetchData = async () => {
        try {
            const gradeRes = await adminService.getGradeLevels();
            const taskRes = await adminService.getTaskTypes();
            if (gradeRes.out_status === 'SUCCESS') setGrades(gradeRes.items || []);
            if (taskRes.out_status === 'SUCCESS') setTaskTypes(taskRes.items || []);
        } catch (err) {
            console.error(err);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    const showToast = (msg) => {
        setToastMessage(msg);
        setTimeout(() => setToastMessage(''), 4000);
    };

    const handleAddGrade = async () => {
        if (!gradeForm.grade_name || !gradeForm.grade_order) {
            setError('Please provide a name and order for the Grade.');
            return;
        }
        setIsLoading(true);
        setError('');
        try {
            await adminService.addGradeLevel({
                grade_name: gradeForm.grade_name,
                grade_order: parseInt(gradeForm.grade_order, 10)
            });
            showToast('Grade Level added successfully!');
            setIsGradeModalOpen(false);
            setGradeForm({ grade_name: '', grade_order: '' });
            fetchData();
        } catch (err) {
            setError(err.response?.data?.detail || 'Failed to add grade.');
        } finally {
            setIsLoading(false);
        }
    };

    const handleDeleteGrade = async (id) => {
        if (!window.confirm("Are you sure you want to delete this Grade Level?")) return;
        try {
            await adminService.deleteGradeLevel(id);
            showToast('Grade Level deleted.');
            fetchData();
        } catch (err) {
            alert(err.response?.data?.detail || 'Failed to delete grade.');
        }
    };

    const handleAddTask = async () => {
        if (!taskForm.task_type) {
            setError('Please provide a task type name.');
            return;
        }
        setIsLoading(true);
        setError('');
        try {
            await adminService.addTaskType(taskForm);
            showToast('Task Type added successfully!');
            setIsTaskModalOpen(false);
            setTaskForm({ task_type: '', task_type_description: '' });
            fetchData();
        } catch (err) {
            setError(err.response?.data?.detail || 'Failed to add task type.');
        } finally {
            setIsLoading(false);
        }
    };

    const handleDeleteTask = async (id) => {
        if (!window.confirm("Are you sure you want to delete this Task Type?")) return;
        try {
            await adminService.deleteTaskType(id);
            showToast('Task Type deleted.');
            fetchData();
        } catch (err) {
            alert(err.response?.data?.detail || 'Failed to delete task type.');
        }
    };

    return (
        <MainLayout>
            <TitleBar
                title="System Dictionary"
                subTitle="Manage global configurations across the platform"
            />

            {toastMessage && (
                <div style={{ background: '#E6F4EA', color: '#1E7E34', padding: '16px', borderRadius: '12px', marginTop: '16px', border: '1px solid #1E7E34' }}>
                    {toastMessage}
                </div>
            )}

            <div className={styles.container}>
                <div className={styles.introText}>
                    Use this system dictionary to dynamically update the reference data used throughout the application. Changes made here are immediately available to all schools, teachers, and students.
                </div>

                {/* Grade Levels Section */}
                <div className={styles.dictionarySection}>
                    <div className={styles.sectionHeader}>
                        <div className={styles.sectionTitle}>
                            <h3><BookOpen size={18} style={{ marginRight: '8px', verticalAlign: 'middle', color: '#6C5DD3' }} />Grade Levels</h3>
                            <p>Define standard academic grades available for classes and enrollments.</p>
                        </div>
                        <button className={styles.addButton} onClick={() => { setIsGradeModalOpen(true); setError(''); }}>
                            <Plus size={16} /> Add Grade
                        </button>
                    </div>

                    <div className={styles.grid}>
                        {grades.map(grade => (
                            <div key={grade.grade_level_id} className={styles.card}>
                                <div className={styles.cardInfo}>
                                    <div className={styles.cardTitle}>{grade.grade_name}</div>
                                    <div className={styles.cardSubtitle}>Ordering: {grade.grade_order}</div>
                                </div>
                                <button className={styles.deleteButton} onClick={() => handleDeleteGrade(grade.grade_level_id)} title="Delete Grade">
                                    <Trash2 size={16} />
                                </button>
                            </div>
                        ))}
                        {grades.length === 0 && <div style={{ color: '#667085', fontSize: '14px' }}>No grade levels found.</div>}
                    </div>
                </div>

                {/* Task Types Section */}
                <div className={styles.dictionarySection}>
                    <div className={styles.sectionHeader}>
                        <div className={styles.sectionTitle}>
                            <h3><Layers size={18} style={{ marginRight: '8px', verticalAlign: 'middle', color: '#6C5DD3' }} />Task Types</h3>
                            <p>Define the types of assignments or activities teachers can create (e.g. Essay, Quiz).</p>
                        </div>
                        <button className={styles.addButton} onClick={() => { setIsTaskModalOpen(true); setError(''); }}>
                            <Plus size={16} /> Add Task Type
                        </button>
                    </div>

                    <div className={styles.grid}>
                        {taskTypes.map(task => (
                            <div key={task.task_type_id} className={styles.card}>
                                <div className={styles.cardInfo}>
                                    <div className={styles.cardTitle}>{task.task_type}</div>
                                    <div className={styles.cardSubtitle}>{task.task_type_description || 'No description provided'}</div>
                                </div>
                                <button className={styles.deleteButton} onClick={() => handleDeleteTask(task.task_type_id)} title="Delete Task Type">
                                    <Trash2 size={16} />
                                </button>
                            </div>
                        ))}
                        {taskTypes.length === 0 && <div style={{ color: '#667085', fontSize: '14px' }}>No task types found.</div>}
                    </div>
                </div>

            </div>

            {/* Grade Modal */}
            {isGradeModalOpen && (
                <div className={styles.overlay}>
                    <div className={styles.modal}>
                        <button className={styles.btnClose} onClick={() => setIsGradeModalOpen(false)}><X size={20} /></button>
                        <h3 className={styles.modalTitle}>Add Grade Level</h3>

                        <div className={styles.field}>
                            <label>Grade Name</label>
                            <input
                                className={styles.input}
                                placeholder="e.g. Grade 10"
                                value={gradeForm.grade_name}
                                onChange={e => setGradeForm({ ...gradeForm, grade_name: e.target.value })}
                            />
                        </div>
                        <div className={styles.field}>
                            <label>Internal Ordering Sequence</label>
                            <input
                                className={styles.input}
                                type="number"
                                placeholder="e.g. 10"
                                value={gradeForm.grade_order}
                                onChange={e => setGradeForm({ ...gradeForm, grade_order: e.target.value })}
                            />
                        </div>

                        {error && <div className={styles.errorMessage}>{error}</div>}

                        <div className={styles.modalFooter}>
                            <button className={styles.btnSecondary} onClick={() => setIsGradeModalOpen(false)} disabled={isLoading}>Cancel</button>
                            <button className={styles.btnPrimary} onClick={handleAddGrade} disabled={isLoading}>
                                {isLoading ? 'Saving...' : 'Save Grade'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Task Type Modal */}
            {isTaskModalOpen && (
                <div className={styles.overlay}>
                    <div className={styles.modal}>
                        <button className={styles.btnClose} onClick={() => setIsTaskModalOpen(false)}><X size={20} /></button>
                        <h3 className={styles.modalTitle}>Add Task Type</h3>

                        <div className={styles.field}>
                            <label>Task Type Name</label>
                            <input
                                className={styles.input}
                                placeholder="e.g. Quiz, Essay, Homework"
                                value={taskForm.task_type}
                                onChange={e => setTaskForm({ ...taskForm, task_type: e.target.value })}
                            />
                        </div>
                        <div className={styles.field}>
                            <label>Description (Optional)</label>
                            <input
                                className={styles.input}
                                placeholder="Brief explanation of this task type"
                                value={taskForm.task_type_description}
                                onChange={e => setTaskForm({ ...taskForm, task_type_description: e.target.value })}
                            />
                        </div>

                        {error && <div className={styles.errorMessage}>{error}</div>}

                        <div className={styles.modalFooter}>
                            <button className={styles.btnSecondary} onClick={() => setIsTaskModalOpen(false)} disabled={isLoading}>Cancel</button>
                            <button className={styles.btnPrimary} onClick={handleAddTask} disabled={isLoading}>
                                {isLoading ? 'Saving...' : 'Save Task Type'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

        </MainLayout>
    );
};

export default AdminDictionary;
