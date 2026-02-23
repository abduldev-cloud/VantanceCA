import React, { useState } from 'react';
import MainLayout from '../../components/layout/MainLayout';
import Typography from '../../components/common/Typography';
import DeleteAccountModal from '../../components/student/DeleteAccountModal';
import styles from './SecurityPrivacyPage.module.css';

const SecurityPrivacyPage = () => {
    const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
    const content = {
        title: "Data Security and Privacy Commitment",
        description: "At VantanceCA, we prioritize the protection of your educational data and personal information through rigorous security standards and transparent privacy practices.",
        body: `
      1. Information We Collect
      We collect information necessary to provide our educational services, including your name, email address, academic performance data, and interations with our AI helper.

      2. How We Use Your Data
      Your data is used to personalize your learning experience, provide real-time feedback on assignments, and improve our educational algorithms. We do not sell your personal information to third parties.

      3. Data Security Measures
      We employ industry-standard encryption for data at rest and in transit. Our servers are hosted in secure environments with restricted access and continuous monitoring.

      4. AI Interaction Privacy
      Conversations with Sage AI are stored securely to help you track your progress. These interactions are used for model improvement in an anonymized format only.

      5. Your Rights
      You have the right to access, correct, or delete your personal data at any time. You can export your performance records through the Settings menu.

      6. Changes to This Policy
      We may update this policy periodically. We will notify you of any significant changes via the email address associated with your account.
    `
    };

    return (
        <MainLayout>
            <div className={styles.container}>
                <div className={styles.header}>
                    <Typography variant="displaySmall" weight="700">Settings</Typography>
                </div>

                <div className={styles.infoBox}>
                    <span className={styles.infoTitle}>{content.title}</span>
                    <p className={styles.infoDesc}>{content.description}</p>
                </div>

                <div className={styles.contentArea}>
                    {content.body.split('\n').map((line, i) => (
                        <p key={i}>{line}</p>
                    ))}
                </div>

                <div className={styles.footer}>
                    <button
                        className={styles.deleteBtn}
                        onClick={() => setIsDeleteModalOpen(true)}
                    >
                        Delete My Account
                    </button>
                    <button className={styles.closeBtn}>Accept and Close</button>
                </div>
            </div>

            <DeleteAccountModal
                isOpen={isDeleteModalOpen}
                onClose={() => setIsDeleteModalOpen(false)}
            />
        </MainLayout>
    );
};

export default SecurityPrivacyPage;
