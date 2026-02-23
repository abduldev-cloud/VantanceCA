import React from 'react';
import styles from './Button.module.css';

const Button = ({
    children,
    onClick,
    type = 'button',
    variant = 'primary',
    loading = false,
    disabled = false,
    className = '',
    fullWidth = false
}) => {
    return (
        <button
            type={type}
            onClick={onClick}
            disabled={disabled || loading}
            className={`
        ${styles.button} 
        ${styles[variant]} 
        ${fullWidth ? styles.fullWidth : ''} 
        ${className}
      `}
        >
            {loading ? (
                <div className={styles.spinner}></div>
            ) : (
                children
            )}
        </button>
    );
};

export default Button;
