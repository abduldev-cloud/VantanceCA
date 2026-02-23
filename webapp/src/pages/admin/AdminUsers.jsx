import React, { useState, useEffect } from 'react';
import {
    Search,
    ChevronDown,
    ChevronLeft,
    ChevronRight,
    Eye,
    MoreVertical,
    RefreshCw
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import adminService from '../../services/adminService';
import styles from './AdminUsers.module.css';

const AdminUsers = () => {
    const [selectedTab, setSelectedTab] = useState(0); // 0: Active, 1: Inactive, 2: Total
    const [searchQuery, setSearchQuery] = useState('');
    const [isLoading, setIsLoading] = useState(true);
    const [users, setUsers] = useState([]);
    const [counts, setCounts] = useState({
        active: 0,
        inactive: 0,
        total: 0
    });
    const [error, setError] = useState('');

    useEffect(() => {
        const fetchUsers = async () => {
            setIsLoading(true);
            try {
                const status = selectedTab === 0 ? 'ACTIVE' : selectedTab === 1 ? 'INACTIVE' : null;
                const response = await adminService.getUsers(status);
                if (response.out_status === 'SUCCESS') {
                    setUsers(response.user_list);
                    if (response.user_counts && response.user_counts.length > 0) {
                        setCounts({
                            active: response.user_counts[0].active_users,
                            inactive: response.user_counts[0].archived_users,
                            total: response.user_counts[0].total_users
                        });
                    }
                }
            } catch (err) {
                console.error('Error fetching users:', err);
                setError('Failed to load users.');
            } finally {
                setIsLoading(false);
            }
        };
        fetchUsers();
    }, [selectedTab]);

    const stats = [
        { title: 'Active Users', value: counts.active.toLocaleString(), color: '#0A8041' },
        { title: 'Inactive Users', value: counts.inactive.toLocaleString(), color: '#FF9933' },
        { title: 'Total Users', value: counts.total.toLocaleString(), color: '#CB6CE6' }
    ];

    const filteredUsers = users.filter(user => {
        const matchesSearch = (user.first_name + ' ' + user.last_name).toLowerCase().includes(searchQuery.toLowerCase()) ||
            user.email.toLowerCase().includes(searchQuery.toLowerCase());
        return matchesSearch;
    });

    return (
        <MainLayout>
            <TitleBar
                title="Users"
                subTitle="View and manage all users across schools"
                buttonTitle="Add School"
                onTap={() => console.log('Add School Clicked')}
            />

            <div className={styles.container}>
                <div className={styles.statsGrid}>
                    {stats.map((stat, index) => (
                        <div
                            key={index}
                            className={`${styles.statCard} ${selectedTab === index ? styles.statCardActive : ''}`}
                            onClick={() => setSelectedTab(index)}
                        >
                            <div className={styles.statTitle}>{stat.title}</div>
                            <div className={styles.statValue} style={{ color: stat.color }}>{stat.value}</div>
                        </div>
                    ))}
                </div>

                <div className={styles.tableContainer}>
                    <div className={styles.tableHeader}>
                        <div className={styles.tableTitle}>All Users</div>
                        <div className={styles.controls}>
                            <div className={styles.searchWrapper}>
                                <Search className={styles.searchIcon} size={18} />
                                <input
                                    type="text"
                                    className={styles.searchInput}
                                    placeholder="Search by name or email"
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                />
                            </div>
                            <button style={{ background: 'transparent', border: 'none', display: 'flex', alignItems: 'center', gap: '4px', cursor: 'pointer' }}>
                                <span>Sort by : <b>Newest</b></span>
                                <ChevronDown size={16} />
                            </button>
                        </div>
                    </div>

                    <div className={styles.gridHeader}>
                        <div>User</div>
                        <div>Email</div>
                        <div>School</div>
                        <div>Role</div>
                        <div>Status</div>
                        <div>Action</div>
                    </div>

                    <div className={styles.tableBody}>
                        {isLoading ? (
                            <div style={{ display: 'flex', justifyContent: 'center', width: '100%', padding: '40px' }}>
                                <RefreshCw className={styles.spin} size={40} color="#004AAD" />
                            </div>
                        ) : error ? (
                            <div style={{ color: '#EF4444', textAlign: 'center', width: '100%', padding: '40px' }}>{error}</div>
                        ) : filteredUsers.length === 0 ? (
                            <div style={{ textAlign: 'center', width: '100%', padding: '40px' }}>No users found</div>
                        ) : (
                            filteredUsers.map((user) => (
                                <div key={user.user_id} className={styles.gridRow}>
                                    <div className={styles.userName}>{user.first_name} {user.last_name}</div>
                                    <div>{user.email}</div>
                                    <div>{user.school_name || 'N/A'}</div>
                                    <div>
                                        <span className={`${styles.roleBadge} ${user.role_display_name === 'TEACHER' ? styles.roleTeacher :
                                            user.role_display_name === 'LEARNER' ? styles.roleStudent : styles.roleAdmin
                                            }`}>
                                            {user.role_display_name}
                                        </span>
                                    </div>
                                    <div className={user.status_code === 'ACTIVE' ? styles.statusActive : styles.statusInactive}>
                                        {user.status_code}
                                    </div>
                                    <div>
                                        <button className={styles.actionButton}>
                                            <Eye size={16} />
                                        </button>
                                    </div>
                                </div>
                            ))
                        )}
                    </div>

                    <div className={styles.tableFooter}>
                        <div className={styles.footerInfo}>
                            Showing {filteredUsers.length} of {filteredUsers.length} users
                        </div>
                        <div className={styles.pagination}>
                            <div className={styles.pageBox}><ChevronLeft size={16} /></div>
                            <div className={`${styles.pageBox} ${styles.pageBoxActive}`}>1</div>
                            <div className={styles.pageBox}>2</div>
                            <div className={styles.pageBox}><ChevronRight size={16} /></div>
                        </div>
                    </div>
                </div>
            </div>
        </MainLayout>
    );
};

export default AdminUsers;
