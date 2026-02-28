import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Eye } from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import Typography from '../../components/common/Typography';
import CreateAssignmentDialog from './CreateAssignmentDialog';
import teacherService from '../../services/teacherService';
import StudentsIcon from '../../assets/icon/students.png';
import ClassesIcon from '../../assets/icon/classes.png';
import GradeIcon from '../../assets/icon/grade.png';
import CalendarIcon from '../../assets/icon/calendar.png';
import styles from './Assignments.module.css';

const TeacherAssignmentsPage = () => {
    const navigate = useNavigate();
    const [selectedTab, setSelectedTab] = useState(0);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isLoading, setIsLoading] = useState(true);
    const [assignments, setAssignments] = useState([]);
    const [error, setError] = useState('');

    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    const teacherId = userData.role_entity_id;

    useEffect(() => {
        const fetchAssignments = async () => {
            if (!teacherId) {
                setError('Teacher ID not found.');
                setIsLoading(false);
                return;
            }

            try {
                const response = await teacherService.getAssignments(teacherId);
                if (response.success) {
                    const mapped = response.data.map(item => ({
                        id: item.task_id,
                        title: item.task_title,
                        submitted: item.submission_count || 0,
                        total: item.student_count || 0, // We need student count per class or total assigned
                        class: item.class_name,
                        grade: item.task_type || 'N/A',
                        dueDate: new Date(item.due_date).toLocaleDateString()
                    }));
                    setAssignments(mapped);
                }
            } catch (err) {
                console.error('Error:', err);
                setError('Failed to load assignments.');
            } finally {
                setIsLoading(false);
            }
        };

        fetchAssignments();
    }, [teacherId]);

    const tabs = [
        { title: 'Active Assignments', count: assignments.length, color: '#0A8041' },
        { title: 'Scheduled Assignments', count: 0, color: '#FF9F43' },
        { title: 'Draft Assignments', count: 0, color: '#6155F5' },
    ];

    return (
        <MainLayout>
            <TitleBar
                title="Assignments"
                subTitle="Plan, edit, and grade assignments across all classes"
                buttonTitle="Create Assignment"
                onTap={() => setIsModalOpen(true)}
            />

            <div className={styles.tabsRow}>
                {tabs.map((tab, index) => (
                    <div
                        key={index}
                        className={`${styles.tabCard} ${selectedTab === index ? styles.tabActive : ''}`}
                        onClick={() => setSelectedTab(index)}
                    >
                        <Typography variant="bodyMedium" className={styles.tabTitle}>{tab.title}</Typography>
                        <Typography variant="displaySmall" weight="700" style={{ color: tab.color }}>
                            {tab.count}
                        </Typography>
                    </div>
                ))}
            </div>

            <div className={styles.assignmentList}>
                {isLoading ? (
                    <Typography align="center" style={{ width: '100%', padding: '40px' }}>Loading assignments...</Typography>
                ) : error ? (
                    <Typography align="center" color="#EF4444" style={{ width: '100%', padding: '40px' }}>{error}</Typography>
                ) : assignments.length === 0 ? (
                    <Typography align="center" style={{ width: '100%', padding: '40px' }}>No assignments found.</Typography>
                ) : (
                    assignments.map((assignment) => (
                        <div key={assignment.id} className={styles.assignmentCard}>
                            <div className={styles.cardInfo}>
                                <Typography variant="titleLarge" weight="600">{assignment.title}</Typography>
                                <div className={styles.metaRow}>
                                    <span className={styles.metaItem}>
                                        <img src={StudentsIcon} alt="" /> {assignment.submitted} Submitted
                                    </span>
                                    <span className={styles.metaItem}>
                                        <img src={ClassesIcon} alt="" /> {assignment.class}
                                    </span>
                                    <span className={styles.metaItem}>
                                        <img src={GradeIcon} alt="" /> {assignment.grade}
                                    </span>
                                    <span className={styles.metaItem}>
                                        <img src={CalendarIcon} alt="" /> {assignment.dueDate}
                                    </span>
                                </div>
                            </div>
                            <button
                                className={styles.viewBtn}
                                onClick={() => navigate(`/teacher/assignments/${assignment.id}`)}
                            >
                                <Eye size={18} /> View Details
                            </button>
                        </div>
                    ))
                )}
            </div>
            <CreateAssignmentDialog isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
        </MainLayout>
    );
};

export default TeacherAssignmentsPage;
