import React, { useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';
import styles from '../common/Modal.module.css';

const ChangePasswordModal = ({ isOpen, onClose }) => {
    const [showNew, setShowNew] = useState(false);
    const [showConfirm, setShowConfirm] = useState(false);
    const [error, setError] = useState('');

    if (!isOpen) return null;

    const handleSubmit = (e) => {
        e.preventDefault();
        // Logic for submission
        setError('Password must use Caps, Small, Number & Symbols (_@$)');
    };

    return (
        <div className={styles.overlay} onClick={onClose}>
            <div className={styles.modal} onClick={e => e.stopPropagation()}>
                <h2 className={styles.title}>Change Your Password</h2>
                <p className={styles.subtitle}>Are you sure you want to change?</p>

                <form onSubmit={handleSubmit}>
                    <div className={styles.formGroup}>
                        <label className={styles.label}>
                            New Password <span className={styles.required}>*</span>
                        </label>
                        <div className={styles.inputWrapper}>
                            <input
                                type={showNew ? "text" : "password"}
                                className={styles.input}
                                placeholder="**********"
                            />
                            <button
                                type="button"
                                className={styles.toggle}
                                onClick={() => setShowNew(!showNew)}
                            >
                                {showNew ? <EyeOff size={20} /> : <Eye size={20} />}
                            </button>
                        </div>
                    </div>

                    <div className={styles.formGroup}>
                        <label className={styles.label}>
                            Confirm Password <span className={styles.required}>*</span>
                        </label>
                        <div className={styles.inputWrapper}>
                            <input
                                type={showConfirm ? "text" : "password"}
                                className={styles.input}
                                placeholder="**********"
                            />
                            <button
                                type="button"
                                className={styles.toggle}
                                onClick={() => setShowConfirm(!showConfirm)}
                            >
                                {showConfirm ? <EyeOff size={20} /> : <Eye size={20} />}
                            </button>
                        </div>
                    </div>

                    {error && <div className={styles.errorText}>{error}</div>}

                    <div className={styles.actions}>
                        <button type="button" className={styles.cancelBtn} onClick={onClose}>
                            Cancel
                        </button>
                        <button type="submit" className={styles.confirmBtn}>
                            Confirm
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default ChangePasswordModal;
