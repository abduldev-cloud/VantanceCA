import React, { useState } from 'react';
import {
    Fingerprint,
    Users,
    FileText,
    Calendar,
    GraduationCap,
    ArrowRight
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import ScheduleFingerprintDialog from './ScheduleFingerprintDialog';
import styles from './WritingFingerprint.module.css';

const WritingFingerprint = () => {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const fingerprintClasses = [
        {
            id: '1',
            className: 'Modern English Literature',
            description: 'Exploring 20th and 21st century literary works and themes.',
            status: 'active',
            studentCount: 28,
            assignmentCount: 12,
            term: 'Fall',
            year: 2025,
            grade: 'Grade 11',
            fingerprintsSubmitted: 45
        },
        {
            id: '2',
            className: 'Creative Writing 101',
            description: 'Developing foundational skills in narrative and descriptive writing.',
            status: 'active',
            studentCount: 22,
            assignmentCount: 8,
            term: 'Fall',
            year: 2025,
            grade: 'Grade 10',
            fingerprintsSubmitted: 30
        }
    ];

    return (
        <MainLayout>
            <TitleBar
                title="Writing Fingerprint"
                subTitle="Track and verify each student’s unique writing style"
                buttonTitle="Schedule Writing Fingerprint Session"
                onTap={() => setIsModalOpen(true)}
            />

            <div className={styles.container}>
                <div className={styles.topSection}>
                    <div className={styles.alertsCard}>
                        <div className={styles.alertsIcon}>
                            <Fingerprint size={50} color="#CB6CE6" />
                        </div>
                        <div className={styles.alertsText}>View Alerts</div>
                    </div>

                    <div className={styles.guideCard}>
                        <div className={styles.guideTitle}>Writing Fingerprint Set-up Guide</div>
                        <div className={styles.guideText}>
                            Schedule a Writing Fingerprint session early in the school year during class time.
                            Make sure it’s closely monitored with no AI use or outside help.
                            This creates each student’s baseline writing style for future authorship checks.
                        </div>
                    </div>
                </div>

                <div className={styles.fingerprintList}>
                    {fingerprintClasses.map((cls) => (
                        <div key={cls.id} className={styles.classCard}>
                            <div className={styles.classMain}>
                                <div className={styles.classNameRow}>
                                    <div className={styles.className}>{cls.className}</div>
                                    <div className={styles.statusBadge}>{cls.status}</div>
                                </div>
                                <div className={styles.classDescription}>{cls.description}</div>

                                <div className={styles.classMeta}>
                                    <div className={styles.metaItem}>
                                        <Users size={18} />
                                        <span>{cls.studentCount} students</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <FileText size={18} />
                                        <span>{cls.assignmentCount} Active Assignments</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <Calendar size={18} />
                                        <span>{cls.term}, {cls.year}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <GraduationCap size={18} />
                                        <span>{cls.grade}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <Fingerprint size={18} />
                                        <span>{cls.fingerprintsSubmitted} Writing Fingerprints submitted</span>
                                    </div>
                                </div>
                            </div>

                            <button className={styles.viewDetailsButton}>
                                <ArrowRight size={15} />
                                <span>View Details</span>
                            </button>
                        </div>
                    ))}
                </div>
            </div>
            <ScheduleFingerprintDialog isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
        </MainLayout>
    );
};

export default WritingFingerprint;
