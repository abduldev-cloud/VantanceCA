import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Calendar, Clock, BookOpen, GraduationCap, ChevronRight, Loader2 } from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import Typography from '../../components/common/Typography';
import studentService from '../../services/studentService';
import styles from './Student.module.css';

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

    return (
        <MainLayout>
            <div className={styles.header}>
                <Typography variant="displaySmall" weight="700">{className}</Typography>
                <Typography variant="bodyMedium" color="#666">
                    Assignments for this class
                </Typography>
            </div>

            <div className={styles.listContainer}>
                {isLoading ? (
                    <div style={{ display: 'flex', justifyContent: 'center', padding: '100px' }}>
                        <Loader2 className={styles.spinner} size={40} />
                    </div>
                ) : error ? (
                    <Typography color="#EF4444" align="center" style={{ width: '100%', padding: '40px' }}>{error}</Typography>
                ) : assignments.length === 0 ? (
                    <Typography align="center" style={{ width: '100%', padding: '40px' }}>No assignments found for this class.</Typography>
                ) : (
                    assignments.map((assignment) => (
                        <div key={assignment.id} className={styles.paperCard} style={{ padding: '24px' }}>
                            <div className={styles.paperInfo}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '8px' }}>
                                    <Typography variant="headlineSmall" weight="600">
                                        {assignment.title}
                                    </Typography>
                                    <span style={{
                                        padding: '2px 8px',
                                        borderRadius: '12px',
                                        fontSize: '11px',
                                        fontWeight: 600,
                                        background: assignment.status === 'GRADED' ? '#D1FAE5' :
                                            assignment.status === 'SUBMITTED' ? '#E0F2FE' : '#FEF3C7',
                                        color: assignment.status === 'GRADED' ? '#065F46' :
                                            assignment.status === 'SUBMITTED' ? '#0369A1' : '#92400E'
                                    }}>
                                        {assignment.status}
                                    </span>
                                </div>
                                <Typography variant="bodyMedium" color="#666" style={{ marginBottom: '20px', display: 'block' }}>
                                    {assignment.description}
                                </Typography>

                                <div className={styles.metaGrid}>
                                    <div className={styles.metaItem}>
                                        <Calendar size={18} color="#004AAD" />
                                        <span>{assignment.dueDate}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <Clock size={18} color="#004AAD" />
                                        <span>{assignment.dueTime}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <BookOpen size={18} color="#004AAD" />
                                        <span>{assignment.className}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <GraduationCap size={18} color="#004AAD" />
                                        <span>{assignment.gradeName}</span>
                                    </div>
                                </div>
                            </div>

                            <button
                                className={styles.actionBtn}
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
