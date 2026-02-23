import React from 'react';
import { CheckCircle2 } from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import Typography from '../../components/common/Typography';
import styles from './SubscriptionPage.module.css';

const SubscriptionPage = () => {
    const plans = [
        {
            id: 1,
            title: 'Basic',
            description: 'Essential features for individual learners starting their journey.',
            price: '$0',
            isActive: true,
            features: ['Up to 2 papers', 'Basic AI assistance', 'Manual grading', 'Community support']
        },
        {
            id: 2,
            title: 'Standard',
            description: 'Perfect for dedicated students who need more comprehensive tools.',
            price: '$19',
            isActive: false,
            features: ['Up to 10 papers', 'Advanced AI helper', 'Auto-grading', 'Direct educator feedback']
        },
        {
            id: 3,
            title: 'Premium',
            description: 'The ultimate toolkit for high-achieving students and researchers.',
            price: '$49',
            isActive: false,
            features: ['Unlimited papers', 'Priority Sage AI access', 'Full analytics report', '24/7 dedicated support']
        }
    ];

    return (
        <MainLayout>
            <div className={styles.container}>
                <div className={styles.header}>
                    <Typography variant="displaySmall" weight="700">Billing & Plans</Typography>
                    <Typography variant="bodyMedium" color="#666">
                        Manage your subscription and billing preferences.
                    </Typography>
                </div>

                <div className={styles.plansGrid}>
                    {plans.map((plan) => (
                        <div key={plan.id} className={`${styles.planCard} ${plan.isActive ? styles.activeCard : ''}`}>
                            {plan.isActive && <div className={styles.badge}>Current Plan</div>}
                            <div className={styles.planName}>{plan.title}</div>
                            <p className={styles.planDesc}>{plan.description}</p>

                            <div className={styles.price}>
                                {plan.price}<span className={styles.period}> / month</span>
                            </div>

                            <div className={styles.features}>
                                {plan.features.map((feature, index) => (
                                    <div key={index} className={styles.featureItem}>
                                        <CheckCircle2 size={18} className={styles.checkIcon} />
                                        <span>{feature}</span>
                                    </div>
                                ))}
                            </div>

                            <button
                                className={`${styles.actionBtn} ${plan.isActive ? styles.activeBtn : styles.upgradeBtn}`}
                                disabled={plan.isActive}
                            >
                                {plan.isActive ? 'Active' : 'Upgrade'}
                            </button>
                        </div>
                    ))}
                </div>
            </div>
        </MainLayout>
    );
};

export default SubscriptionPage;
