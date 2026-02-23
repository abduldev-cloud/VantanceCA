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
                    // Filter for GRADED assignments
                    const graded = response.data.filter(item => item.status === 'GRADED' || item.status === 'SUBMITTED');
                    const mapped = graded.map(item => ({
                        id: item.task_id,
                        title: item.task_title,
                        description: item.task_description,
                        subject: item.class_name,
                        date: new Date(item.submitted_at || item.graded_at || Date.now()).toLocaleDateString(),
                        frequency: 'Once',
                        na: 0,
                        wa: 0,
                        pa: 0,
                        ca: item.score || 0
                    }));
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

    const filteredResults = results.filter(r =>
        r.title.toLowerCase().includes(search.toLowerCase()) ||
        r.subject.toLowerCase().includes(search.toLowerCase())
    );

    const StatPill = ({ label, count, color }) => (
        <div className={styles.statPillWrapper}>
            <div className={styles.statPill} style={{ backgroundColor: `${color}33` }}>
                {label}
            </div>
            <span className={styles.statCount}>{count}</span>
        </div>
    );

    return (
        <MainLayout>
            <div className={styles.header}>
                <Typography variant="displaySmall" weight="700">Results</Typography>
                <Typography variant="bodyMedium" color="#666">
                    View your practice results and analytics.
                </Typography>
            </div>

            <div className={styles.filterRow}>
                <div className={styles.searchBar}>
                    <img src={SearchIcon} alt="" />
                    <input
                        type="text"
                        placeholder="Search"
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
                    <option value="na">NA - Not Answered</option>
                    <option value="wa">WA - Wrong Answered</option>
                    <option value="pa">PA - Partially Answered</option>
                    <option value="ca">CA - Correct Answered</option>
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
                                <Typography variant="titleLarge" weight="600">{result.title}</Typography>
                                <Typography variant="bodySmall" color="#666" className={styles.resultDesc}>
                                    {result.description}
                                </Typography>

                                <div className={styles.metaRow}>
                                    <div className={styles.metaItem}>
                                        <img src={BookIcon} alt="" />
                                        <span>{result.subject}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <img src={CalendarIcon} alt="" />
                                        <span>{result.date}</span>
                                    </div>
                                    <div className={styles.metaItem}>
                                        <img src={CalendarIcon} alt="" />
                                        <span>{result.frequency}</span>
                                    </div>
                                </div>
                            </div>

                            <div className={styles.statsGrid}>
                                <StatPill label="NA" count={result.na} color="#8B6B00" />
                                <StatPill label="WA" count={result.wa} color="#B71C1C" />
                                <StatPill label="PA" count={result.pa} color="#E65100" />
                                <StatPill label="CA" count={result.ca} color="#006064" />
                            </div>
                        </div>
                    ))
                )}
            </div>
        </MainLayout>
    );
};

export default StudentResults;
