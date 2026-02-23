import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import MainLayout from '../../components/layout/MainLayout';
import Typography from '../../components/common/Typography';
import ChangePasswordModal from '../../components/student/ChangePasswordModal';
import styles from './SettingsPage.module.css';

const SettingsPage = () => {
    const navigate = useNavigate();
    const [isPasswordModalOpen, setIsPasswordModalOpen] = useState(false);
    const userProfile = {
        name: "John Doe",
        email: "john.doe@example.com"
    };

    return (
        <MainLayout>
            <div className={styles.container}>
                <Typography variant="displaySmall" weight="700">Settings</Typography>

                <div className={styles.section}>
                    <div className={styles.sectionHeader}>Your Profile</div>

                    <div className={styles.infoRow}>
                        <span className={styles.infoLabel}>Name</span>
                        <span className={styles.infoValue}>{userProfile.name}</span>
                    </div>

                    <div className={styles.infoRow}>
                        <span className={styles.infoLabel}>Email</span>
                        <span className={styles.infoValue}>{userProfile.email}</span>
                    </div>

                    <div className={styles.actionRow}>
                        <div className={styles.actionLeft}>
                            <span className={styles.infoLabel}>Password</span>
                        </div>
                        <button
                            className={styles.actionBtn}
                            onClick={() => setIsPasswordModalOpen(true)}
                        >
                            Change
                        </button>
                    </div>

                    <div className={styles.actionRow}>
                        <div className={styles.actionLeft}>
                            <span className={styles.infoLabel}>Plan & Subscription</span>
                            <p className={styles.actionDesc}>Manage your subscription plans and billing details.</p>
                        </div>
                        <button
                            className={styles.actionBtn}
                            onClick={() => navigate('/student/subscription')}
                        >
                            View
                        </button>
                    </div>

                    <div className={styles.actionRow}>
                        <div className={styles.actionLeft}>
                            <span className={styles.infoLabel}>Security & Privacy</span>
                            <p className={styles.actionDesc}>Control your data privacy and security settings.</p>
                        </div>
                        <button
                            className={styles.actionBtn}
                            onClick={() => navigate('/student/security')}
                        >
                            View
                        </button>
                    </div>

                    <button className={styles.logoutHeader}>Logout</button>
                </div>
            </div>

            <ChangePasswordModal
                isOpen={isPasswordModalOpen}
                onClose={() => setIsPasswordModalOpen(false)}
            />
        </MainLayout>
    );
};

export default SettingsPage;
