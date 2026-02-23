import React, { useState } from 'react';
import {
    TrendingUp,
    TrendingDown,
    RotateCcw,
    RefreshCw
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
import CreateAssignmentDialog from './CreateAssignmentDialog';
import styles from './Analytics.module.css';

const Analytics = () => {
    const [timeRange, setTimeRange] = useState('30d');
    const [selectedClass, setSelectedClass] = useState('All');
    const [selectedGrade, setSelectedGrade] = useState('All');
    const [selectedTerm, setSelectedTerm] = useState('All');
    const [period, setPeriod] = useState('month');
    const [isModalOpen, setIsModalOpen] = useState(false);

    const kpis = [
        { title: 'Grade', sub: 'Average across classes', value: '78.5%', trend: 'up' },
        { title: 'Assignment Time', sub: 'Average # hours', value: '4.2', trend: 'down' },
        { title: 'Writing Fingerprint', sub: 'Average Deviation', value: '12.4%', trend: 'up' },
        { title: 'Writing Fingerprint', sub: 'Total', value: '156', trend: 'up' },
        { title: 'AI Prompt Used', sub: 'Average', value: '3.5', trend: 'down' },
        { title: 'AI Prompt Used', sub: 'Total', value: '1.4k', trend: 'up' }
    ];

    const chartData = [
        { name: 'Jan', value: 40 },
        { name: 'Feb', value: 30 },
        { name: 'Mar', value: 65 },
        { name: 'Apr', value: 45 },
        { name: 'May', value: 90 },
        { name: 'Jun', value: 55 }
    ];

    return (
        <MainLayout>
            <div className={styles.container}>
                <div className={styles.header} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end' }}>
                    <div>
                        <h1 style={{ fontSize: '28px', fontWeight: '600', color: '#142228', margin: 0 }}>Analytics</h1>
                        <p style={{ fontSize: '16px', color: '#142228', marginTop: '4px' }}>
                            Track writing trends, performance, and AI use.
                        </p>
                    </div>
                    <button
                        onClick={() => setIsModalOpen(true)}
                        style={{
                            background: 'linear-gradient(90deg, #004AAD 0%, #CB6CE6 100%)',
                            color: 'white',
                            border: 'none',
                            padding: '8px 25px',
                            borderRadius: '50px',
                            fontSize: '14px',
                            fontWeight: '600',
                            cursor: 'pointer'
                        }}
                    >
                        Create Assignment
                    </button>
                </div>

                <div className={styles.mainCard}>
                    <div className={styles.leftCol}>
                        <div className={styles.kpiTitle}>Key Performance Indicators</div>
                        <div className={styles.filterRow}>
                            <div className={styles.filterItem}>
                                <span>Time Range:</span>
                                <select
                                    className={styles.select}
                                    value={timeRange}
                                    onChange={(e) => setTimeRange(e.target.value)}
                                >
                                    <option value="30d">last 30d</option>
                                    <option value="90d">last 90d</option>
                                    <option value="Term 1">Term 1</option>
                                </select>
                            </div>
                        </div>

                        <div className={styles.trendingGrid}>
                            {kpis.map((kpi, index) => (
                                <div key={index} className={styles.trendingCard}>
                                    <div className={styles.cardTitle}>{kpi.title}</div>
                                    <div className={styles.cardSubtitle}>{kpi.sub}</div>
                                    <div className={styles.cardValueRow}>
                                        <div className={styles.cardValue}>{kpi.value}</div>
                                        {kpi.trend === 'up' ? (
                                            <TrendingUp size={20} color="#0A8041" />
                                        ) : (
                                            <TrendingDown size={20} color="#EF4444" />
                                        )}
                                    </div>
                                    <div className={styles.cardPeriod}>
                                        in the <span>{timeRange}</span>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>

                    <div className={styles.rightCol}>
                        <div className={styles.filtersGrid}>
                            <div className={styles.filterItem}>
                                <span>Class:</span>
                                <select className={styles.select} value={selectedClass} onChange={e => setSelectedClass(e.target.value)}>
                                    <option>All</option>
                                    <option>Grade 11-A</option>
                                </select>
                            </div>
                            <div className={styles.filterItem}>
                                <span>Grade:</span>
                                <select className={styles.select} value={selectedGrade} onChange={e => setSelectedGrade(e.target.value)}>
                                    <option>All</option>
                                    <option>Grade 11</option>
                                </select>
                            </div>
                            <div className={styles.filterItem}>
                                <span>Term:</span>
                                <select className={styles.select} value={selectedTerm} onChange={e => setSelectedTerm(e.target.value)}>
                                    <option>All</option>
                                    <option>Fall 2025</option>
                                </select>
                            </div>
                            <div style={{ display: 'flex', gap: '8px' }}>
                                <select className={styles.select} value={period} onChange={e => setPeriod(e.target.value)}>
                                    <option value="month">Month</option>
                                    <option value="week">Week</option>
                                </select>
                                <button className={styles.navBtn} style={{ background: 'transparent', border: 'none', cursor: 'pointer' }}>
                                    <RotateCcw size={20} color="#666" />
                                </button>
                            </div>
                        </div>

                        <div className={styles.chartCard}>
                            <div className={styles.chartTitle}>Total Submissions</div>
                            <div className={styles.divider} />
                            <div style={{ flex: 1 }}>
                                <ResponsiveContainer width="100%" height="100%">
                                    <BarChart data={chartData}>
                                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#F0F0F0" />
                                        <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 12 }} />
                                        <YAxis hide />
                                        <Tooltip cursor={{ fill: 'transparent' }} />
                                        <Bar dataKey="value" radius={[4, 4, 0, 0]}>
                                            {chartData.map((entry, index) => (
                                                <Cell key={`cell-${index}`} fill={index % 2 === 0 ? '#004AAD' : '#CB6CE6'} />
                                            ))}
                                        </Bar>
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
                                        <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 12 }} />
                                        <YAxis hide />
                                        <Tooltip cursor={{ fill: 'transparent' }} />
                                        <Bar dataKey="value" radius={[4, 4, 0, 0]}>
                                            {chartData.map((entry, index) => (
                                                <Cell key={`cell-${index}`} fill={index === 2 ? '#CB6CE6' : '#004AAD'} />
                                            ))}
                                        </Bar>
                                    </BarChart>
                                </ResponsiveContainer>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <CreateAssignmentDialog isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
        </MainLayout>
    );
};

export default Analytics;
