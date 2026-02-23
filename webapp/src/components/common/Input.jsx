import React, { useState } from 'react';
import styles from './Input.module.css';

const Input = ({
    label,
    type = 'text',
    placeholder,
    value,
    onChange,
    error,
    name,
    required = false
}) => {
    const [showPassword, setShowPassword] = useState(false);
    const isPassword = type === 'password';
    const inputType = isPassword ? (showPassword ? 'text' : 'password') : type;

    return (
        <div className={styles.inputContainer}>
            {label && <label className={styles.label}>{label}</label>}
            <div className={styles.fieldWrapper}>
                <input
                    name={name}
                    type={inputType}
                    placeholder={placeholder}
                    value={value}
                    onChange={onChange}
                    required={required}
                    className={`${styles.input} ${error ? styles.inputError : ''}`}
                />
                {isPassword && (
                    <button
                        type="button"
                        className={styles.toggleBtn}
                        onClick={() => setShowPassword(!showPassword)}
                    >
                        {showPassword ? 'Hide' : 'Show'}
                    </button>
                )}
            </div>
            {error && <span className={styles.errorText}>{error}</span>}
        </div>
    );
};

export default Input;
