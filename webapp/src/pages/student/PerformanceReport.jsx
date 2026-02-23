import React, { useState } from 'react';
import MainLayout from '../../components/layout/MainLayout';
import Typography from '../../components/common/Typography';
import styles from './Performance.module.css';

const PerformanceReport = () => {
    const [filter, setFilter] = useState('all');

    const questions = [
        { id: 1, text: 'What is the primary objective of accounting?', status: 'CA', marks: '5/5' },
        { id: 2, text: 'Explain the concept of Double Entry System.', status: 'PA', marks: '3/5' },
        { id: 3, text: 'Distinguish between Bookkeeping and Accounting.', status: 'WA', marks: '1/5' },
        { id: 4, text: 'Define Assets and Liabilities.', status: 'CA', marks: '5/5' },
    ];

    const getStatusColor = (status) => {
        switch (status) {
            case 'CA': return '#006064';
            case 'WA': return '#B71C1C';
            case 'PA': return '#E65100';
            default: return '#8B6B00';
        }
    };

    return (
        <MainLayout>
            <div className={styles.container}>
                <div className={styles.breadcrumbs}>
                    <span>Paper <strong>Accountancy</strong></span> /
                    <span> Unit <strong>Meaning Scope of Accounting</strong></span> /
                    <span> Questions <strong>8/10</strong></span>
                </div>
                <div className={styles.metaInfo}>
                    Foundation: <strong>May 2025</strong> | Complete Date: <strong>01/12/2025 | Daily</strong>
                </div>

                <div className={styles.header}>
                    <Typography variant="headlineLarge" weight="700">Performance Report</Typography>
                    <select
                        className={styles.filterSelect}
                        value={filter}
                        onChange={(e) => setFilter(e.target.value)}
                    >
                        <option value="all">Filter</option>
                        <option value="ca">Correct</option>
                        <option value="wa">Wrong</option>
                        <option value="pa">Partial</option>
                    </select>
                </div>

                <div className={styles.statsLabelRow}>
                    <div className={styles.spacer}></div>
                    <div className={styles.statsLabels}>
                        <span>NA</span>
                        <span>WA</span>
                        <span>PA</span>
                        <span>CA</span>
                    </div>
                </div>

                <div className={styles.questionList}>
                    {questions.map((q) => (
                        <div key={q.id} className={styles.questionCard}>
                            <div className={styles.questionText}>
                                <Typography variant="bodyLarge" weight="500">
                                    {q.id}. {q.text}
                                </Typography>
                            </div>
                            <div className={styles.questionStats}>
                                {['NA', 'WA', 'PA', 'CA'].map(status => (
                                    <div key={status} className={styles.statDotWrapper}>
                                        {q.status === status ? (
                                            <div className={styles.activeDot} style={{ backgroundColor: getStatusColor(status) }}></div>
                                        ) : (
                                            <div className={styles.inactiveDot}></div>
                                        )}
                                    </div>
                                ))}
                            </div>
                            <div className={styles.marks}>
                                {q.marks}
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </MainLayout>
    );
};

export default PerformanceReport;
