import React, { useState } from 'react';
import {
    Users,
    FileText,
    Calendar,
    GraduationCap,
    Fingerprint,
    Eye,
    School
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import teacherService from '../../services/teacherService';
import styles from './TeacherClasses.module.css';

const TeacherClasses = () => {
    const [selectedTab, setSelectedTab] = useState(0); // 0: Active, 1: Archived, 2: Students
    const [isLoading, setIsLoading] = useState(true);
    const [classes, setClasses] = useState([]);
    const [error, setError] = useState('');

    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    const teacherId = userData.role_entity_id;

    useEffect(() => {
        const fetchClasses = async () => {
            if (!teacherId) {
                setError('Teacher ID not found.');
                setIsLoading(false);
                return;
            }

            try {
                const response = await teacherService.getClasses(teacherId);
                if (response.success) {
                    const mappedClasses = response.data.map(cls => ({
                        id: cls.class_id,
                        className: cls.class_name,
                        description: `Class taught at ${cls.institute_name}`,
                        status: 'active',
                        studentCount: cls.student_count,
                        assignmentCount: cls.assignments_count || 0,
                        term: cls.term,
                        grade: cls.grade_name || 'N/A',
                        fingerprintCount: 0
                    }));
                    setClasses(mappedClasses);
                }
            } catch (err) {
                console.error('Error fetching classes:', err);
                setError('Failed to load classes.');
            } finally {
                setIsLoading(false);
            }
        };

        fetchClasses();
    }, [teacherId]);

    const activeCount = classes.filter(c => c.status === 'active').length;
    const archivedCount = classes.filter(c => c.status === 'archived').length;
    const totalStudents = classes.reduce((sum, c) => sum + (c.studentCount || 0), 0);

    const stats = [
        { title: 'Active Classes', value: activeCount.toString(), color: '#0A8041' },
        { title: 'Archived Classes', value: archivedCount.toString(), color: '#FF9933' },
        { title: 'Total Current Students', value: totalStudents.toString(), color: '#CB6CE6' }
    ];

    const filteredClasses = classes.filter(cls => {
        if (selectedTab === 0) return cls.status === 'active';
        if (selectedTab === 1) return cls.status === 'archived';
        return true;
    });

    return (
        <MainLayout>
            <TitleBar
                title="Classes"
                subTitle="Manage your classes and view student rosters"
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

                <div className={styles.classList}>
                    {isLoading ? (
                        <div className={styles.emptyState}>Loading classes...</div>
                    ) : error ? (
                        <div className={styles.emptyState} style={{ color: '#EF4444' }}>{error}</div>
                    ) : filteredClasses.length > 0 ? (
                        filteredClasses.map((cls) => (
                            <div key={cls.id} className={styles.classCard}>
                                <div className={styles.classMain}>
                                    <div className={styles.classNameRow}>
                                        <div className={styles.className}>{cls.className}</div>
                                        <div
                                            className={styles.statusBadge}
                                            style={{ color: cls.status === 'active' ? '#0A8041' : '#FF9933' }}
                                        >
                                            {cls.status}
                                        </div>
                                    </div>
                                    <div className={styles.classDescription}>{cls.description}</div>

                                    <div className={styles.classMeta}>
                                        <div className={styles.metaItem}>
                                            <Users className={styles.metaIcon} size={18} />
                                            <span>{cls.studentCount} students</span>
                                        </div>
                                        <div className={styles.metaItem}>
                                            <FileText className={styles.metaIcon} size={18} />
                                            <span>{cls.assignmentCount} Assignments</span>
                                        </div>
                                        <div className={styles.metaItem}>
                                            <Calendar className={styles.metaIcon} size={18} />
                                            <span>{cls.term}</span>
                                        </div>
                                        <div className={styles.metaItem}>
                                            <GraduationCap className={styles.metaIcon} size={18} />
                                            <span>{cls.grade}</span>
                                        </div>
                                        <div className={styles.metaItem}>
                                            <Fingerprint className={styles.metaIcon} size={18} />
                                            <span>{cls.fingerprintCount} Fingerprints submitted</span>
                                        </div>
                                    </div>
                                </div>

                                <button className={styles.viewDetailsButton}>
                                    <Eye size={20} />
                                    <span>View Details</span>
                                </button>
                            </div>
                        ))
                    ) : (
                        <div className={styles.emptyState}>
                            <School size={60} color="#CCC" />
                            <div className={styles.emptyTitle}>
                                No {selectedTab === 1 ? 'archived' : 'active'} classes available.
                            </div>
                            <div className={styles.emptySubtitle}>
                                Classes will appear here once created
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </MainLayout>
    );
};

export default TeacherClasses;
