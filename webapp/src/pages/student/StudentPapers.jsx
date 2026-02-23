import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import MainLayout from '../../components/layout/MainLayout';
import Typography from '../../components/common/Typography';
import studentService from '../../services/studentService';
import StudentsIcon from '../../assets/icon/students.png';
import ActiveAssignmentIcon from '../../assets/icon/activeAssignment.png';
import CalendarIcon from '../../assets/icon/calendar.png';
import GradeIcon from '../../assets/icon/grade.png';
import FingerprintIcon from '../../assets/icon/fingerprint.png';
import EyeIcon from '../../assets/icon/eye.png';
import styles from './Student.module.css';

const StudentPapers = () => {
    const navigate = useNavigate();
    const [isLoading, setIsLoading] = useState(true);
    const [papers, setPapers] = useState([]);
    const [error, setError] = useState('');

    useEffect(() => {
        const fetchPapers = async () => {
            try {
                const userData = JSON.parse(localStorage.getItem('userData') || '{}');
                const learnerId = userData.role_entity_id; // learner_id stored in role_entity_id during login

                if (!learnerId) {
                    setError('Unable to identify student. Please log in again.');
                    setIsLoading(false);
                    return;
                }

                const response = await studentService.getClasses(learnerId);
                if (response.success) {
                    // Map backend data to UI structure
                    const mappedPapers = response.data.map(cls => ({
                        id: cls.class_id,
                        className: cls.class_name,
                        description: cls.institute_name || 'Class',
                        studentCount: cls.student_count,
                        assignmentsCount: cls.assignments_count,
                        status: 'active',
                        term: cls.term,
                        academicYear: cls.academic_year,
                        grade: cls.grade_name,
                        fingerprintStatus: 'pending' // Default for now
                    }));
                    setPapers(mappedPapers);
                }
            } catch (err) {
                console.error('Error fetching papers:', err);
                setError('Failed to load classes. Pulse check your connection.');
            } finally {
                setIsLoading(false);
            }
        };

        fetchPapers();
    }, []);

    return (
        <MainLayout>
            <div className={styles.header}>
                <Typography variant="displaySmall" weight="700">Papers</Typography>
                <Typography variant="bodyLarge" color="#666">
                    View your current papers and assignments.
                </Typography>
            </div>

            <div className={styles.listContainer}>
                {isLoading ? (
                    <Typography align="center" style={{ width: '100%', padding: '40px' }}>Loading papers...</Typography>
                ) : error ? (
                    <Typography align="center" color="#EF4444" style={{ width: '100%', padding: '40px' }}>{error}</Typography>
                ) : papers.length === 0 ? (
                    <Typography align="center" style={{ width: '100%', padding: '40px' }}>No papers found.</Typography>
                ) : (
                    papers.map((paper) => (
                        <div key={paper.id} className={styles.paperCard}>
                            <div className={styles.paperInfo}>
                                <div className={styles.titleRow}>
                                    <Typography variant="titleLarge" weight="600">{paper.className}</Typography>
                                    <div className={`${styles.statusBadge} ${styles[paper.status]}`}>
                                        {paper.status}
                                    </div>
                                </div>
                                <Typography variant="bodyMedium" color="#666" className={styles.description}>
                                    {paper.description}
                                </Typography>

                                <div className={styles.metaGrid}>
                                    <div className={styles.metaItem}>
                                        <img src={StudentsIcon} alt="" />
                                        <span>{paper.studentCount} students</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <img src={ActiveAssignmentIcon} alt="" />
                                        <span>{paper.assignmentsCount} active assignments</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <img src={CalendarIcon} alt="" />
                                        <span>{paper.term} {paper.academicYear}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <img src={GradeIcon} alt="" />
                                        <span>{paper.grade}</span>
                                    </div>
                                    {paper.fingerprintStatus === 'submitted' && (
                                        <div className={styles.metaItem}>
                                            <img src={FingerprintIcon} alt="" />
                                            <span>Writing Fingerprint submitted</span>
                                        </div>
                                    )}
                                </div>
                            </div>

                            <button
                                className={styles.actionBtn}
                                onClick={() => navigate(`/student/class/${paper.id}`)}
                            >
                                <img src={EyeIcon} alt="" />
                                View Schedule
                            </button>
                        </div>
                    ))
                )}
            </div>
        </MainLayout>
    );
};

export default StudentPapers;
