import React, { useState, useEffect } from 'react';
import MainLayout from '../../components/layout/MainLayout';
import Typography from '../../components/common/Typography';
import studentService from '../../services/studentService';
import SearchIcon from '../../assets/icon/search.png';
import BookIcon from '../../assets/icon/book.png';
import CalendarIcon from '../../assets/icon/calendar.png';
import styles from './Student.module.css';

const StudentResults = () => {
    const [filter, setFilter] = useState('all');
    const [search, setSearch] = useState('');
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState('');
    const [results, setResults] = useState([]);

    useEffect(() => {
        const fetchResults = async () => {
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
                    // Filter only GRADED or SUBMITTED assignments
                    const completed = response.data.filter(item => item.status === 'GRADED' || item.status === 'SUBMITTED');
                    const mapped = completed.map(item => {
                        const score = parseFloat(item.score) || 0;
                        const maxScore = parseFloat(item.max_score) || 100;
                        const percentage = maxScore > 0 ? Math.round((score / maxScore) * 100) : 0;
                        const deviation = parseFloat(item.deviation_percentage) || 0;

                        // Determine grade label based on percentage
                        let gradeLabel = 'NA';
                        let gradeColor = '#8B6B00';
                        if (percentage >= 80) {
                            gradeLabel = 'Excellent';
                            gradeColor = '#059669';
                        } else if (percentage >= 60) {
                            gradeLabel = 'Good';
                            gradeColor = '#2563EB';
                        } else if (percentage >= 40) {
                            gradeLabel = 'Average';
                            gradeColor = '#D97706';
                        } else if (percentage > 0) {
                            gradeLabel = 'Needs Work';
                            gradeColor = '#DC2626';
                        }

                        return {
                            id: item.task_id,
                            title: item.task_title,
                            description: item.task_description,
                            subject: item.class_name || 'N/A',
                            taskType: item.task_type || 'Assignment',
                            date: item.graded_at
                                ? new Date(item.graded_at).toLocaleDateString()
                                : item.submitted_at
                                    ? new Date(item.submitted_at).toLocaleDateString()
                                    : 'N/A',
                            score: score,
                            maxScore: maxScore,
                            percentage: percentage,
                            deviation: deviation,
                            feedback: item.feedback || null,
                            status: item.status,
                            gradeLabel: gradeLabel,
                            gradeColor: gradeColor,
                            teacherName: item.teacher_first_name
                                ? `${item.teacher_first_name} ${item.teacher_last_name || ''}`.trim()
                                : null
                        };
                    });
                    setResults(mapped);
                }
            } catch (err) {
                console.error('Error:', err);
                setError('Failed to load results.');
            } finally {
                setIsLoading(false);
            }
        };

        fetchResults();
    }, []);

    const filteredResults = results.filter(r => {
        const matchesSearch = r.title.toLowerCase().includes(search.toLowerCase()) ||
            r.subject.toLowerCase().includes(search.toLowerCase());
        if (!matchesSearch) return false;

        if (filter === 'all') return true;
        if (filter === 'excellent') return r.percentage >= 80;
        if (filter === 'good') return r.percentage >= 60 && r.percentage < 80;
        if (filter === 'average') return r.percentage >= 40 && r.percentage < 60;
        if (filter === 'needs_work') return r.percentage < 40;
        if (filter === 'graded') return r.status === 'GRADED';
        if (filter === 'submitted') return r.status === 'SUBMITTED';
        return true;
    });

    // Summary statistics
    const totalGraded = results.filter(r => r.status === 'GRADED').length;
    const avgScore = totalGraded > 0
        ? Math.round(results.filter(r => r.status === 'GRADED').reduce((sum, r) => sum + r.percentage, 0) / totalGraded)
        : 0;
    const bestScore = results.length > 0 ? Math.max(...results.map(r => r.percentage)) : 0;

    return (
        <MainLayout>
            <div className={styles.header}>
                <Typography variant="displaySmall" weight="700">Results</Typography>
                <Typography variant="bodyMedium" color="#666">
                    View your graded assignments and performance scores.
                </Typography>
            </div>

            {/* Summary Stats Row */}
            <div style={{ display: 'flex', gap: '16px', marginBottom: '20px', flexWrap: 'wrap' }}>
                <div style={{
                    flex: 1, minWidth: '150px', background: 'white', border: '1px solid #E2E8F0',
                    borderRadius: '12px', padding: '20px', textAlign: 'center'
                }}>
                    <div style={{ fontSize: '13px', color: '#64748B', fontWeight: 500, textTransform: 'uppercase', letterSpacing: '0.05em' }}>Completed</div>
                    <div style={{ fontSize: '28px', fontWeight: 700, color: '#0F172A', marginTop: '4px' }}>{results.length}</div>
                </div>
                <div style={{
                    flex: 1, minWidth: '150px', background: 'white', border: '1px solid #E2E8F0',
                    borderRadius: '12px', padding: '20px', textAlign: 'center'
                }}>
                    <div style={{ fontSize: '13px', color: '#64748B', fontWeight: 500, textTransform: 'uppercase', letterSpacing: '0.05em' }}>Graded</div>
                    <div style={{ fontSize: '28px', fontWeight: 700, color: '#2563EB', marginTop: '4px' }}>{totalGraded}</div>
                </div>
                <div style={{
                    flex: 1, minWidth: '150px', background: 'white', border: '1px solid #E2E8F0',
                    borderRadius: '12px', padding: '20px', textAlign: 'center'
                }}>
                    <div style={{ fontSize: '13px', color: '#64748B', fontWeight: 500, textTransform: 'uppercase', letterSpacing: '0.05em' }}>Avg Score</div>
                    <div style={{ fontSize: '28px', fontWeight: 700, color: '#059669', marginTop: '4px' }}>{avgScore}%</div>
                </div>
                <div style={{
                    flex: 1, minWidth: '150px', background: 'white', border: '1px solid #E2E8F0',
                    borderRadius: '12px', padding: '20px', textAlign: 'center'
                }}>
                    <div style={{ fontSize: '13px', color: '#64748B', fontWeight: 500, textTransform: 'uppercase', letterSpacing: '0.05em' }}>Best Score</div>
                    <div style={{ fontSize: '28px', fontWeight: 700, color: '#7C3AED', marginTop: '4px' }}>{bestScore}%</div>
                </div>
            </div>

            <div className={styles.filterRow}>
                <div className={styles.searchBar}>
                    <img src={SearchIcon} alt="" />
                    <input
                        type="text"
                        placeholder="Search assignments..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                    />
                </div>
                <select
                    className={styles.filterSelect}
                    value={filter}
                    onChange={(e) => setFilter(e.target.value)}
                >
                    <option value="all">Filter: All</option>
                    <option value="graded">Graded Only</option>
                    <option value="submitted">Awaiting Grade</option>
                    <option value="excellent">Excellent (80%+)</option>
                    <option value="good">Good (60-79%)</option>
                    <option value="average">Average (40-59%)</option>
                    <option value="needs_work">Needs Work (&lt;40%)</option>
                </select>
            </div>

            <div className={styles.listContainer}>
                {isLoading ? (
                    <Typography align="center" style={{ width: '100%', padding: '40px' }}>Loading results...</Typography>
                ) : error ? (
                    <Typography align="center" color="#EF4444" style={{ width: '100%', padding: '40px' }}>{error}</Typography>
                ) : filteredResults.length === 0 ? (
                    <Typography align="center" style={{ width: '100%', padding: '40px' }}>No results found.</Typography>
                ) : (
                    filteredResults.map((result) => (
                        <div key={result.id} className={styles.resultCard}>
                            <div className={styles.resultInfo}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
                                    <Typography variant="titleLarge" weight="600">{result.title}</Typography>
                                    <span style={{
                                        padding: '3px 10px',
                                        borderRadius: '12px',
                                        fontSize: '11px',
                                        fontWeight: 600,
                                        background: result.status === 'GRADED' ? '#D1FAE5' : '#FEF3C7',
                                        color: result.status === 'GRADED' ? '#065F46' : '#92400E'
                                    }}>
                                        {result.status === 'GRADED' ? 'Graded' : 'Awaiting Grade'}
                                    </span>
                                </div>

                                {result.description && (
                                    <Typography variant="bodySmall" color="#666" className={styles.resultDesc}>
                                        {result.description.length > 120 ? result.description.slice(0, 120) + '...' : result.description}
                                    </Typography>
                                )}

                                <div className={styles.metaRow}>
                                    <div className={styles.metaItem}>
                                        <img src={BookIcon} alt="" />
                                        <span>{result.subject}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <img src={CalendarIcon} alt="" />
                                        <span>{result.date}</span>
                                    </div>
                                    {result.teacherName && (
                                        <div className={styles.metaItem}>
                                            <span style={{ fontSize: '12px', color: '#64748B' }}>by {result.teacherName}</span>
                                        </div>
                                    )}
                                </div>

                                {result.feedback && (
                                    <div style={{
                                        marginTop: '10px', padding: '10px 14px',
                                        background: '#F8FAFC', borderRadius: '8px',
                                        borderLeft: '3px solid #004AAD', fontSize: '13px',
                                        color: '#475569', lineHeight: '1.5'
                                    }}>
                                        <strong style={{ color: '#1E293B' }}>Feedback:</strong> {result.feedback}
                                    </div>
                                )}
                            </div>

                            <div className={styles.statsGrid}>
                                {/* Score display */}
                                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '6px', minWidth: '90px' }}>
                                    <div style={{
                                        width: '64px', height: '64px', borderRadius: '50%',
                                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                                        background: `conic-gradient(${result.gradeColor} ${result.percentage * 3.6}deg, #F1F5F9 0deg)`,
                                        position: 'relative'
                                    }}>
                                        <div style={{
                                            width: '50px', height: '50px', borderRadius: '50%',
                                            background: 'white', display: 'flex', alignItems: 'center',
                                            justifyContent: 'center', fontWeight: 700, fontSize: '14px',
                                            color: result.gradeColor
                                        }}>
                                            {result.percentage}%
                                        </div>
                                    </div>
                                    <div style={{ fontSize: '12px', fontWeight: 600, color: result.gradeColor }}>
                                        {result.gradeLabel}
                                    </div>
                                    <div style={{ fontSize: '11px', color: '#94A3B8' }}>
                                        {result.score}/{result.maxScore}
                                    </div>
                                </div>

                                {/* Deviation indicator */}
                                {result.deviation > 0 && (
                                    <div style={{
                                        display: 'flex', flexDirection: 'column', alignItems: 'center',
                                        gap: '4px', minWidth: '70px'
                                    }}>
                                        <div style={{
                                            fontSize: '18px', fontWeight: 700,
                                            color: result.deviation > 15 ? '#DC2626' : '#059669'
                                        }}>
                                            {result.deviation}%
                                        </div>
                                        <div style={{ fontSize: '11px', color: '#64748B', textAlign: 'center' }}>
                                            Deviation
                                        </div>
                                    </div>
                                )}
                            </div>
                        </div>
                    ))
                )}
            </div>
        </MainLayout>
    );
};

export default StudentResults;
