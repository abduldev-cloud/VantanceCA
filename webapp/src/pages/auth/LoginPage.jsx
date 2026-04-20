import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import AuthLayout from '../../components/layout/AuthLayout';
import Typography from '../../components/common/Typography';
import Input from '../../components/common/Input';
import Button from '../../components/common/Button';
import { useRole } from '../../hooks/useRole';
import authService from '../../services/authService';
import LoginLogo from '../../assets/images/logo/login_logo.png';
import GoogleLogo from '../../assets/icon/google.png';
import styles from './Login.module.css';

const LoginPage = () => {
    const [formData, setFormData] = useState({
        email: '',
        password: '',
        rememberMe: false
    });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const navigate = useNavigate();
    const { setRole } = useRole();

    const handleChange = (e) => {
        const { name, value, type, checked } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value
        }));
    };

    const parseJwt = (token) => {
        try {
            return JSON.parse(atob(token.split('.')[1]));
        } catch (e) {
            return null;
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            const data = await authService.login(formData.email, formData.password);
            const decoded = parseJwt(data.access_token);
            const userId = decoded.sub;

            // Get detailed entity details (like learner_id/teacher_id)
            const details = await authService.getUserDetails(userId);

            // Store details
            localStorage.setItem('userData', JSON.stringify(details));

            // Determine role and set it in context
            const roleName = details.role_display_name; // e.g., "LEARNER", "TEACHER", "ADMIN"
            localStorage.setItem('userRole', roleName);
            setRole(roleName);

            // Navigate based on role
            if (roleName.toUpperCase() === 'LEARNER') {
                navigate('/student/class');
            } else if (roleName.toUpperCase() === 'TEACHER') {
                navigate('/teacher/dashboard');
            } else if (roleName.toUpperCase() === 'ADMIN' || roleName.toUpperCase() === 'INSTITUTE_ADMIN' || roleName.toUpperCase() === 'PLATFORM_ADMIN') {
                navigate('/admin/dashboard');
            }
        } catch (err) {
            setError('Invalid email or password. Please try again.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    return (
        <AuthLayout image={LoginLogo}>
            <div className={styles.header}>
                <Typography variant="displaySmall" weight="600" align="center">
                    WELCOME BACK
                </Typography>
                <Typography variant="bodyMedium" color="#667085" align="center" className={styles.subtitle}>
                    Please enter your details.
                </Typography>
                {error && <div className={styles.error}>{error}</div>}
            </div>

            <form onSubmit={handleSubmit} className={styles.form}>
                <Input
                    label="Email"
                    name="email"
                    placeholder="Enter your email"
                    value={formData.email}
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

                <div className={styles.footerRow}>
                    <label className={styles.checkboxLabel}>
                        <input
                            type="checkbox"
                            name="rememberMe"
                            checked={formData.rememberMe}
                            onChange={handleChange}
                        />
                        Remember me
                    </label>
                    <a href="/auth/forgot_password" className={styles.link}>
                        Forgot password?
                    </a>
                </div>

                <Button type="submit" fullWidth loading={loading}>
                    Sign in
                </Button>

                {/* <Button variant="secondary" fullWidth className={styles.googleBtn}>
                    <img src={GoogleLogo} alt="Google" className={styles.googleIcon} />
                    Sign in with Google
                </Button> */}

                <div className={styles.footerLinks}>
                    <Typography variant="bodySmall" color="#667085">
                        Don't have an account? <Link to="/auth/register" className={styles.boldLink}>Register</Link>
                    </Typography>
                    <Typography variant="bodySmall" color="#667085" className={styles.mt20}>
                        Don't have an access? <a href="#" className={styles.boldLink}>Join Us</a>
                    </Typography>
                </div>
            </form>
        </AuthLayout>
    );
};

export default LoginPage;
