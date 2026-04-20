import React from 'react';
import { AlertCircle, CheckCircle2 } from 'lucide-react';
import styles from './DeleteAccountModal.module.css';

const DeleteAccountModal = ({ isOpen, onClose }) => {
    const [isDeleted, setIsDeleted] = React.useState(false);

    if (!isOpen) return null;

    if (isDeleted) {
        return (
            <div className={styles.overlay} onClick={onClose}>
                <div className={styles.modal} onClick={e => e.stopPropagation()}>
                    <CheckCircle2 size={64} className={styles.successIcon} />
                    <h2 className={styles.title}>Account Deleted</h2>
                    <p className={styles.subtitle}>Your account has been successfully deleted.</p>
                    <div className={styles.actions}>
                        <button className={styles.successBtn} onClick={onClose}>
                            Close
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className={styles.overlay} onClick={onClose}>
            <div className={styles.modal} onClick={e => e.stopPropagation()}>
                <h2 className={styles.title}>Delete My Account</h2>
                <p className={styles.subtitle}>
                    Are you sure you want to delete <span className={styles.userName}>Arun Kumar</span>?
                </p>

                <div className={styles.warningBox}>
                    <AlertCircle size={24} className={styles.warningIcon} />
                    <div>
                        <div className={styles.warningTitle}>Warning</div>
                        <div className={styles.warningText}>
                            By deleting this account, you won't be able to access the VantanceCA system.
                        </div>
                    </div>
                </div>

                <div className={styles.actions}>
                    <button className={styles.cancelBtn} onClick={onClose}>
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
