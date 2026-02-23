import React, { useState, useEffect } from 'react';
import {
    Users,
    MapPin,
    Globe,
    Mail,
    Eye,
    X,
    Plus,
    RefreshCw
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import adminService from '../../services/adminService';
import styles from './AdminSchools.module.css';

const AddSchoolDialog = ({ isOpen, onClose }) => {
    if (!isOpen) return null;

    return (
        <div className={styles.overlay}>
            <div className={styles.modal}>
                <button className={styles.btnClose} onClick={onClose}><X size={20} /></button>
                <div className={styles.modalHeader}>
                    <h2 className={styles.modalTitle}>Add School</h2>
                    <p className={styles.modalSubtitle}>Please fill out this form to add school.</p>
                </div>
                <div className={styles.form}>
                    <div className={styles.field}>
                        <label>School Name</label>
                        <input type="text" className={styles.input} placeholder="Enter school name" />
                    </div>
                    <div className={styles.field}>
                        <label>Institute Type</label>
                        <select className={styles.select}>
                            <option>Public</option>
                            <option>Private</option>
                            <option>Chartered</option>
                        </select>
                    </div>
                    <div className={styles.field}>
                        <label>School State</label>
                        <select className={styles.select}>
                            <option>California</option>
                            <option>Texas</option>
                            <option>New York</option>
                        </select>
                    </div>
                    <div className={styles.field}>
                        <label>School District</label>
                        <select className={styles.select}>
                            <option>District 1</option>
                            <option>District 2</option>
                        </select>
                    </div>
                    <div className={styles.field}>
                        <label>School Admin Email</label>
                        <input type="email" className={styles.input} placeholder="admin@school.com" />
                    </div>
                    <div className={styles.field}>
                        <label>School Domain</label>
                        <input type="text" className={styles.input} placeholder="school.edu" />
                    </div>

                    <div className={styles.row}>
                        <div className={styles.toggleRow}>
                            <input type="checkbox" id="demo" />
                            <label htmlFor="demo" className={styles.toggleLabel}>Demo School</label>
                        </div>
                        <button className={styles.btnAdd} onClick={onClose}>Add</button>
                    </div>
                </div>
            </div>
        </div>
    );
};

const AdminSchools = () => {
    const [selectedTab, setSelectedTab] = useState(0); // 0: Active, 1: Archived, 2: Total
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isLoading, setIsLoading] = useState(true);
    const [schools, setSchools] = useState([]);
    const [summary, setSummary] = useState({
        active: 0,
        archived: 0,
        totalUsers: 0
    });
    const [error, setError] = useState('');

    useEffect(() => {
        const fetchSchools = async () => {
            setIsLoading(true);
            try {
                const status = selectedTab === 0 ? 'ACTIVE' : selectedTab === 1 ? 'ARCHIVED' : null;
                const response = await adminService.getSchools(status);
                if (response.out_status === 'SUCCESS') {
                    setSchools(response.institute_details);
                    if (response.summary_counts && response.summary_counts.length > 0) {
                        setSummary({
                            active: response.summary_counts[0].active_institutes,
                            archived: response.summary_counts[0].archived_institutes,
                            totalUsers: response.summary_counts[0].total_users
                        });
                    }
                }
            } catch (err) {
                console.error('Error fetching schools:', err);
                setError('Failed to load schools.');
            } finally {
                setIsLoading(false);
            }
        };
        fetchSchools();
    }, [selectedTab]);

    const stats = [
        { title: 'Active Schools', value: summary.active.toString(), color: '#0A8041' },
        { title: 'Archived Schools', value: summary.archived.toString(), color: '#FF9933' },
        { title: 'Total Current Users', value: summary.totalUsers.toLocaleString(), color: '#CB6CE6' }
    ];

    return (
        <MainLayout>
            <TitleBar
                title="Schools"
                subTitle="View and manage all schools"
                buttonTitle="Add School"
                onTap={() => setIsModalOpen(true)}
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

                <div className={styles.schoolList}>
                    {isLoading ? (
                        <div style={{ display: 'flex', justifyContent: 'center', width: '100%', padding: '40px' }}>
                            <RefreshCw className={styles.spin} size={40} color="#004AAD" />
                        </div>
                    ) : error ? (
                        <div style={{ color: '#EF4444', textAlign: 'center', width: '100%', padding: '40px' }}>{error}</div>
                    ) : schools.length === 0 ? (
                        <div style={{ textAlign: 'center', width: '100%', padding: '40px' }}>No schools found</div>
                    ) : (
                        schools.map((school) => (
                            <div key={school.institute_id} className={styles.schoolCard}>
                                <div className={styles.schoolMain}>
                                    <div className={styles.schoolNameRow}>
                                        <div className={styles.schoolName}>{school.institute_name}</div>
                                        <div
                                            className={styles.statusBadge}
                                            style={{ color: school.status_code === 'ACTIVE' ? '#0A8041' : '#FF9933' }}
                                        >
                                            {school.status_code}
                                        </div>
                                    </div>
                                    <div className={styles.schoolDescription}>Institute Code: {school.institute_code}</div>
                                    <div className={styles.schoolMeta}>
                                        <div className={styles.metaItem}>
                                            <Users className={styles.metaIcon} size={16} />
                                            <span>{school.total_users} Users ({school.total_teachers}T / {school.total_students}S)</span>
                                        </div>
                                        <div className={styles.metaItem}>
                                            <MapPin className={styles.metaIcon} size={16} />
                                            <span>{school.total_classes} Classes</span>
                                        </div>
                                        <div className={styles.metaItem}>
                                            <Globe className={styles.metaIcon} size={16} />
                                            <span>{school.is_demo ? 'Demo School' : 'Production'}</span>
                                        </div>
                                        <div className={styles.metaItem}>
                                            <Mail className={styles.metaIcon} size={16} />
                                            <span>Created: {new Date(school.created_at).toLocaleDateString()}</span>
                                        </div>
                                    </div>
                                </div>

                                <button className={styles.viewDetailsButton}>
                                    <Eye size={20} />
                                    <span>View Details</span>
                                </button>
                            </div>
                        ))
                    )}
                </div>
            </div>

            <AddSchoolDialog isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
        </MainLayout>
    );
};

export default AdminSchools;
