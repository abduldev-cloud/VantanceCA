import React, { useState, useEffect, useRef } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import {
    Search,
    ChevronDown,
    ChevronLeft,
    ChevronRight,
    Eye,
    X,
    FolderUp,
    RefreshCw,
    ArrowLeft
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import adminService from '../../services/adminService';
import styles from './AdminUsers.module.css';

const AddUserDialog = ({ isOpen, onClose, currentInstituteId, onSuccess }) => {
    const [schools, setSchools] = useState([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState('');

    const [formData, setFormData] = useState({
        first_name: '',
        last_name: '',
        email: '',
        role_id: 'role-004', // default to Learner
        institute_id: currentInstituteId || ''
    });

    useEffect(() => {
        if (isOpen && !currentInstituteId) {
            // Fetch schools for the dropdown
            const fetchSchoolsForDropdown = async () => {
                try {
                    const response = await adminService.getSchools('ACTIVE');
                    if (response.out_status === 'SUCCESS') {
                        setSchools(response.institute_details || []);
                        if (response.institute_details?.length > 0) {
                            setFormData(prev => ({ ...prev, institute_id: response.institute_details[0].institute_id }));
                        }
                    }
                } catch (err) {
                    console.error('Error fetching schools:', err);
                }
            };
            fetchSchoolsForDropdown();
        } else if (isOpen && currentInstituteId) {
            setFormData(prev => ({ ...prev, institute_id: currentInstituteId }));
        }
    }, [isOpen, currentInstituteId]);

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
    };

    const handleSubmit = async () => {
        if (!formData.first_name || !formData.last_name || !formData.email || !formData.institute_id) {
            setError('Please fill in all required fields.');
            return;
        }

        setIsLoading(true);
        setError('');
        try {
            await adminService.addUser(formData);
            onSuccess();
            onClose();
        } catch (err) {
            setError(err.response?.data?.detail || 'Failed to add user.');
        } finally {
            setIsLoading(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className={styles.overlay}>
            <div className={styles.modal} style={{ maxWidth: '450px' }}>
                <button className={styles.btnClose} onClick={onClose}><X size={20} /></button>
                <div className={styles.modalHeader}>
                    <h2 className={styles.modalTitle}>Add User</h2>
                    <p className={styles.modalSubtitle}>Create a new student or faculty member.</p>
                </div>
                <div className={styles.form}>
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
                        <div className={styles.field}>
                            <label>First Name</label>
                            <input type="text" name="first_name" className={styles.input} onChange={handleInputChange} />
                        </div>
                        <div className={styles.field}>
                            <label>Last Name</label>
                            <input type="text" name="last_name" className={styles.input} onChange={handleInputChange} />
                        </div>
                    </div>

                    <div className={styles.field}>
                        <label>Email Address</label>
                        <input type="email" name="email" className={styles.input} placeholder="user@school.edu" onChange={handleInputChange} />
                    </div>

                    <div className={styles.field}>
                        <label>Role</label>
                        <select name="role_id" className={styles.select} value={formData.role_id} onChange={handleInputChange}>
                            <option value="role-004">Student (Learner)</option>
                            <option value="role-003">Faculty (Teacher)</option>
                            <option value="role-002">School Admin</option>
                        </select>
                    </div>

                    {!currentInstituteId && (
                        <div className={styles.field}>
                            <label>Assign to School</label>
                            <select name="institute_id" className={styles.select} value={formData.institute_id} onChange={handleInputChange}>
                                {schools.map(school => (
                                    <option key={school.institute_id} value={school.institute_id}>
                                        {school.institute_name}
                                    </option>
                                ))}
                            </select>
                        </div>
                    )}

                    {error && <div style={{ color: '#EF4444', fontSize: '13px', marginTop: '5px' }}>{error}</div>}

                    <div className={styles.row} style={{ marginTop: '20px', justifyContent: 'flex-end', gap: '10px' }}>
                        <button className={styles.actionButton} style={{ padding: '8px 20px', border: '1px solid #ddd' }} onClick={onClose} disabled={isLoading}>Cancel</button>
                        <button className={styles.btnAdd} onClick={handleSubmit} disabled={isLoading}>
                            {isLoading ? 'Saving...' : 'Add User'}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

const BulkImportUsersDialog = ({ isOpen, onClose, currentInstituteId, onSuccess }) => {
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
            const response = await adminService.bulkImportUsers(file, currentInstituteId);
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
                    <h2 className={styles.modalTitle}>Bulk Import Users</h2>
                    <p className={styles.modalSubtitle}>Upload a CSV file to create multiple students or faculty at once.</p>
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
                        Expected CSV columns: <b>first_name, last_name, email, role_id</b>
                        <br /><br />
                        For <b>role_id</b>, use: <br />
                        <b>role-004</b> (Student) <br />
                        <b>role-003</b> (Faculty) <br />
                        <br />
                        <i>Note: If assigning globally, add <br /><b>institute_id</b> to your CSV.</i>
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

const AdminUsers = () => {
    const [searchParams] = useSearchParams();
    const navigate = useNavigate();
    const instituteId = searchParams.get('institute_id');
    const schoolName = searchParams.get('school_name');

    const [selectedTab, setSelectedTab] = useState(0); // 0: Active, 1: Inactive, 2: Total
    const [searchQuery, setSearchQuery] = useState('');
    const [isLoading, setIsLoading] = useState(true);
    const [users, setUsers] = useState([]);
    const [isAddUserOpen, setIsAddUserOpen] = useState(false);
    const [isBulkImportOpen, setIsBulkImportOpen] = useState(false);
    const [toastMessage, setToastMessage] = useState('');

    const [counts, setCounts] = useState({
        active: 0,
        inactive: 0,
        total: 0
    });
    const [error, setError] = useState('');

    const fetchUsers = async () => {
        setIsLoading(true);
        try {
            const status = selectedTab === 0 ? 'ACTIVE' : selectedTab === 1 ? 'INACTIVE' : null;
            const response = await adminService.getUsers(status, 1, 50, instituteId);
            if (response.out_status === 'SUCCESS') {
                setUsers(response.user_list || []);
                if (response.user_counts && response.user_counts.length > 0) {
                    setCounts({
                        active: response.user_counts[0].active_users || 0,
                        inactive: response.user_counts[0].archived_users || 0,
                        total: response.user_counts[0].total_users || 0
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

    useEffect(() => {
        fetchUsers();
    }, [selectedTab, instituteId]);

    const stats = [
        { title: 'Active Users', value: (counts.active || 0).toLocaleString(), color: '#0A8041' },
        { title: 'Inactive Users', value: (counts.inactive || 0).toLocaleString(), color: '#FF9933' },
        { title: 'Total Users', value: (counts.total || 0).toLocaleString(), color: '#CB6CE6' }
    ];

    const filteredUsers = users.filter(user => {
        const fullName = (user.first_name || '') + ' ' + (user.last_name || '');
        const matchesSearch = fullName.toLowerCase().includes(searchQuery.toLowerCase()) ||
            (user.email || '').toLowerCase().includes(searchQuery.toLowerCase());
        return matchesSearch;
    });

    const pageTitle = schoolName
        ? `Users — ${decodeURIComponent(schoolName)}`
        : 'Users';
    const pageSubtitle = schoolName
        ? `Showing users from ${decodeURIComponent(schoolName)}`
        : 'View and manage all users across schools';

    return (
        <MainLayout>
            <TitleBar
                title={pageTitle}
                subTitle={pageSubtitle}
                buttonTitle="Add User"
                onTap={() => setIsAddUserOpen(true)}
            />

            {instituteId && (
                <button
                    onClick={() => navigate('/admin/school')}
                    className={styles.backButton}
                >
                    <ArrowLeft size={18} />
                    <span>Back to Schools</span>
                </button>
            )}

            {toastMessage && (
                <div style={{ background: '#E6F4EA', color: '#1E7E34', padding: '16px', borderRadius: '12px', marginTop: '16px', border: '1px solid #1E7E34' }}>
                    {toastMessage}
                </div>
            )}

            <div className={styles.container}>
                <div className={styles.headerRow}>
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
                    <button className={styles.bulkImportButton} onClick={() => setIsBulkImportOpen(true)}>
                        <FolderUp size={18} />
                        <span>Bulk Import Users</span>
                    </button>
                </div>

                <div className={styles.tableContainer}>
                    <div className={styles.tableHeader}>
                        <div className={styles.tableTitle}>
                            {instituteId ? `${decodeURIComponent(schoolName || 'School')} Users` : 'All Users'}
                        </div>
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
                                            user.role_display_name === 'LEARNER' ? styles.roleStudent :
                                                user.role_display_name === 'INSTITUTE_ADMIN' ? styles.roleAdmin :
                                                    styles.roleAdmin
                                            }`}>
                                            {user.role_display_name === 'PLATFORM_ADMIN' ? 'Platform Admin' :
                                                user.role_display_name === 'INSTITUTE_ADMIN' ? 'School Admin' :
                                                    user.role_display_name === 'TEACHER' ? 'Faculty' : 'Student'}
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

            <AddUserDialog
                isOpen={isAddUserOpen}
                onClose={() => setIsAddUserOpen(false)}
                currentInstituteId={instituteId}
                onSuccess={() => {
                    setToastMessage('User added successfully!');
                    setTimeout(() => setToastMessage(''), 3000);
                    fetchUsers();
                }}
            />
            <BulkImportUsersDialog
                isOpen={isBulkImportOpen}
                onClose={() => setIsBulkImportOpen(false)}
                currentInstituteId={instituteId}
                onSuccess={(msg) => {
                    setToastMessage(msg || 'Users imported successfully!');
                    setTimeout(() => setToastMessage(''), 5000);
                    fetchUsers();
                }}
            />
        </MainLayout>
    );
};

export default AdminUsers;
