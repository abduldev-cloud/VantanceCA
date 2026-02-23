import React, { useState } from 'react';
import {
    Calendar,
    Fingerprint,
    MessageSquare,
    X,
    CheckCircle,
    ArrowRight
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import styles from './GradingReview.module.css';

const GradingReview = () => {
    const [activeTab, setActiveTab] = useState('chat');
    const [grade, setGrade] = useState('');

    const studentData = {
        name: 'Arun Kumar',
        task: 'The Future of AI in Education',
        date: 'Oct 12, 2025 10:30 AM',
        deviation: 12,
        words: 850,
        content: `
            The integration of Artificial Intelligence in education is not just a trend, but a paradigm shift. 
            AI-powered tools are personalizing learning experiences, providing real-time feedback, and enabling 
            educators to focus on more complex student interactions. However, ethical considerations like 
            data privacy and algorithmic bias must be addressed to ensure a fair and equitable future for all learners.
        `
    };

    const rubrics = [
        {
            title: 'Content Analysis', points: 40, criteria: [
                { text: 'Strong thesis statement addressing the core prompt.', color: '#0A8041' },
                { text: 'Clear logical flow between paragraphs.', color: '#0A8041' }
            ]
        },
        {
            title: 'Grammar & Style', points: 30, criteria: [
                { text: 'Minimal grammatical errors and professional tone.', color: '#0A8041' }
            ]
        }
    ];

    return (
        <MainLayout>
            <div className={styles.container}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end' }}>
                    <div>
                        <h1 style={{ fontSize: '28px', fontWeight: '600', color: '#142228', margin: 0 }}>Grading</h1>
                        <p style={{ fontSize: '16px', color: '#142228', marginTop: '4px' }}>Review work and enter a final grade</p>
                    </div>
                </div>

                <div className={styles.mainRow}>
                    <div className={styles.leftCol}>
                        <div className={styles.card}>
                            <div className={styles.studentHeader}>
                                <div className={styles.studentInfo}>
                                    <h2>{studentData.name}</h2>
                                    <p>{studentData.task}</p>
                                </div>
                                <div className={styles.metaRow}>
                                    <div className={styles.metaItem}>
                                        <Calendar size={15} />
                                        <span>{studentData.date}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <Fingerprint size={20} />
                                        <span>Deviation: {studentData.deviation}%</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <span>{studentData.words} words</span>
                                    </div>
                                    <div className={styles.metaItem} style={{ cursor: 'pointer' }}>
                                        <MessageSquare size={20} />
                                    </div>
                                </div>
                            </div>

                            <div className={styles.contentArea}>
                                {studentData.content}
                            </div>
                        </div>

                        <div className={styles.tabsContainer}>
                            <div className={styles.tabHeader}>
                                <div
                                    className={`${styles.tab} ${activeTab === 'chat' ? styles.tabActive : ''}`}
                                    onClick={() => setActiveTab('chat')}
                                >
                                    AI Chat Log
                                </div>
                                <div
                                    className={`${styles.tab} ${activeTab === 'rubric' ? styles.tabActive : ''}`}
                                    onClick={() => setActiveTab('rubric')}
                                >
                                    Rubric
                                </div>
                            </div>
                            <div className={styles.tabContent}>
                                {activeTab === 'chat' ? (
                                    <div style={{ display: 'flex', flexDirection: 'column' }}>
                                        <div className={`${styles.chatMessage} ${styles.chatMe}`}>
                                            How can I improve my introduction?
                                        </div>
                                        <div className={`${styles.chatMessage} ${styles.chatAI}`}>
                                            Try adding a more compelling hook that captures the reader's attention immediately.
                                        </div>
                                    </div>
                                ) : (
                                    <div>
                                        {rubrics.map((r, i) => (
                                            <div key={i} style={{ marginBottom: '20px' }}>
                                                <div className={styles.rubricRow}>
                                                    <div className={styles.rubricTitle}>{r.title}</div>
                                                    <div className={styles.rubricPoints}>{r.points} points</div>
                                                </div>
                                                {r.criteria.map((c, j) => (
                                                    <div key={j} className={styles.criterion}>
                                                        <CheckCircle size={20} color={c.color} />
                                                        <span style={{ color: c.color }}>{c.text}</span>
                                                    </div>
                                                ))}
                                            </div>
                                        ))}
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>

                    <div className={styles.rightCol}>
                        <div className={styles.gradeCard}>
                            <div className={styles.gradeTitle}>Enter Grade</div>
                            <input
                                className={styles.gradeInput}
                                placeholder="0"
                                type="number"
                                value={grade}
                                onChange={(e) => setGrade(e.target.value)}
                            />
                            <div className={styles.totalPoints}>
                                <span>{grade || '0'}</span>
                                <span>/100</span>
                            </div>
                            <button className={styles.btnSubmit}>
                                <ArrowRight size={16} />
                                Submit
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </MainLayout>
    );
};

export default GradingReview;
