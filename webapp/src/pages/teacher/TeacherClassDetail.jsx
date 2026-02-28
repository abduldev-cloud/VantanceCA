import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
    ArrowLeft,
    Users,
    FileText,
    Calendar,
    GraduationCap,
    Mail,
    RefreshCw,
    UserX
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import teacherService from '../../services/teacherService';
import AddStudentsDialog from './AddStudentsDialog';
import styles from './TeacherClassDetail.module.css';

const TeacherClassDetail = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const [classData, setClassData] = useState(null);
    const [students, setStudents] = useState([]);
    const [assignments, setAssignments] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState('');
    const [isAddStudentsOpen, setIsAddStudentsOpen] = useState(false);

    useEffect(() => {
        const fetchData = async () => {
            setIsLoading(true);
            try {
                const [classRes, studentsRes, assignmentsRes] = await Promise.all([
                    teacherService.getClassDetails(id),
                    teacherService.getClassStudents(id),
                    teacherService.getAssignments(null, id)
                ]);

                if (classRes.success) setClassData(classRes.data);
                if (studentsRes.success) setStudents(studentsRes.data || []);
                if (assignmentsRes.success) setAssignments(assignmentsRes.data || []);
            } catch (err) {
                console.error('Error fetching class details:', err);
                setError('Failed to load class details.');
            } finally {
                setIsLoading(false);
            }
        };

        if (id) fetchData();
    }, [id]);

    const refreshData = async () => {
        try {
            const [studentsRes, assignmentsRes] = await Promise.all([
                teacherService.getClassStudents(id),
                teacherService.getAssignments(null, id)
            ]);
            if (studentsRes.success) setStudents(studentsRes.data || []);
            if (assignmentsRes.success) setAssignments(assignmentsRes.data || []);
        } catch (err) {
            console.error('Error refreshing data:', err);
        }
    };

    if (isLoading) {
        return (
            <MainLayout>
                <div className={styles.loadingState}>
                    <RefreshCw className={styles.spin} size={40} color="#004AAD" />
                    <p style={{ marginTop: '16px' }}>Loading class details...</p>
                </div>
            </MainLayout>
        );
    }

    if (error || !classData) {
        return (
            <MainLayout>
                <div className={styles.container}>
                    <button className={styles.backButton} onClick={() => navigate('/teacher/classes')}>
                        <ArrowLeft size={18} /> Back to Classes
                    </button>
                    <div className={styles.errorState}>{error || 'Class not found.'}</div>
                </div>
            </MainLayout>
        );
    }

    return (
        <MainLayout>
            <div className={styles.container}>
                <button className={styles.backButton} onClick={() => navigate('/teacher/classes')}>
                    <ArrowLeft size={18} /> Back to Classes
                </button>

                {/* Class Header */}
                <div className={styles.header}>
                    <div className={styles.headerTop}>
                        <div>
                            <div className={styles.className}>{classData.class_name}</div>
                            <div className={styles.classCode}>Code: {classData.class_code || 'N/A'}</div>
                        </div>
                        <div className={styles.statusBadge}>Active</div>
                    </div>
                    <div className={styles.headerMeta}>
                        <div className={styles.headerMetaItem}>
                            <GraduationCap size={18} />
                            <span>{classData.grade_name || 'N/A'}</span>
                        </div>
                        <div className={styles.headerMetaItem}>
                            <Calendar size={18} />
                            <span>{classData.term || 'N/A'} {classData.academic_year || ''}</span>
                        </div>
                        <div className={styles.headerMetaItem}>
                            <Users size={18} />
                            <span>{students.length} Students</span>
                        </div>
                        <div className={styles.headerMetaItem}>
                            <FileText size={18} />
                            <span>{assignments.length} Assignments</span>
                        </div>
                    </div>
                </div>

                {/* Stats */}
                <div className={styles.statsRow}>
                    <div className={styles.statCard}>
                        <div className={styles.statValue} style={{ color: '#004AAD' }}>{students.length}</div>
                        <div className={styles.statLabel}>Enrolled Students</div>
                    </div>
                    <div className={styles.statCard}>
                        <div className={styles.statValue} style={{ color: '#0A8041' }}>{assignments.length}</div>
                        <div className={styles.statLabel}>Total Assignments</div>
                    </div>
                    <div className={styles.statCard}>
                        <div className={styles.statValue} style={{ color: '#FF9933' }}>
                            {assignments.filter(a => a.graded_count > 0).length}
                        </div>
                        <div className={styles.statLabel}>Graded</div>
                    </div>
                    <div className={styles.statCard}>
                        <div className={styles.statValue} style={{ color: '#CB6CE6' }}>
                            {assignments.reduce((sum, a) => sum + (a.submission_count || 0), 0)}
                        </div>
                        <div className={styles.statLabel}>Total Submissions</div>
                    </div>
                </div>

                {/* Students Table */}
                <div className={styles.section}>
                    <div className={styles.sectionHeader}>
                        <div className={styles.sectionTitle}>Students</div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                            <div className={styles.studentCount}>{students.length} enrolled</div>
                            <button
                                onClick={() => setIsAddStudentsOpen(true)}
                                style={{
                                    background: '#004AAD',
                                    color: 'white',
                                    border: 'none',
                                    padding: '8px 16px',
                                    borderRadius: '8px',
                                    fontSize: '13px',
                                    fontWeight: '600',
                                    cursor: 'pointer',
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '6px'
                                }}
                            >
                                + Add Students
                            </button>
                        </div>
                    </div>
                    {students.length > 0 ? (
                        <table className={styles.table}>
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Student Code</th>
                                    <th>Enrolled Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                {students.map((student, idx) => (
                                    <tr key={student.learner_id || idx}>
                                        <td>
                                            <div className={styles.studentName}>
                                                {student.first_name} {student.last_name}
                                            </div>
                                        </td>
                                        <td>
                                            <div className={styles.studentEmail}>
                                                <Mail size={14} style={{ marginRight: 6, verticalAlign: 'middle' }} />
                                                {student.email || 'N/A'}
                                            </div>
                                        </td>
                                        <td>{student.learner_code || 'N/A'}</td>
                                        <td>{student.enrollment_date ? new Date(student.enrollment_date).toLocaleDateString() : 'N/A'}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    ) : (
                        <div className={styles.emptyState}>
                            <UserX size={40} color="#CCC" />
                            <p>No students enrolled in this class yet.</p>
                        </div>
                    )}
                </div>

                {/* Assignments Table */}
                <div className={styles.section}>
                    <div className={styles.sectionHeader}>
                        <div className={styles.sectionTitle}>Assignments</div>
                        <div className={styles.studentCount}>{assignments.length} total</div>
                    </div>
                    {assignments.length > 0 ? (
                        <table className={styles.table}>
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>Type</th>
                                    <th>Due Date</th>
                                    <th>Submissions</th>
                                    <th>Graded</th>
                                </tr>
                            </thead>
                            <tbody>
                                {assignments.map((task, idx) => (
                                    <tr key={task.task_id || idx}>
                                        <td>
                                            <div className={styles.studentName}>{task.task_title}</div>
                                        </td>
                                        <td>{task.task_type || 'N/A'}</td>
                                        <td>{task.due_date ? new Date(task.due_date).toLocaleDateString() : 'No deadline'}</td>
                                        <td>{task.submission_count || 0}</td>
                                        <td>{task.graded_count || 0}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    ) : (
                        <div className={styles.emptyState}>
                            <FileText size={40} color="#CCC" />
                            <p>No assignments created for this class yet.</p>
                        </div>
                    )}
                </div>

                <AddStudentsDialog
                    isOpen={isAddStudentsOpen}
                    onClose={() => setIsAddStudentsOpen(false)}
                    classId={id}
                    onStudentsAdded={refreshData}
                />
            </div>
        </MainLayout>
    );
};

export default TeacherClassDetail;
