import React, { useState, useEffect } from 'react';
import {
    Activity,
    AlertTriangle,
    ShieldAlert,
    CheckCircle2,
    RefreshCw
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import adminService from '../../services/adminService';
import { useRole } from '../../hooks/useRole';
import styles from './AdminApiQuotas.module.css';

const AdminApiQuotas = () => {
    const { isPlatformAdmin } = useRole();
    const [quotas, setQuotas] = useState([]);
    const [summary, setSummary] = useState({ total_tokens_used: 0, schools_near_limit: 0 });
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState('');

    useEffect(() => {
        fetchQuotas();
    }, []);

    const fetchQuotas = async () => {
        if (!isPlatformAdmin) return;
        setIsLoading(true);
        try {
            const res = await adminService.getApiQuotas();
            if (res.out_status === 'SUCCESS') {
                setQuotas(res.quotas);
                setSummary(res.summary);
            }
        } catch (err) {
            console.error('Failed to load quotas:', err);
            setError('Failed to fetch API quotas. Please try again later.');
        } finally {
            setIsLoading(false);
        }
    };

    if (!isPlatformAdmin) {
        return (
            <MainLayout>
                <div style={{ padding: '40px', textAlign: 'center', color: '#EF4444' }}>
                    <ShieldAlert size={48} style={{ margin: '0 auto 16px' }} />
                    <h2 style={{ fontSize: '24px', fontWeight: 'bold' }}>Access Denied</h2>
                    <p>Only Platform Administrators can view API quotas.</p>
                </div>
            </MainLayout>
        );
    }

    const calculatePercentage = (used, limit) => {
        if (!limit || limit === 0) return 0;
        const p = (used / limit) * 100;
        return p > 100 ? 100 : p;
    };

    const getStatusInfo = (used, limit) => {
        const p = calculatePercentage(used, limit);
        if (p >= 90) return { label: 'CRITICAL', color: '#DC2626', style: styles.badgeCritical };
        if (p >= 75) return { label: 'WARNING', color: '#D97706', style: styles.badgeWarning };
        return { label: 'NORMAL', color: '#059669', style: styles.badgeNormal };
    };

    return (
        <MainLayout>
            <TitleBar
                title="API Usage & Quotas"
                subTitle="Monitor AI token consumption and thresholds across schools."
                buttonTitle="Refresh Data"
                onTap={fetchQuotas}
            />

            <div className={styles.container}>
                <div className={styles.introBox}>
                    <h3><Activity size={20} color="#004AAD" /> AI Token Monitoring</h3>
                    <p>
                        Every time schools utilize generative AI (like the gemini model) to evaluate papers or generate rubrics, it consumes API tokens.
                        Keep track of usage limits here to prevent runaway server costs. The limits shown are monthly thresholds.
                    </p>
                </div>

                <div className={styles.statsGrid}>
                    <div className={styles.statCard}>
                        <div className={styles.statTitle}>Total Platform Tokens Used (This Month)</div>
                        <div className={styles.statValue}>
                            {summary.total_tokens_used.toLocaleString()}
                        </div>
                    </div>
                    <div className={styles.statCard}>
                        <div className={styles.statTitle}>Schools Near Limit (&ge;80% Quota)</div>
                        <div className={styles.statValue} style={{ color: summary.schools_near_limit > 0 ? '#DC2626' : '#0F172A' }}>
                            {summary.schools_near_limit} {summary.schools_near_limit > 0 && <AlertTriangle size={24} style={{ display: 'inline', verticalAlign: 'middle', marginLeft: '5px' }} />}
                        </div>
                    </div>
                </div>

                <div className={styles.tableContainer}>
                    {isLoading ? (
                        <div style={{ padding: '60px', textAlign: 'center' }}>
                            <RefreshCw className="spin" size={32} color="#94A3B8" />
                            <p style={{ marginTop: '12px', color: '#64748B' }}>Loading usage data...</p>
                        </div>
                    ) : error ? (
                        <div style={{ padding: '40px', textAlign: 'center', color: '#EF4444' }}>
                            {error}
                        </div>
                    ) : (
                        <table className={styles.table}>
                            <thead>
                                <tr>
                                    <th>Institute</th>
                                    <th>Month</th>
                                    <th>Quota Usage</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                {quotas.map(school => {
                                    const { label, color, style } = getStatusInfo(school.tokens_used, school.threshold_limit);
                                    const perc = calculatePercentage(school.tokens_used, school.threshold_limit);

                                    return (
                                        <tr key={school.quota_id}>
                                            <td>
                                                <div className={styles.schoolName}>
                                                    {school.institute_name}
                                                    {school.is_demo === 'Y' && <span className={styles.demoBadge}>DEMO</span>}
                                                </div>
                                            </td>
                                            <td>{school.month_year}</td>
                                            <td style={{ minWidth: '300px' }}>
                                                <div className={styles.progressLabel}>
                                                    <span>{school.tokens_used.toLocaleString()} tokens</span>
                                                    <span>{school.threshold_limit.toLocaleString()} limit</span>
                                                </div>
                                                <div className={styles.progressBarContainer}>
                                                    <div
                                                        className={styles.progressBar}
                                                        style={{ width: `${perc}%`, backgroundColor: color }}
                                                    ></div>
                                                </div>
                                                <div style={{ fontSize: '12px', color: '#64748B', marginTop: '4px', textAlign: 'right' }}>
                                                    {perc.toFixed(1)}% Used
                                                </div>
                                            </td>
                                            <td>
                                                <div className={`${styles.alertBadge} ${style}`}>
                                                    {label === 'NORMAL' ? <CheckCircle2 size={14} /> : <AlertTriangle size={14} />}
                                                    {label}
                                                </div>
                                            </td>
                                        </tr>
                                    );
                                })}
                                {quotas.length === 0 && (
                                    <tr>
                                        <td colSpan="4" style={{ textAlign: 'center', padding: '40px', color: '#64748B' }}>
                                            No active quotas found for this billing cycle.
                                        </td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    )}
                </div>
            </div>
        </MainLayout>
    );
};

export default AdminApiQuotas;
