import React, { useState, useEffect } from 'react';
import { ShieldAlert, RefreshCw, Layers } from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import adminService from '../../services/adminService';
import { useRole } from '../../hooks/useRole';
import styles from './AdminSecurityLogs.module.css';

const AdminSecurityLogs = () => {
    const { isPlatformAdmin } = useRole();
    const [logs, setLogs] = useState([]);
    const [totalLogs, setTotalLogs] = useState(0);
    const [page, setPage] = useState(1);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState('');
    const pageSize = 15;

    const fetchLogs = async () => {
        setIsLoading(true);
        setError('');
        try {
            const data = await adminService.getAuditLogs(page, pageSize);
            if (data.out_status === 'SUCCESS') {
                setLogs(data.logs || []);
                setTotalLogs(data.total || 0);
            }
        } catch (err) {
            console.error('Failed to load audit logs:', err);
            setError('Could not retrieve audit logs. Please try again.');
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        fetchLogs();
    }, [page]);

    // Format MySQL timestamp nicely
    const formatTime = (ts) => {
        if (!ts) return 'Unknown';
        const date = new Date(ts);
        return new Intl.DateTimeFormat('en-US', {
            month: 'short', day: 'numeric',
            hour: 'numeric', minute: 'numeric', second: 'numeric',
            hour12: true
        }).format(date);
    };

    if (!isPlatformAdmin) {
        return (
            <MainLayout>
                <div style={{ padding: '40px', textAlign: 'center', color: '#667085' }}>
                    <ShieldAlert size={48} style={{ marginBottom: '16px' }} />
                    <h2>Access Denied</h2>
                    <p>You must be a Platform Administrator to access the master audit logs.</p>
                </div>
            </MainLayout>
        );
    }

    return (
        <MainLayout>
            <TitleBar
                title="Security & Audit Logs"
                subTitle="Chronological record of critical administrative actions across the platform"
            />

            <div className={styles.container}>
                <div className={styles.introBox}>
                    <h3><ShieldAlert size={20} color="#047857" /> Master Audit Trail</h3>
                    <p>
                        For compliance and security auditing, all critical operations are logged here in real-time.
                        This includes school creations, user deletions, bulk imports, and system configuration modifications.
                        This log is strictly read-only and cannot be tampered with.
                    </p>
                </div>

                {error && <div style={{ color: '#EF4444', marginBottom: '10px' }}>{error}</div>}

                <div className={styles.tableContainer}>
                    <table className={styles.table}>
                        <thead>
                            <tr>
                                <th>Timestamp</th>
                                <th>User Origin</th>
                                <th>Action Code</th>
                                <th>Description of Action</th>
                                <th>IP Address</th>
                            </tr>
                        </thead>
                        <tbody>
                            {isLoading && logs.length === 0 ? (
                                <tr>
                                    <td colSpan="5" style={{ textAlign: 'center', padding: '40px' }}>
                                        <RefreshCw className="spinner" size={24} color="#667085" />
                                        <div style={{ marginTop: '10px', color: '#667085' }}>Loading secure logs...</div>
                                    </td>
                                </tr>
                            ) : logs.length === 0 ? (
                                <tr>
                                    <td colSpan="5" style={{ textAlign: 'center', padding: '40px' }}>
                                        <Layers size={24} color="#667085" style={{ marginBottom: '8px' }} />
                                        <div style={{ color: '#667085' }}>No audit logs recorded yet.</div>
                                    </td>
                                </tr>
                            ) : (
                                logs.map(log => (
                                    <tr key={log.log_id}>
                                        <td className={styles.timeCell}>{formatTime(log.created_at)}</td>
                                        <td>
                                            <div className={styles.userCell}>{log.user_name}</div>
                                            <div className={styles.roleBadge}>{log.role_name}</div>
                                        </td>
                                        <td>
                                            <span className={styles.actionCell}>{log.action_type}</span>
                                        </td>
                                        <td className={styles.descCell}>{log.description}</td>
                                        <td className={styles.ipCell}>{log.ip_address || '---'}</td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>

                    {!isLoading && totalLogs > 0 && (
                        <div className={styles.pagination}>
                            <div className={styles.pageInfo}>
                                Showing {((page - 1) * pageSize) + 1} to {Math.min(page * pageSize, totalLogs)} of {totalLogs} logs
                            </div>
                            <div className={styles.pageControls}>
                                <button
                                    className={styles.pageBtn}
                                    disabled={page === 1}
                                    onClick={() => setPage(page - 1)}
                                >
                                    Previous
                                </button>
                                <button
                                    className={styles.pageBtn}
                                    disabled={page * pageSize >= totalLogs}
                                    onClick={() => setPage(page + 1)}
                                >
                                    Next
                                </button>
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </MainLayout>
    );
};

export default AdminSecurityLogs;
