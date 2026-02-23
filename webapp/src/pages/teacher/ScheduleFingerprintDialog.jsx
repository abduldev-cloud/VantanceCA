import React, { useState } from 'react';
import { X } from 'lucide-react';
import styles from './CreateAssignmentDialog.module.css'; // Reusing styles

const ScheduleFingerprintDialog = ({ isOpen, onClose }) => {
    if (!isOpen) return null;

    return (
        <div className={styles.overlay}>
            <div className={styles.modal} style={{ maxWidth: '450px' }}>
                <button className={styles.btnClose} onClick={onClose}><X size={24} /></button>

                <div className={styles.header}>
                    <h2>Schedule Writing Fingerprint</h2>
                    <p>Assign as early in the school year as possible</p>
                </div>

                <div className={styles.form}>
                    <div className={styles.field}>
                        <label>Class</label>
                        <select className={styles.select}>
                            <option>Select Class</option>
                            <option>Modern English Literature</option>
                        </select>
                    </div>
                    <div className={styles.field}>
                        <label>Grade</label>
                        <select className={styles.select}>
                            <option>Select Grade</option>
                            <option>Grade 11</option>
                        </select>
                    </div>
                    <div className={styles.field}>
                        <label>Date</label>
                        <input type="date" className={styles.input} />
                    </div>
                    <div className={styles.field}>
                        <label>Due by</label>
                        <input type="time" className={styles.input} />
                    </div>
                </div>

                <div className={styles.footer}>
                    <button className={styles.btnNext} onClick={onClose}>
                        Next
                    </button>
                </div>
            </div>
        </div>
    );
};

export default ScheduleFingerprintDialog;
