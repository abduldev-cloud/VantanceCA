import React from 'react';
import styles from './AuthLayout.module.css';

const AuthLayout = ({ children, image }) => {
    return (
        <div className={styles.container}>
            <div className={styles.card}>
                <div className={styles.imageSection}>
                    <img src={image} alt="Auth Illustration" className={styles.image} />
                </div>
                <div className={styles.formSection}>
                    <div className={styles.formContent}>
                        {children}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default AuthLayout;
