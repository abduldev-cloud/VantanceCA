import React, { useState, useEffect } from 'react';
import {
    TrendingUp,
    TrendingDown,
    RefreshCw,
    Search,
    ChevronDown,
    AlertTriangle,
    CheckCircle2
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
import adminService from '../../services/adminService';
import styles from './AdminDashboard.module.css';

const AdminDashboard = () => {
    const [timeRange, setTimeRange] = useState('30d');
    const [selectedClass, setSelectedClass] = useState('All');
    const [period, setPeriod] = useState('Monthly');
    const [isLoading, setIsLoading] = useState(true);
    const [statsData, setStatsData] = useState({
        activeStudents: 0,
        totalSchools: 0,
        systemUptime: '99.9%',
        anomalies: []
    });
    const [analytics, setAnalytics] = useState({
        kpis: [],
        chartData: []
    });
    const [error, setError] = useState('');

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const [statsRes, analyticsRes] = await Promise.all([
                    adminService.getStats(),
                    adminService.getAnalytics()
                ]);

                if (statsRes.success) {
                    setStatsData({
                        activeStudents: statsRes.data.active_students,
                        totalSchools: statsRes.data.total_schools,
                        systemUptime: statsRes.data.system_uptime,
                        anomalies: statsRes.data.anomalies || []
                    });
                }

                if (analyticsRes.success) {
                    setAnalytics({
                        kpis: analyticsRes.kpis,
                        chartData: analyticsRes.chartData
                    });
                }
            } catch (err) {
                console.error('Error:', err);
                setError('Failed to load portal statistics.');
            } finally {
                setIsLoading(false);
            }
        };
        fetchStats();
    }, []);

    const stats = [
        { title: 'Active Students', value: statsData.activeStudents.toLocaleString(), color: '#0A8041' },
        { title: 'Total Schools', value: statsData.totalSchools.toString(), color: '#FF9933' },
        { title: 'System Uptime', value: statsData.systemUptime, color: '#CB6CE6' }
    ];

    const aiUsageKPIs = analytics.kpis.length > 0 ? analytics.kpis : [
        { title: 'AI Stats', sub: 'Status', value: 'Loading...', trend: 'up' }
    ];

    const chartData = analytics.chartData.length > 0 ? analytics.chartData : [];

    if (isLoading) {
        return (
            <MainLayout>
                <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80vh' }}>
                    <RefreshCw className={styles.spin} size={48} color="#004AAD" />
                </div>
            </MainLayout>
        );
    }

    return (
        <MainLayout>
            <div className={styles.container}>
                <div className={styles.welcomeSection}>
                    <div>
                        <h1 className={styles.welcomeTitle}>Welcome Back, Admin</h1>
                        <p className={styles.welcomeSubtitle}>Here’s what’s happening across the platform.</p>
                    </div>
                    <button style={{
                        background: 'transparent',
                        border: 'none',
                        cursor: 'pointer',
                        padding: '8px'
                    }}>
                        <RefreshCw size={20} color="#666" />
                    </button>
                </div>

                <div className={styles.statsGrid}>
                    {stats.map((stat, index) => (
                        <div key={index} className={`${styles.statCard} ${index === 0 ? styles.statCardActive : ''}`}>
                            <div className={styles.statTitle}>{stat.title}</div>
                            <div className={styles.statValue} style={{ color: stat.color }}>{stat.value}</div>
                        </div>
                    ))}
                </div>

                <div className={styles.mainGrid}>
                    <div className={styles.aiUsageCard}>
                        <div className={styles.cardHeader}>
                            <div className={styles.cardTitle}>AI Usage Overview</div>
                            <button style={{ background: 'transparent', border: 'none', cursor: 'pointer' }}>
                                <RefreshCw size={18} color="#666" />
                            </button>
                        </div>

                        <div className={styles.filterRow}>
                            <div className={styles.filterItem}>
                                <span>Time Range:</span>
                                <select
                                    className={styles.select}
                                    value={timeRange}
                                    onChange={(e) => setTimeRange(e.target.value)}
                                >
                                    <option value="7d">7d</option>
                                    <option value="14d">14d</option>
                                    <option value="30d">30d</option>
                                    <option value="Term 1">Term 1</option>
                                </select>
                            </div>
                        </div>

                        <div className={styles.miniStatsGrid}>
                            {aiUsageKPIs.map((kpi, index) => (
                                <div key={index} className={styles.miniStatCard}>
                                    <div className={styles.miniStatTitle}>{kpi.title}</div>
                                    <div className={styles.miniStatSub}>{kpi.sub}</div>
                                    <div className={styles.miniStatValueRow}>
                                        <div className={styles.miniStatValue}>{kpi.value}</div>
                                        {kpi.trend === 'up' ? (
                                            <TrendingUp size={16} color="#0A8041" />
                                        ) : (
                                            <TrendingDown size={16} color="#EF4444" />
                                        )}
                                    </div>
                                    <div className={styles.miniStatPeriod}>
                                        in the <span>{timeRange}</span>
                                    </div>
                                </div>
                            ))}
                        </div>

                        <div className={styles.chartSection}>
                            <div className={styles.chartHeader}>
                                <div className={styles.chartTitle}>Average Writing Fingerprints Alerts</div>
                                <div style={{ display: 'flex', gap: '15px' }}>
                                    <div className={styles.filterItem}>
                                        <span>Class:</span>
                                        <select className={styles.select} value={selectedClass} onChange={e => setSelectedClass(e.target.value)}>
                                            <option>All</option>
                                            <option>Modern English</option>
                                        </select>
                                    </div>
                                    <div className={styles.filterItem}>
                                        <select className={styles.select} value={period} onChange={e => setPeriod(e.target.value)}>
                                            <option>Yearly</option>
                                            <option>Monthly</option>
                                            <option>Weekly</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div className={styles.divider} />
                            <div style={{ width: '100%', height: 200 }}>
                                <ResponsiveContainer width="100%" height="100%">
                                    <BarChart data={chartData}>
                                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#F0F0F0" />
                                        <XAxis
                                            dataKey="name"
                                            axisLine={false}
                                            tickLine={false}
                                            tick={{ fontSize: 10, fill: '#666' }}
                                        />
                                        <YAxis hide />
                                        <Tooltip
                                            cursor={{ fill: '#F5F5F5' }}
                                            contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px rgba(0,0,0,0.1)' }}
                                        />
                                        <Bar dataKey="value" radius={[4, 4, 0, 0]}>
                                            {chartData.map((entry, index) => (
                                                <Cell key={`cell-${index}`} fill={index % 2 === 0 ? '#004AAD' : '#CB6CE6'} />
                                            ))}
                                        </Bar>
                                    </BarChart>
                                </ResponsiveContainer>
                            </div>
                        </div>
                    </div>

                    <div className={styles.supportCard}>
                        <h2 className={styles.supportTitle}>Recent AI Alerts</h2>
                        <div className={styles.ticketList}>
                            {statsData.anomalies.length === 0 ? (
                                <div className={styles.emptyAlerts}>
                                    <CheckCircle2 size={40} color="#0A8041" />
                                    <p>No high deviation alerts found</p>
                                </div>
                            ) : (
                                statsData.anomalies.map((anomaly, index) => (
                                    <div key={index} className={styles.ticketItem}>
                                        <div className={styles.anomalyHeader}>
                                            <AlertTriangle size={16} color="#EF4444" />
                                            <span className={styles.ticketNumber}>{anomaly.deviation_percentage}% Deviation</span>
                                        </div>
                                        <div className={styles.ticketUser}>{anomaly.first_name} {anomaly.last_name}</div>
                                        <div className={styles.ticketSchool}>{anomaly.institute_name}</div>
                                        <div className={styles.ticketTask}>{anomaly.task_title}</div>
                                    </div>
                                ))
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </MainLayout>
    );
};

export default AdminDashboard;
