import React from 'react';
import Typography from '../common/Typography';
import Button from '../common/Button';
import styles from './TitleBar.module.css';

const TitleBar = ({ title, subTitle, buttonTitle, onTap }) => {
    return (
        <div className={styles.container}>
            <div className={styles.textSection}>
                <Typography variant="headlineSmall" weight="600">{title}</Typography>
                <Typography variant="bodyMedium" color="#667085">{subTitle}</Typography>
            </div>
            {buttonTitle && (
                <Button onClick={onTap}>
                    {buttonTitle}
                </Button>
            )}
        </div>
    );
};

export default TitleBar;
