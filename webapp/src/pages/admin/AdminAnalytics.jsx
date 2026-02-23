import React, { useState } from 'react';
import {
    TrendingUp,
    TrendingDown,
    RefreshCw,
    Search
} from 'lucide-react';
import {
    BarChart,
    Bar,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    ResponsiveContainer,
    Cell
} from 'recharts';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import styles from './AdminAnalytics.module.css';

const AdminAnalytics = () => {
    const [timeRange, setTimeRange] = useState('30d');
    const [institute, setInstitute] = useState('All');
    const [teacher, setTeacher] = useState('All');
    const [grade, setGrade] = useState('All');
    const [classFilter, setClassFilter] = useState('All');

    const kpis = [
        { title: 'Writing Fingerprint', sub: 'Average Deviation', value: '12.4%', trend: 'up' },
        { title: 'Writing Fingerprint', sub: 'Total', value: '1,560', trend: 'up' },
        { title: 'Writing Fingerprint', sub: 'Average Deviation', value: '12.4%', trend: 'up' },
        { title: 'Writing Fingerprint', sub: 'Total', value: '1,560', trend: 'up' },
        { title: 'AI Prompt Used', sub: 'Average', value: '4.2', trend: 'down' },
        { title: 'AI Prompt Used', sub: 'Total', value: '12.4k', trend: 'up' }
    ];

    const chartData = [
        { name: 'Jan', value: 30 },
        { name: 'Feb', value: 45 },
        { name: 'Mar', value: 60 },
        { name: 'Apr', value: 25 },
        { name: 'May', value: 80 },
        { name: 'Jun', value: 50 },
        { name: 'Jul', value: 65 },
        { name: 'Aug', value: 35 },
        { name: 'Sep', value: 75 },
        { name: 'Oct', value: 90 },
        { name: 'Nov', value: 55 },
        { name: 'Dec', value: 70 }
    ];

    return (
        <MainLayout>
            <TitleBar
                title="Analytics"
                subTitle="Track writing trends, performance, and AI use."
            />

            <div className={styles.container}>
                <div className={styles.kpiCard}>
                    <div className={styles.kpiHeader}>
                        <div className={styles.kpiTitle}>Key Performance Indicators</div>
                        <div className={styles.filterGroup}>
                            <span>Time Range:</span>
                            <select className={styles.select} value={timeRange} onChange={e => setTimeRange(e.target.value)}>
                                <option>7d</option>
                                <option>14d</option>
                                <option>30d</option>
                                <option>Term 1</option>
                            </select>
                        </div>
                    </div>

                    <div className={styles.mainContent}>
                        <div className={styles.kpiGrid}>
                            {kpis.map((kpi, index) => (
                                <div key={index} className={styles.miniStatCard}>
                                    <div className={styles.miniStatTitle}>{kpi.title}</div>
                                    <div className={styles.miniStatSub}>{kpi.sub}</div>
                                    <div className={styles.miniStatValueRow}>
                                        <div className={styles.miniStatValue}>{kpi.value}</div>
                                        {kpi.trend === 'up' ? <TrendingUp size={20} color="#0A8041" /> : <TrendingDown size={20} color="#EF4444" />}
                                    </div>
                                    <div className={styles.miniStatPeriod}>in the <span>{timeRange}</span></div>
                                </div>
                            ))}
                        </div>

                        <div className={styles.chartsColumn}>
                            <div className={styles.filterGrid}>
                                <div className={styles.filterGroup}>
                                    <label>Institute:</label>
                                    <select className={styles.select} value={institute} onChange={e => setInstitute(e.target.value)}>
                                        <option>All</option>
                                        <option>St. Mary's Academy</option>
                                    </select>
                                </div>
                                <div className={styles.filterGroup}>
                                    <label>Class:</label>
                                    <select className={styles.select} value={classFilter} onChange={e => setClassFilter(e.target.value)}>
                                        <option>All</option>
                                        <option>Modern English</option>
                                    </select>
                                </div>
                                <div className={styles.filterGroup}>
                                    <label>Teacher:</label>
                                    <select className={styles.select} value={teacher} onChange={e => setTeacher(e.target.value)}>
                                        <option>All</option>
                                        <option>John Doe</option>
                                    </select>
                                </div>
                                <div className={styles.filterGroup}>
                                    <label>Grade:</label>
                                    <select className={styles.select} value={grade} onChange={e => setGrade(e.target.value)}>
                                        <option>All</option>
                                        <option>Grade 10</option>
                                    </select>
                                </div>
                            </div>

                            <div className={styles.chartCard}>
                                <div className={styles.chartTitle}>Total Submissions</div>
                                <div className={styles.divider} />
                                <div style={{ flex: 1 }}>
                                    <ResponsiveContainer width="100%" height="100%">
                                        <BarChart data={chartData}>
                                            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#F0F0F0" />
                                            <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 10, fill: '#666' }} />
                                            <YAxis hide />
                                            <Tooltip cursor={{ fill: '#F5F5F5' }} />
                                            <Bar dataKey="value" fill="#004AAD" radius={[4, 4, 0, 0]} />
                                        </BarChart>
                                    </ResponsiveContainer>
                                </div>
                            </div>

                            <div className={styles.chartCard}>
                                <div className={styles.chartTitle}>Average Writing Fingerprints Alerts</div>
                                <div className={styles.divider} />
                                <div style={{ flex: 1 }}>
                                    <ResponsiveContainer width="100%" height="100%">
                                        <BarChart data={chartData}>
                                            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#F0F0F0" />
                                            <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 10, fill: '#666' }} />
                                            <YAxis hide />
                                            <Tooltip cursor={{ fill: '#F5F5F5' }} />
                                            <Bar dataKey="value" fill="#CB6CE6" radius={[4, 4, 0, 0]} />
                                        </BarChart>
                                    </ResponsiveContainer>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </MainLayout>
    );
};

export default AdminAnalytics;
