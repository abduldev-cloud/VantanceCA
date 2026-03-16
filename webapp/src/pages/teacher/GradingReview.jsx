import React, { useState, useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import {
    Calendar,
    Fingerprint,
    MessageSquare,
    X,
    CheckCircle,
    ArrowRight,
    ArrowLeft,
    Sparkles
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import teacherService from '../../services/teacherService';
import styles from './GradingReview.module.css';

const GradingReview = () => {
    const location = useLocation();
    const navigate = useNavigate();
    const submission = location.state?.submission;

    const [activeTab, setActiveTab] = useState('chat');
    const [grade, setGrade] = useState(submission?.score || '');
    const [feedback, setFeedback] = useState(submission?.feedback || '');
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [chatHistory, setChatHistory] = useState([]);
    const [isChatLoading, setIsChatLoading] = useState(false);
    const [isAutoGrading, setIsAutoGrading] = useState(false);

    useEffect(() => {
        if (activeTab === 'chat' && submission?.learner_task_id) {
            const fetchChat = async () => {
                setIsChatLoading(true);
                try {
                    const res = await teacherService.getChatHistory(submission.learner_task_id);
                    if (res.success) {
                        setChatHistory(res.data || []);
                    }
                } catch (err) {
                    console.error('Error fetching chat history:', err);
                } finally {
                    setIsChatLoading(false);
                }
            };
            fetchChat();
        }
    }, [activeTab, submission?.learner_task_id]);

    if (!submission) {
        return (
            <MainLayout>
                <div style={{ padding: '40px', textAlign: 'center' }}>
                    <h2>No submission data found.</h2>
                    <button onClick={() => navigate(-1)} className={styles.btnRemind} style={{ marginTop: '20px' }}>
                        Go Back
                    </button>
                </div>
            </MainLayout>
        );
    }

    const handleSubmitGrade = async () => {
        if (!grade) {
            alert('Please enter a grade.');
            return;
        }

        setIsSubmitting(true);
        try {
            const res = await teacherService.submitGrade(submission.learner_task_id, grade, feedback);
            if (res.success) {
                alert('Grade submitted successfully!');
                navigate(-1);
            } else {
                alert(res.message || 'Failed to submit grade.');
            }
        } catch (err) {
            console.error('Error submitting grade:', err);
            alert('An error occurred while submitting the grade.');
        } finally {
            setIsSubmitting(false);
        }
    };

    const handleAutoGrade = async () => {
        if (isAutoGrading) return;

        setIsAutoGrading(true);
        console.log('AI Auto-Grading started for:', submission.learner_task_id);
        try {
            const res = await teacherService.autoGrade(submission.learner_task_id);
            console.log('AI Auto-Grading Response:', res);
            if (res.success) {
                setGrade(res.score);
                setFeedback(res.feedback);
            } else {
                alert(res.message || 'Auto-grading failed.');
            }
        } catch (err) {
            console.error('Error auto-grading:', err);
            alert('An error occurred during AI grading.');
        } finally {
            setIsAutoGrading(false);
        }
    };

    const studentData = {
        name: `${submission.first_name} ${submission.last_name}`,
        task: submission.task_title || 'Assignment Task',
        date: submission.submitted_at ? new Date(submission.submitted_at).toLocaleString() : 'Not submitted',
        deviation: submission.deviation_percentage || 0,
        words: submission.word_count || 0,
        content: submission.submission_text || 'No content provided.'
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
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '20px' }}>
                    <button
                        onClick={() => navigate(-1)}
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
                        <ArrowLeft size={18} /> Back
                    </button>
                    <div style={{ textAlign: 'right' }}>
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

                            <div
                                className={styles.contentArea}
                                dangerouslySetInnerHTML={{ __html: studentData.content }}
                            />
                        </div>

                        <div className={styles.card} style={{ marginTop: '20px' }}>
                            <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '15px' }}>Teacher Feedback</h3>
                            <textarea
                                className={styles.feedbackInput}
                                placeholder="Enter your feedback here..."
                                value={feedback}
                                onChange={(e) => setFeedback(e.target.value)}
                                style={{
                                    width: '100%',
                                    minHeight: '120px',
                                    padding: '15px',
                                    borderRadius: '12px',
                                    border: '1px solid #EEE',
                                    fontSize: '14px',
                                    resize: 'vertical',
                                    outline: 'none',
                                    background: '#F8F9FA'
                                }}
                            ></textarea>
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
                                        {isChatLoading ? (
                                            <div style={{ textAlign: 'center', padding: '20px' }}>Loading chat history...</div>
                                        ) : chatHistory.length === 0 ? (
                                            <div style={{ textAlign: 'center', padding: '20px', color: '#6B7280' }}>No AI chat logs found for this submission.</div>
                                        ) : (
                                            chatHistory.map((msg, idx) => (
                                                <div
                                                    key={msg.message_id || idx}
                                                    className={`${styles.chatMessage} ${msg.sender === 'STUDENT' ? styles.chatMe : styles.chatAI}`}
                                                >
                                                    <div style={{ fontSize: '10px', marginBottom: '4px', opacity: 0.7 }}>
                                                        {msg.sender === 'STUDENT' ? 'Student' : 'AI Assistant'}
                                                    </div>
                                                    {msg.message_content}
                                                </div>
                                            ))
                                        )}
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
                                <span>/10</span>
                            </div>
                            <button
                                className={styles.btnSubmit}
                                onClick={handleSubmitGrade}
                                disabled={isSubmitting}
                            >
                                <ArrowRight size={16} />
                                {isSubmitting ? 'Submitting...' : 'Submit'}
                            </button>
                            <button
                                className={styles.btnAutoGrade}
                                onClick={handleAutoGrade}
                                disabled={isAutoGrading || isSubmitting}
                            >
                                <Sparkles size={16} color="#4F46E5" />
                                <span>{isAutoGrading ? 'AI Grading...' : 'Auto-Grade with AI'}</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </MainLayout>
    );
};

export default GradingReview;
