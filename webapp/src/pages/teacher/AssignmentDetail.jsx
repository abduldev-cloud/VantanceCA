import React, { useState } from 'react';
import {
    Search,
    ChevronDown,
    Fingerprint,
    Eye,
    Bell
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import CreateAssignmentDialog from './CreateAssignmentDialog';
import styles from './AssignmentDetail.module.css';

const AssignmentDetail = () => {
    const [searchQuery, setSearchQuery] = useState('');
    const [isModalOpen, setIsModalOpen] = useState(false);

    const stats = {
        title: 'The Future of AI in Education',
        submitted: 15,
        missing: 5,
        avgScore: '8.4/10'
    };

    const students = [
        {
            id: '1',
            name: 'Arun Kumar',
            hasFingerprint: true,
            submittedAt: 'Oct 12, 2025 10:30 AM',
            wordCount: 850,
            grade: '9/10',
            status: 'GRADED'
        },
        {
            id: '2',
            name: 'Sarah Jenkins',
            hasFingerprint: true,
            submittedAt: 'Oct 11, 2025 04:15 PM',
            wordCount: 1200,
            grade: '-',
            status: 'SUBMITTED'
        },
        {
            id: '3',
            name: 'Michael Chen',
            hasFingerprint: false,
            submittedAt: '-',
            wordCount: '-',
            grade: '-',
            status: 'MISSING'
        }
    ];

    const filteredStudents = students.filter(s =>
        s.name.toLowerCase().includes(searchQuery.toLowerCase())
    );

    return (
        <MainLayout>
            <TitleBar
                title={stats.title}
                subTitle=""
                buttonTitle="Create Assignment"
                onTap={() => setIsModalOpen(true)}
            />

            <div className={styles.container}>
                <div className={styles.statsGrid}>
                    <div className={styles.statCard}>
                        <div className={styles.statTitle}>Submissions</div>
                        <div className={styles.statValue} style={{ color: '#0A8041' }}>{stats.submitted}</div>
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
                        {filteredStudents.map((s) => (
                            <div key={s.id} className={styles.gridRow}>
                                <div>{s.name}</div>
                                <div>
                                    {s.hasFingerprint ? <Fingerprint size={20} style={{ margin: '0 auto' }} /> : '-'}
                                </div>
                                <div>{s.submittedAt}</div>
                                <div>{s.wordCount}</div>
                                <div>{s.grade}</div>
                                <div>
                                    {s.status === 'GRADED' && (
                                        <button className={styles.actionButton}>
                                            <Eye size={14} />
                                            View Details
                                        </button>
                                    )}
                                    {s.status === 'SUBMITTED' && (
                                        <button className={`${styles.actionButton} ${styles.btnGradient}`}>
                                            <Eye size={14} />
                                            Review
                                        </button>
                                    )}
                                    {s.status === 'MISSING' && (
                                        <button className={`${styles.actionButton} ${styles.btnRemind}`}>
                                            <Bell size={14} />
                                            Remind
                                        </button>
                                    )}
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
            <CreateAssignmentDialog isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
        </MainLayout>
    );
};

export default AssignmentDetail;
