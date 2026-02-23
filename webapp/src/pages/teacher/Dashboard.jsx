import React, { useState, useEffect } from 'react';
import {
    Plus,
    ChevronRight,
    RefreshCw,
    TrendingUp,
    TrendingDown,
    CheckCircle2,
    AlertTriangle
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
import Typography from '../../components/common/Typography';
import CreateAssignmentDialog from './CreateAssignmentDialog';
import teacherService from '../../services/teacherService';
import styles from './Dashboard.module.css';

const TeacherDashboard = () => {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [timeRange, setTimeRange] = useState('30d');
    const [selectedClass, setSelectedClass] = useState('All');
    const [period, setPeriod] = useState('Monthly');
    const [isLoading, setIsLoading] = useState(true);
    const [dashboardData, setDashboardData] = useState({
        pendingReview: 0,
        gradedThisWeek: 0,
        activeStudents: 0,
        anomalies: []
    });
    const [error, setError] = useState('');

    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    const teacherId = userData.role_entity_id;
    const teacherName = `${userData.first_name || ''} ${userData.last_name || ''}`.trim() || 'Teacher';

    useEffect(() => {
        const fetchDashboardData = async () => {
            if (!teacherId) {
                setError('Teacher ID not found. Please log in again.');
                setIsLoading(false);
                return;
            }

            try {
                const response = await teacherService.getStats(teacherId);
                if (response.success) {
                    setDashboardData({
                        pendingReview: response.data.pending_review,
                        gradedThisWeek: response.data.graded_this_week,
                        activeStudents: response.data.active_students,
                        anomalies: response.data.anomalies.map(a => ({
                            name: `${a.first_name} ${a.last_name}`,
                            deviation: `${a.deviation_percentage}% higher`,
                            task: a.task_title
                        }))
                    });
                }
            } catch (err) {
                console.error('Error fetching dashboard data:', err);
                setError('Failed to load dashboard statistics.');
            } finally {
                setIsLoading(false);
            }
        };

        fetchDashboardData();
    }, [teacherId]);

    const stats = [
        {
            title: 'Pending Review',
            value: dashboardData.pendingReview.toString(),
            color: '#FF9933',
            desc: 'Submissions awaiting review',
            link: '/teacher/grading?tab=0'
        },
        {
            title: 'Graded This Week',
            value: dashboardData.gradedThisWeek.toString(),
            color: '#0A8041',
            desc: 'Recently graded assignments',
            link: '/teacher/grading?tab=1'
        },
        {
            title: 'Active Students',
            value: dashboardData.activeStudents.toString(),
            color: '#CB6CE6',
            desc: 'Students enrolled in your classes'
        }
    ];

    const aiUsageCards = [
        {
            title: 'Writing Fingerprint',
            subTitle: 'Average Deviation',
            value: '12.4%',
            trend: 'up',
            period: 'last 30d'
        },
        {
            title: 'Writing Fingerprint',
            subTitle: 'Total',
            value: '156',
            trend: 'up',
            period: 'last 30d'
        },
        {
            title: 'AI Prompt Used',
            subTitle: 'Average',
            value: '4.2',
            trend: 'down',
            period: 'last 30d'
        },
        {
            title: 'AI Prompt Used',
            subTitle: 'Total',
            value: '1.2k',
            trend: 'up',
            period: 'last 30d'
        }
    ];

    const chartData = [
        { name: 'Jan', value: 40 },
        { name: 'Feb', value: 30 },
        { name: 'Mar', value: 65 },
        { name: 'Apr', value: 45 },
        { name: 'May', value: 90 },
        { name: 'Jun', value: 55 },
        { name: 'Jul', value: 70 },
        { name: 'Aug', value: 40 },
        { name: 'Sep', value: 80 },
        { name: 'Oct', value: 95 },
        { name: 'Nov', value: 60 },
        { name: 'Dec', value: 75 }
    ];

    const anomalies = dashboardData.anomalies;

    return (
        <MainLayout>
            <div className={styles.container}>
                <div className={styles.header}>
                    <div className={styles.welcomeText}>
                        <h1 className={styles.welcomeTitle}>
                            Welcome Back, <span className={styles.userName}>{teacherName}</span>
                        </h1>
                        <p className={styles.welcomeSubtitle}>Here’s what’s happening with your students.</p>
                        {error && <p style={{ color: '#EF4444', fontSize: '14px', marginTop: '10px' }}>{error}</p>}
                    </div>
                    <button className={styles.createBtn} onClick={() => setIsModalOpen(true)}>
                        <Plus size={20} />
                        <span>Create Assignment</span>
                    </button>
                </div>

                <div className={styles.statsGrid}>
                    {stats.map((stat, index) => (
                        <div key={index} className={styles.statsCard}>
                            <div className={styles.statsTitle}>{stat.title}</div>
                            <div className={styles.statsValue} style={{ color: stat.color }}>{stat.value}</div>
                            <div className={styles.statsDesc}>{stat.desc}</div>
                            {stat.link && (
                                <button className={styles.viewAllButton}>
                                    <span>View All</span>
                                    <ChevronRight size={16} />
                                </button>
                            )}
                        </div>
                    ))}
                </div>

                <div className={styles.mainGrid}>
                    {/* AI Usage Overview */}
                    <div className={styles.chartCard}>
                        <div className={styles.chartHeader}>
                            <div className={styles.chartTitle}>AI Usage Overview</div>
                            <div className={styles.filters}>
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
                                <RefreshCw size={18} style={{ cursor: 'pointer', color: '#666' }} />
                            </div>
                        </div>

                        <div className={styles.trendingGrid}>
                            {aiUsageCards.map((card, index) => (
                                <div key={index} className={styles.trendingCard}>
                                    <div className={styles.trendingTitle}>{card.title}</div>
                                    <div className={styles.trendingSubtitle}>{card.subTitle}</div>
                                    <div className={styles.trendingValueWrapper}>
                                        <div className={styles.trendingValue}>{card.value}</div>
                                        {card.trend === 'up' ? (
                                            <TrendingUp size={16} color="#0A8041" />
                                        ) : (
                                            <TrendingDown size={16} color="#EF4444" />
                                        )}
                                    </div>
                                    <div className={styles.trendingPeriod}>
                                        in the <span>{card.period}</span>
                                    </div>
                                </div>
                            ))}
                        </div>

                        <div className={styles.usageChartWrapper}>
                            <div className={styles.chartRow}>
                                <div className={styles.chartRowTitle}>Average Writing Fingerprints Alerts</div>
                                <div className={styles.chartFilters}>
                                    <div className={styles.filters}>
                                        <span>Class:</span>
                                        <select
                                            className={styles.select}
                                            value={selectedClass}
                                            onChange={(e) => setSelectedClass(e.target.value)}
                                        >
                                            <option value="All">All</option>
                                            <option value="Class 10-A">Class 10-A</option>
                                            <option value="Class 12-B">Class 12-B</option>
                                        </select>
                                    </div>
                                    <select
                                        className={styles.select}
                                        value={period}
                                        onChange={(e) => setPeriod(e.target.value)}
                                    >
                                        <option value="Yearly">Yearly</option>
                                        <option value="Monthly">Monthly</option>
                                        <option value="Weekly">Weekly</option>
                                    </select>
                                </div>
                            </div>

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

                    {/* Writing Fingerprint Alerts */}
                    <div className={styles.alertsCard}>
                        <div className={styles.alertsTitle}>Writing Fingerprint Alerts</div>
                        <div className={styles.alertsSubtitle}>Possible Authorship Anomaly</div>
                        <p className={styles.alertsHint}>These submissions show potential deviation.</p>

                        {anomalies.length > 0 ? (
                            <div className={styles.alertsList}>
                                {anomalies.map((alert, index) => (
                                    <div key={index} className={styles.alertItem}>
                                        <div className={styles.alertStudent}>{alert.name}</div>
                                        <div className={styles.alertDeviation}>Potential {alert.deviation} deviation.</div>
                                    </div>
                                ))}
                            </div>
                        ) : (
                            <div className={styles.noAnomalies}>
                                <CheckCircle2 size={32} />
                                <div className={styles.noAnomaliesTitle}>No Anomalies Detected</div>
                                <div className={styles.noAnomaliesSubtitle}>All submissions appear authentic</div>
                            </div>
                        )}
                    </div>
                </div>
            </div>
            <CreateAssignmentDialog isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
        </MainLayout>
    );
};

export default TeacherDashboard;
