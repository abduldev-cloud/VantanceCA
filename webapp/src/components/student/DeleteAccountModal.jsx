import React from 'react';
import { AlertCircle, CheckCircle2 } from 'lucide-react';
import styles from '../common/Modal.module.css';

const DeleteAccountModal = ({ isOpen, onClose }) => {
    const [isDeleted, setIsDeleted] = React.useState(false);

    if (!isOpen) return null;

    if (isDeleted) {
        return (
            <div className={styles.overlay} onClick={onClose}>
                <div className={styles.modal} style={{ maxWidth: '400px', textAlign: 'center' }} onClick={e => e.stopPropagation()}>
                    <CheckCircle2 color="#10B981" size={64} style={{ margin: '0 auto 24px auto' }} />
                    <h2 className={styles.title}>Account Deleted</h2>
                    <p className={styles.subtitle}>Your account has been successfully deleted.</p>
                    <div className={styles.actions}>
                        <button className={styles.confirmBtn} onClick={onClose}>
                            Close
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className={styles.overlay} onClick={onClose}>
            <div className={styles.modal} style={{ background: '#F9F9F9', maxWidth: '500px' }} onClick={e => e.stopPropagation()}>
                <h2 className={styles.title} style={{ color: '#1F2040', fontSize: '24px' }}>Delete My Account</h2>
                <p className={styles.subtitle} style={{ color: '#1F2040', fontWeight: '500' }}>
                    Are you sure you want to delete <span style={{ fontWeight: 'bold', color: '#9CA3AF' }}>Arun Kumar</span>?
                </p>

                <div style={{ background: 'white', padding: '16px', margin: '24px 0', borderLeft: '4px solid #FF9933', display: 'flex', gap: '12px' }}>
                    <AlertCircle color="#FF9933" size={24} style={{ flexShrink: 0 }} />
                    <div>
                        <div style={{ color: '#FF9933', fontWeight: 'bold', fontSize: '14px', marginBottom: '8px' }}>Warning</div>
                        <div style={{ color: '#FF9933', fontSize: '13px', lineHeight: '1.4' }}>
                            By deleting this account, you won't be able to access the VantanceCA system.
                        </div>
                    </div>
                </div>

                <div className={styles.actions}>
                    <button className={styles.cancelBtn} onClick={onClose} style={{ background: '#E0E0E0' }}>
                        No, Cancel
                    </button>
                    <button className={styles.confirmBtn} onClick={() => setIsDeleted(true)}>
                        Yes, Delete
                    </button>
                </div>
            </div>
        </div>
    );
};

export default DeleteAccountModal;
