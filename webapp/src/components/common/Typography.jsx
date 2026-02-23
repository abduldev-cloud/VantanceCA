import React from 'react';
import styles from './Typography.module.css';

const Typography = ({
    children,
    variant = 'bodyMedium',
    color,
    weight,
    align,
    className = '',
    style = {}
}) => {
    const Tag = variant.startsWith('h') ? variant : 'p';

    const combinedStyle = {
        color: color,
        fontWeight: weight,
        textAlign: align,
        ...style
    };

    return (
        <Tag
            className={`${styles[variant]} ${className}`}
            style={combinedStyle}
        >
            {children}
        </Tag>
    );
};

export default Typography;
