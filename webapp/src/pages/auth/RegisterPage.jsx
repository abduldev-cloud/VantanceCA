import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import AuthLayout from '../../components/layout/AuthLayout';
import Typography from '../../components/common/Typography';
import Input from '../../components/common/Input';
import Button from '../../components/common/Button';
import authService from '../../services/authService';
import LoginLogo from '../../assets/images/logo/login_logo.jpg';
import styles from './Login.module.css';

const RegisterPage = () => {
    const [formData, setFormData] = useState({
        username: '',
        email: '',
        password: '',
        first_name: '',
        last_name: '',
        phone_number: '',
        role: 'LEARNER'
    });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');
    const navigate = useNavigate();

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        setSuccess('');

        try {
            await authService.register(formData);
            setSuccess('Registration successful! You can now log in.');
            setTimeout(() => {
                navigate('/auth/login');
            }, 2000);
        } catch (err) {
            setError(err.response?.data?.detail || 'Registration failed. Please try again.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    return (
        <AuthLayout image={LoginLogo}>
            <div className={styles.header}>
                <Typography variant="displaySmall" weight="600" align="center">
                    CREATE AN ACCOUNT
                </Typography>
                <Typography variant="bodyMedium" color="#667085" align="center" className={styles.subtitle}>
                    Please enter your details to register.
                </Typography>
                {error && <div className={styles.error}>{error}</div>}
                {success && <div style={{ color: 'var(--success)', textAlign: 'center', marginTop: '16px', fontSize: '14px', fontWeight: '600', padding: '10px', background: 'rgba(var(--success-rgb), 0.1)', borderRadius: 'var(--radius-sm)', border: '1px solid rgba(var(--success-rgb), 0.2)' }}>{success}</div>}
            </div>

            <form onSubmit={handleSubmit} className={styles.form}>
                <div style={{ display: 'flex', gap: '16px' }}>
                    <Input
                        label="First Name"
                        name="first_name"
                        placeholder="John"
                        value={formData.first_name}
                        onChange={handleChange}
                        required
                        style={{ flex: 1 }}
                    />
                    <Input
                        label="Last Name"
                        name="last_name"
                        placeholder="Doe"
                        value={formData.last_name}
                        onChange={handleChange}
                        required
                        style={{ flex: 1 }}
                    />
                </div>

                <Input
                    label="Username"
                    name="username"
                    placeholder="johndoe123"
                    value={formData.username}
                    onChange={handleChange}
                    required
                />

                <Input
                    label="Email"
                    name="email"
                    type="email"
                    placeholder="john@example.com"
                    value={formData.email}
                    onChange={handleChange}
                    required
                />

                <Input
                    label="Phone Number"
                    name="phone_number"
                    placeholder="+1234567890"
                    value={formData.phone_number}
                    onChange={handleChange}
                    required
                />

                <Input
                    label="Password"
                    name="password"
                    type="password"
                    placeholder="**********"
                    value={formData.password}
                    onChange={handleChange}
                    required
                />

                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '8px' }}>
                    <label style={{ fontSize: '14px', fontWeight: '500', color: 'var(--text-primary)' }}>Role</label>
                    <select
                        name="role"
                        value={formData.role}
                        onChange={handleChange}
                        style={{
                            padding: '12px 16px',
                            border: '1.5px solid var(--border-color)',
                            borderRadius: 'var(--radius-md)',
                            fontSize: '14px',
                            outline: 'none',
                            background: 'var(--surface-color)',
                            color: 'var(--text-primary)'
                        }}
                    >
                        <option value="LEARNER">Learner</option>
                        <option value="TEACHER">Teacher</option>
                    </select>
                </div>

                <Button type="submit" fullWidth loading={loading}>
                    Register
                </Button>

                <div className={styles.footerLinks} style={{ marginTop: '16px', paddingTop: '16px' }}>
                    <Typography variant="bodySmall" color="#667085" align="center">
                        Already have an account? <Link to="/auth/login" className={styles.boldLink}>Sign in</Link>
                    </Typography>
                </div>
            </form>
        </AuthLayout>
    );
};

export default RegisterPage;
