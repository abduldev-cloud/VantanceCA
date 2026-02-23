import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import MainLayout from '../../components/layout/MainLayout';
import Typography from '../../components/common/Typography';
import studentService from '../../services/studentService';
import BookIcon from '../../assets/icon/book.png';
import CalendarIcon from '../../assets/icon/calendar.png';
import ClockIcon from '../../assets/icon/clock.png';
import styles from './Student.module.css';

const StudentPractices = () => {
    const navigate = useNavigate();
    const [selectedTab, setSelectedTab] = useState(0);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState('');
    const [practices, setPractices] = useState([]);

    useEffect(() => {
        const fetchAssignments = async () => {
            try {
                const userData = JSON.parse(localStorage.getItem('userData') || '{}');
                const learnerId = userData.role_entity_id;

                if (!learnerId) {
                    setError('Unable to identify student.');
                    setIsLoading(false);
                    return;
                }

                const response = await studentService.getAssignments(learnerId);
                if (response.success) {
                    const mapped = response.data.map(item => ({
                        id: item.task_id,
                        title: item.task_title,
                        description: item.task_description,
                        className: item.class_name,
                        dueDate: new Date(item.due_date).toLocaleDateString(),
                        duration: '00:10:00', // Mock duration as it's not in DB
                        frequency: 'Once',
                        status: item.status // e.g., 'ASSIGNED', 'SUBMITTED', 'GRADED'
                    }));
                    setPractices(mapped);
                }
            } catch (err) {
                console.error('Error:', err);
                setError('Failed to load assignments.');
            } finally {
                setIsLoading(false);
            }
        };

        fetchAssignments();
    }, []);

    const filteredPractices = practices.filter(p => {
        if (selectedTab === 0) return p.status === 'ASSIGNED';
        if (selectedTab === 1) return p.status === 'ASSIGNED'; // For now mapping to assigned
        if (selectedTab === 2) return p.status === 'GRADED' || p.status === 'SUBMITTED';
        return true;
    });

    const tabs = [
        { title: 'Pending', count: practices.filter(p => p.status === 'ASSIGNED').length, color: '#FF3B30' },
        { title: 'Upcoming', count: 0, color: '#FF9500' },
        { title: 'Completed', count: practices.filter(p => p.status === 'GRADED' || p.status === 'SUBMITTED').length, color: '#34C759' },
    ];

    return (
        <MainLayout>
            <div className={styles.header}>
                <Typography variant="headlineSmall" weight="700">Practices</Typography>
                <Typography variant="bodyMedium" color="#666">
                    View current and upcoming practices.
                </Typography>
            </div>

            <div className={styles.tabsRow}>
                {tabs.map((tab, index) => (
                    <div
                        key={index}
                        className={styles.tabCard}
                        onClick={() => setSelectedTab(index)}
                    >
                        <div className={styles.tabTitle}>{tab.title}</div>
                        <div className={styles.tabCount} style={{ color: tab.color }}>
                            {tab.count}
                        </div>
                    </div>
                ))}
            </div>

            <div className={styles.listContainer}>
                {isLoading ? (
                    <Typography align="center" style={{ width: '100%', padding: '40px' }}>Loading practices...</Typography>
                ) : error ? (
                    <Typography align="center" color="#EF4444" style={{ width: '100%', padding: '40px' }}>{error}</Typography>
                ) : filteredPractices.length === 0 ? (
                    <Typography align="center" style={{ width: '100%', padding: '40px' }}>No practices found for this category.</Typography>
                ) : (
                    filteredPractices.map((practice) => (
                        <div key={practice.id} className={styles.practiceCard}>
                            <div className={styles.practiceInfo}>
                                <div className={styles.practiceTitle}>{practice.title}</div>
                                <div className={styles.practiceDesc}>{practice.description}</div>

                                <div className={styles.metaGrid}>
                                    <div className={styles.metaItem}>
                                        <img src={BookIcon} alt="" />
                                        <span>{practice.className}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <img src={CalendarIcon} alt="" />
                                        <span>{practice.dueDate}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <img src={ClockIcon} alt="" />
                                        <span>{practice.duration}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <img src={CalendarIcon} alt="" />
                                        <span>{practice.frequency}</span>
                                    </div>
                                </div>
                            </div>

                            <button
                                className={styles.startBtn}
                                onClick={() => navigate(`/student/writingpad?id=${practice.id}`)}
                            >
                                Start Practices
                            </button>
                        </div>
                    ))
                )}
            </div>
        </MainLayout>
    );
};

export default StudentPractices;
