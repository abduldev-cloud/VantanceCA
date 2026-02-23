import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Calendar, Clock, BookOpen, GraduationCap, ChevronRight } from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import Typography from '../../components/common/Typography';
import styles from './Student.module.css';

const ClassDetail = () => {
    const navigate = useNavigate();

    const assignments = [
        {
            id: 'task-1',
            title: 'Climate Change Essay',
            description: 'Discuss the impact of rising global temperatures on biodiversity in the Arctic region.',
            dueDate: 'March 15, 2026',
            dueTime: '11:59 PM',
            className: 'Environmental Science',
            gradeName: 'Grade 12',
            buttonLabel: 'Continue Writing'
        },
        {
            id: 'task-2',
            title: 'Water Cycle Quiz',
            description: 'Review the stages of the water cycle and their importance in sustainable ecosystems.',
            dueDate: 'March 20, 2026',
            dueTime: '11:59 PM',
            className: 'Environmental Science',
            gradeName: 'Grade 12',
            buttonLabel: 'Start Practice'
        }
    ];

    return (
        <MainLayout>
            <div className={styles.header}>
                <Typography variant="displaySmall" weight="700">Environmental Science</Typography>
                <Typography variant="bodyMedium" color="#666">
                    Assignments for this class
                </Typography>
            </div>

            <div className={styles.listContainer}>
                {assignments.map((assignment) => (
                    <div key={assignment.id} className={styles.paperCard} style={{ padding: '24px' }}>
                        <div className={styles.paperInfo}>
                            <Typography variant="headlineSmall" weight="600" style={{ marginBottom: '8px' }}>
                                {assignment.title}
                            </Typography>
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
                            onClick={() => navigate(`/student/writingpad`)}
                        >
                            <ChevronRight size={20} />
                            <span>{assignment.buttonLabel}</span>
                        </button>
                    </div>
                ))}
            </div>
        </MainLayout>
    );
};

export default ClassDetail;
