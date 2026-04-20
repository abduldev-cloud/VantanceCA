import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Calendar, Clock, BookOpen, GraduationCap, ChevronRight, Loader2 } from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import Typography from '../../components/common/Typography';
import studentService from '../../services/studentService';
import styles from './ClassDetail.module.css';
import studentStyles from './Student.module.css';

const ClassDetail = () => {
    const navigate = useNavigate();
    const { id: classId } = useParams();
    const [assignments, setAssignments] = useState([]);
    const [className, setClassName] = useState('Loading class...');
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState('');

    useEffect(() => {
        const fetchData = async () => {
            try {
                const userData = JSON.parse(localStorage.getItem('userData') || '{}');
                const learnerId = userData.role_entity_id;

                if (!learnerId) {
                    setError('Unable to identify student.');
                    setIsLoading(false);
                    return;
                }

                const response = await studentService.getAssignments(learnerId, classId);
                if (response.success) {
                    const mapped = response.data.map(item => ({
                        id: item.task_id,
                        title: item.task_title,
                        description: item.task_description,
                        dueDate: item.due_date ? new Date(item.due_date).toLocaleDateString() : 'No due date',
                        dueTime: item.due_date ? new Date(item.due_date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '',
                        className: item.class_name,
                        gradeName: item.grade_name || 'N/A',
                        status: item.status,
                        buttonLabel: (item.status === 'SUBMITTED' || item.status === 'GRADED') ? 'Review Work' :
                            (item.submission_text ? 'Continue Writing' : 'Start Practice')
                    }));
                    setAssignments(mapped);
                    if (mapped.length > 0) {
                        setClassName(mapped[0].className);
                    }
                }
            } catch (err) {
                console.error('Error fetching class assignments:', err);
                setError('Failed to load assignments.');
            } finally {
                setIsLoading(false);
            }
        };

        fetchData();
    }, [classId]);

    const handleAction = (assignment) => {
        if (assignment.status === 'GRADED' || assignment.status === 'SUBMITTED') {
            navigate(`/student/result`);
        } else {
            navigate(`/student/writingpad?id=${assignment.id}`);
        }
    };

    const getStatusClass = (status) => {
        switch (status) {
            case 'GRADED': return styles.statusGRADED;
            case 'SUBMITTED': return styles.statusSUBMITTED;
            default: return styles.statusPENDING;
        }
    };

    return (
        <MainLayout>
            <div className={studentStyles.header}>
                <Typography variant="displaySmall" weight="700">{className}</Typography>
                <Typography variant="bodyMedium" color="var(--text-muted)">
                    Assignments for this class
                </Typography>
            </div>

            <div className={studentStyles.listContainer}>
                {isLoading ? (
                    <div className={styles.loadingWrapper}>
                        <Loader2 className={styles.spinner} size={48} />
                    </div>
                ) : error ? (
                    <div className={styles.errorText}>{error}</div>
                ) : assignments.length === 0 ? (
                    <div className={styles.messageText}>No assignments found for this class.</div>
                ) : (
                    assignments.map((assignment) => (
                        <div key={assignment.id} className={styles.paperCard}>
                            <div className={styles.paperInfo}>
                                <div className={styles.titleRow}>
                                    <Typography variant="headlineSmall" weight="800" family="Outfit">
                                        {assignment.title}
                                    </Typography>
                                    <span className={`${styles.statusBadge} ${getStatusClass(assignment.status)}`}>
                                        {assignment.status}
                                    </span>
                                </div>
                                <Typography variant="bodyMedium" color="var(--text-secondary)" className={styles.description}>
                                    {assignment.description}
                                </Typography>

                                <div className={studentStyles.metaGrid}>
                                    <div className={studentStyles.metaItem}>
                                        <Calendar size={18} color="var(--secondary)" />
                                        <span>{assignment.dueDate}</span>
                                    </div>
                                    <div className={studentStyles.metaItem}>
                                        <Clock size={18} color="var(--secondary)" />
                                        <span>{assignment.dueTime}</span>
                                    </div>
                                    <div className={studentStyles.metaItem}>
                                        <BookOpen size={18} color="var(--secondary)" />
                                        <span>{assignment.className}</span>
                                    </div>
                                    <div className={studentStyles.metaItem}>
                                        <GraduationCap size={18} color="var(--secondary)" />
                                        <span>{assignment.gradeName}</span>
                                    </div>
                                </div>
                            </div>

                            <button
                                className={studentStyles.actionBtn}
                                onClick={() => handleAction(assignment)}
                            >
                                <ChevronRight size={20} />
                                <span>{assignment.buttonLabel}</span>
                            </button>
                        </div>
                    ))
                )}
            </div>
        </MainLayout>
    );
};

export default ClassDetail;
