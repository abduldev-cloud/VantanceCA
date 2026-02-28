import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
    Search,
    ChevronDown,
    Fingerprint,
    Eye,
    Bell,
    ArrowLeft,
    RefreshCw
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import CreateAssignmentDialog from './CreateAssignmentDialog';
import teacherService from '../../services/teacherService';
import styles from './AssignmentDetail.module.css';

const AssignmentDetail = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const [searchQuery, setSearchQuery] = useState('');
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isLoading, setIsLoading] = useState(true);
    const [assignment, setAssignment] = useState(null);
    const [submissions, setSubmissions] = useState([]);
    const [error, setError] = useState('');

    useEffect(() => {
        const fetchDetails = async () => {
            if (!id) return;
            setIsLoading(true);
            try {
                const [detailsRes, submissionsRes] = await Promise.all([
                    teacherService.getAssignmentDetails(id),
                    teacherService.getSubmissions(id)
                ]);

                if (detailsRes.success) {
                    setAssignment(detailsRes.data);
                }
                if (submissionsRes.success) {
                    setSubmissions(submissionsRes.data || []);
                }
            } catch (err) {
                console.error('Error fetching assignment details:', err);
                setError('Failed to load assignment details.');
            } finally {
                setIsLoading(false);
            }
        };

        fetchDetails();
    }, [id]);

    const filteredStudents = submissions.filter(s =>
        `${s.first_name} ${s.last_name}`.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const stats = {
        title: assignment?.task_title || 'Assignment Detail',
        submitted: submissions.filter(s => s.status === 'SUBMITTED' || s.status === 'GRADED').length,
        missing: submissions.filter(s => s.status === 'PENDING' || s.status === 'NOT_STARTED').length,
        total: submissions.length,
        avgScore: assignment?.average_score ? `${assignment.average_score.toFixed(1)}/10` : 'N/A'
    };

    if (isLoading) {
        return (
            <MainLayout>
                <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
                    <RefreshCw className={styles.spin} size={40} color="#004AAD" />
                </div>
            </MainLayout>
        );
    }

    return (
        <MainLayout>
            <div style={{ padding: '0 40px', marginTop: '20px' }}>
                <button
                    onClick={() => navigate('/teacher/assignments')}
                    style={{
                        background: 'none',
                        border: 'none',
                        color: '#004AAD',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '8px',
                        cursor: 'pointer',
                        fontWeight: '600',
                        fontSize: '14px'
                    }}
                >
                    <ArrowLeft size={18} /> Back to Assignments
                </button>
            </div>

            <TitleBar
                title={stats.title}
                subTitle={assignment ? `${assignment.class_name} | Due: ${new Date(assignment.due_date).toLocaleDateString()}` : ""}
                buttonTitle="Create Assignment"
                onTap={() => setIsModalOpen(true)}
            />

            <div className={styles.container}>
                <div className={styles.statsGrid}>
                    <div className={styles.statCard}>
                        <div className={styles.statTitle}>Submissions</div>
                        <div className={styles.statValue} style={{ color: '#0A8041' }}>{stats.submitted}/{stats.total}</div>
                    </div>
                    <div className={styles.statCard}>
                        <div className={styles.statTitle}>Missing</div>
                        <div className={styles.statValue} style={{ color: '#FF9933' }}>{stats.missing}</div>
                    </div>
                    <div className={styles.statCard}>
                        <div className={styles.statTitle}>Average Score</div>
                        <div className={styles.statValue} style={{ color: '#CB6CE6' }}>{stats.avgScore}</div>
                    </div>
                </div>

                <div className={styles.tableContainer}>
                    <div className={styles.tableHeader}>
                        <div className={styles.tableTitle}>All Students</div>
                        <div className={styles.controls}>
                            <div className={styles.searchWrapper}>
                                <Search className={styles.searchIcon} size={18} />
                                <input
                                    type="text"
                                    className={styles.searchInput}
                                    placeholder="Search"
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                />
                            </div>
                            <div className={styles.actionButton}>
                                <span>Sort by : <b>Newest</b></span>
                                <ChevronDown size={14} />
                            </div>
                        </div>
                    </div>

                    <div className={styles.gridHeader}>
                        <div>Student</div>
                        <div>Writing Fingerprint</div>
                        <div>Submitted</div>
                        <div>Word Count</div>
                        <div>Grade</div>
                        <div>Action</div>
                    </div>

                    <div className={styles.daysGrid}>
                        {filteredStudents.length === 0 ? (
                            <div style={{ padding: '40px', textAlign: 'center', color: '#6B7280' }}>
                                No students found for this assignment.
                            </div>
                        ) : (
                            filteredStudents.map((s) => (
                                <div key={s.learner_task_id} className={styles.gridRow}>
                                    <div>{s.first_name} {s.last_name}</div>
                                    <div>
                                        {s.fingerprint_status === 'COMPLETED' ? <Fingerprint size={20} style={{ margin: '0 auto', color: '#0A8041' }} /> : '-'}
                                    </div>
                                    <div>{s.submitted_at ? new Date(s.submitted_at).toLocaleString() : '-'}</div>
                                    <div>{s.word_count || '-'}</div>
                                    <div>{s.score !== null ? `${s.score}/10` : '-'}</div>
                                    <div>
                                        {s.status === 'GRADED' && (
                                            <button
                                                className={styles.actionButton}
                                                onClick={() => navigate('/teacher/grading-review', { state: { submission: s } })}
                                            >
                                                <Eye size={14} />
                                                View Details
                                            </button>
                                        )}
                                        {s.status === 'SUBMITTED' && (
                                            <button
                                                className={`${styles.actionButton} ${styles.btnGradient}`}
                                                onClick={() => navigate('/teacher/grading-review', { state: { submission: s } })}
                                            >
                                                <Eye size={14} />
                                                Review
                                            </button>
                                        )}
                                        {(s.status === 'PENDING' || s.status === 'NOT_STARTED') && (
                                            <button className={`${styles.actionButton} ${styles.btnRemind}`}>
                                                <Bell size={14} />
                                                Remind
                                            </button>
                                        )}
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </div>
            </div>
            <CreateAssignmentDialog isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
        </MainLayout>
    );
};

export default AssignmentDetail;
