import React, { useState, useEffect } from 'react';
import {
    Search,
    ChevronDown,
    ChevronLeft,
    ChevronRight,
    Fingerprint,
    Eye,
    Bell
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import Typography from '../../components/common/Typography';
import CreateAssignmentDialog from './CreateAssignmentDialog';
import teacherService from '../../services/teacherService';
import styles from './Grading.module.css';

const Grading = () => {
    const [selectedTab, setSelectedTab] = useState(0); // 0: Pending, 1: Graded, 2: Total
    const [searchQuery, setSearchQuery] = useState('');
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState('');
    const [assignments, setAssignments] = useState([]);

    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    const teacherId = userData.role_entity_id;

    useEffect(() => {
        const fetchSubmissions = async () => {
            if (!teacherId) {
                setError('Teacher ID not found.');
                setIsLoading(false);
                return;
            }

            try {
                const response = await teacherService.getAllSubmissions(teacherId);
                if (response.success) {
                    const mapped = response.data.map(item => ({
                        id: item.learner_task_id,
                        studentName: `${item.first_name} ${item.last_name}`,
                        hasFingerprint: (item.fingerprint_count || 0) > 0,
                        assignmentTitle: item.task_title,
                        submittedDate: item.submitted_at ? new Date(item.submitted_at).toLocaleString() : '-',
                        wordCount: '850', // Mock word count
                        grade: item.score !== null ? `${item.score}/100` : '-',
                        status: item.status.toLowerCase()
                    }));
                    setAssignments(mapped);
                }
            } catch (err) {
                console.error('Error:', err);
                setError('Failed to load submissions.');
            } finally {
                setIsLoading(false);
            }
        };

        fetchSubmissions();
    }, [teacherId]);

    const pendingCount = assignments.filter(a => a.status === 'submitted' || a.status === 'pending').length;
    const gradedCount = assignments.filter(a => a.status === 'graded').length;

    const stats = [
        { title: 'Pending Review', value: pendingCount.toString(), color: '#FF9933' },
        { title: 'Graded Assignments', value: gradedCount.toString(), color: '#0A8041' },
        { title: 'Total Assignments', value: assignments.length.toString(), color: '#CB6CE6' }
    ];

    const filteredItems = assignments.filter(item => {
        const matchesSearch = item.studentName.toLowerCase().includes(searchQuery.toLowerCase());
        if (selectedTab === 0) return matchesSearch && item.status === 'pending';
        if (selectedTab === 1) return matchesSearch && item.status === 'graded';
        return matchesSearch;
    });

    return (
        <MainLayout>
            <TitleBar
                title="Grading"
                subTitle="Review and grade student work in one place"
                buttonTitle="Create Assignment"
                onTap={() => setIsModalOpen(true)}
            />

            <div className={styles.container}>
                <div className={styles.statsGrid}>
                    {stats.map((stat, index) => (
                        <div
                            key={index}
                            className={`${styles.statCard} ${selectedTab === index ? styles.statCardActive : ''}`}
                            onClick={() => setSelectedTab(index)}
                        >
                            <div className={styles.statTitle}>{stat.title}</div>
                            <div className={styles.statValue} style={{ color: stat.color }}>{stat.value}</div>
                        </div>
                    ))}
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
                            <div className={styles.pageBox} style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                                <span>Sort by : <b>Newest</b></span>
                                <ChevronDown size={16} />
                            </div>
                        </div>
                    </div>

                    <div className={styles.gridHeader}>
                        <div>Student</div>
                        <div>Fingerprint</div>
                        <div>Assignment</div>
                        <div>Submitted</div>
                        <div>Word Count</div>
                        <div>Grade</div>
                        <div>Action</div>
                    </div>

                    <div className={styles.tableBody}>
                        {isLoading ? (
                            <Typography align="center" style={{ padding: '40px' }}>Loading submissions...</Typography>
                        ) : error ? (
                            <Typography align="center" color="#EF4444" style={{ padding: '40px' }}>{error}</Typography>
                        ) : filteredItems.length === 0 ? (
                            <Typography align="center" style={{ padding: '40px' }}>No submissions found for this category.</Typography>
                        ) : (
                            filteredItems.map((item) => (
                                <div key={item.id} className={styles.gridRow}>
                                    <div className={styles.studentName}>{item.studentName}</div>
                                    <div>
                                        {item.hasFingerprint ? <Fingerprint size={20} color="black" style={{ margin: '0 auto' }} /> : '-'}
                                    </div>
                                    <div className={styles.assignmentTitle}>{item.assignmentTitle}</div>
                                    <div>{item.submittedDate}</div>
                                    <div>{item.wordCount}</div>
                                    <div>{item.grade}</div>
                                    <div>
                                        {(item.status === 'pending' || item.status === 'submitted') && (
                                            <button className={`${styles.actionButton} ${styles.btnReview}`}>
                                                <Eye size={16} />
                                                Review
                                            </button>
                                        )}
                                        {item.status === 'graded' && (
                                            <button className={`${styles.actionButton} ${styles.btnView}`}>
                                                <Eye size={16} />
                                                View
                                            </button>
                                        )}
                                        {item.status === 'assigned' && (
                                            <button className={`${styles.actionButton} ${styles.btnRemind}`}>
                                                <Bell size={16} />
                                                Remind
                                            </button>
                                        )}
                                    </div>
                                </div>
                            ))
                        )}
                    </div>

                    <div className={styles.tableFooter}>
                        <div className={styles.footerInfo}>
                            Showing {filteredItems.length} of {filteredItems.length} learners
                        </div>
                        <div className={styles.pagination}>
                            <div className={styles.pageBox}><ChevronLeft size={16} /></div>
                            <div className={`${styles.pageBox} ${styles.pageBoxActive}`}>1</div>
                            <div className={styles.pageBox}>2</div>
                            <div className={styles.pageBox}><ChevronRight size={16} /></div>
                        </div>
                    </div>
                </div>
            </div>
            <CreateAssignmentDialog isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
        </MainLayout>
    );
};

export default Grading;
