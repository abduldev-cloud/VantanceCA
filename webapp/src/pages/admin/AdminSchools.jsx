import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    Users,
    MapPin,
    Globe,
    Mail,
    Eye,
    X,
    FolderUp,
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

const BulkImportSchoolsDialog = ({ isOpen, onClose, onSuccess }) => {
    const [file, setFile] = useState(null);
    const [isUploading, setIsUploading] = useState(false);
    const [error, setError] = useState('');
    const fileInputRef = useRef(null);

    if (!isOpen) return null;

    const handleFileChange = (e) => {
        if (e.target.files && e.target.files[0]) {
            setFile(e.target.files[0]);
            setError('');
        }
    };

    const handleUpload = async () => {
        if (!file) {
            setError('Please select a CSV file first.');
            return;
        }

        setIsUploading(true);
        setError('');
        try {
            const response = await adminService.bulkImportSchools(file);
            onSuccess(response.message);
            onClose();
        } catch (err) {
            setError(err.response?.data?.detail || 'Failed to upload file.');
        } finally {
            setIsUploading(false);
        }
    };

    return (
        <div className={styles.overlay}>
            <div className={styles.modal}>
                <button className={styles.btnClose} onClick={onClose}><X size={20} /></button>
                <div className={styles.modalHeader}>
                    <h2 className={styles.modalTitle}>Bulk Import Schools</h2>
                    <p className={styles.modalSubtitle}>Upload a CSV file to create multiple schools & institute admins at once.</p>
                </div>

                <div className={styles.form}>
                    <div className={styles.uploadArea} onClick={() => fileInputRef.current?.click()}>
                        <FolderUp size={30} color="#667085" />
                        <span className={styles.uploadText}>{file ? file.name : "Click to select a .csv file"}</span>
                        <input
                            type="file"
                            accept=".csv"
                            ref={fileInputRef}
                            style={{ display: 'none' }}
                            onChange={handleFileChange}
                        />
                    </div>

                    <div className={styles.uploadHelpText}>
                        Expected CSV columns: <b>institute_name, institute_code, admin_email, admin_first_name, admin_last_name, city, state, is_demo</b>
                    </div>

                    {error && <div className={styles.errorMessage}>{error}</div>}

                    <div className={styles.modalFooter} style={{ marginTop: '20px' }}>
                        <button className={styles.btnSecondary} onClick={onClose} disabled={isUploading}>Cancel</button>
                        <button className={styles.btnPrimary} onClick={handleUpload} disabled={isUploading || !file}>
                            {isUploading ? 'Importing...' : 'Start Import'}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

const AdminSchools = () => {
    const navigate = useNavigate();
    const [selectedTab, setSelectedTab] = useState(0); // 0: Active, 1: Archived
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isBulkImportOpen, setIsBulkImportOpen] = useState(false);
    const [isLoading, setIsLoading] = useState(true);
    const [schools, setSchools] = useState([]);
    const [toastMessage, setToastMessage] = useState('');
    const [summary, setSummary] = useState({
        active: 0,
        archived: 0,
        totalUsers: 0
    });
    const [error, setError] = useState('');

    const fetchSchools = async () => {
        setIsLoading(true);
        try {
            const status = selectedTab === 0 ? 'ACTIVE' : 'ARCHIVED';
            const response = await adminService.getSchools(status);
            if (response.out_status === 'SUCCESS') {
                setSchools(response.institute_details || []);
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

    useEffect(() => {
        fetchSchools();
    }, [selectedTab]);

    const handleTabClick = (index) => {
        if (index === 2) {
            navigate('/admin/user');
        } else {
            setSelectedTab(index);
        }
    };

    const handleViewDetails = (school) => {
        navigate(`/admin/user?institute_id=${school.institute_id}&school_name=${encodeURIComponent(school.institute_name)}`);
    };

    const handleBulkImportSuccess = (message) => {
        setToastMessage(message);
        setTimeout(() => setToastMessage(''), 5000);
        fetchSchools(); // Refresh the list
    };

    const stats = [
        { title: 'Active Schools', value: summary.active.toString(), color: '#0A8041' },
        { title: 'Archived Schools', value: summary.archived.toString(), color: '#FF9933' },
        { title: 'Total Current Users', value: (summary.totalUsers || 0).toLocaleString(), color: '#CB6CE6' }
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
                <div className={styles.headerRow}>
                    <div className={styles.statsGrid}>
                        {stats.map((stat, index) => (
                            <div
                                key={index}
                                className={`${styles.statCard} ${selectedTab === index ? styles.statCardActive : ''}`}
                                onClick={() => handleTabClick(index)}
                            >
                                <div className={styles.statTitle}>{stat.title}</div>
                                <div className={styles.statValue} style={{ color: stat.color }}>{stat.value}</div>
                            </div>
                        ))}
                    </div>
                    <button className={styles.bulkImportButton} onClick={() => setIsBulkImportOpen(true)}>
                        <FolderUp size={18} />
                        <span>Bulk Import Schools</span>
                    </button>
                </div>

                {toastMessage && (
                    <div className={styles.toastSuccess}>
                        {toastMessage}
                    </div>
                )}

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

                                <button
                                    className={styles.viewDetailsButton}
                                    onClick={() => handleViewDetails(school)}
                                >
                                    <Eye size={20} />
                                    <span>View Users</span>
                                </button>
                            </div>
                        ))
                    )}
                </div>
            </div>

            <AddSchoolDialog isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
            <BulkImportSchoolsDialog
                isOpen={isBulkImportOpen}
                onClose={() => setIsBulkImportOpen(false)}
                onSuccess={handleBulkImportSuccess}
            />
        </MainLayout>
    );
};

export default AdminSchools;
