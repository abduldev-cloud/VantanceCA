import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
    LayoutDashboard,
    BookOpen,
    BarChart2,
    Layers,
    CreditCard,
    Settings,
    HelpCircle,
    Fingerprint,
    ClipboardList,
    GraduationCap,
    Calendar,
    ChevronLeft,
    ChevronRight,
    LogOut,
    User,
    Shield,
    Activity
} from 'lucide-react';
import authService from '../../services/authService';
import { useRole } from '../../hooks/useRole';
import Logo from '../../assets/images/logo/Logo.jpg';
import LogoCircle from '../../assets/images/logo/logo_circle.png';
import styles from './Sidebar.module.css';

const Sidebar = () => {
    const [isCondensed, setIsCondensed] = useState(localStorage.getItem('sidebarCondensed') === 'true');
    const { isTeacher, isStudent, isInstituteAdmin, isPlatformAdmin, setRole } = useRole();
    const navigate = useNavigate();
    const location = useLocation();

    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    const userName = userData ? `${userData.first_name || ''} ${userData.last_name || ''}`.trim() || 'User' : 'User';
    const userCode = userData ? userData.role_entity_id : '';

    const handleLogout = () => {
        authService.logout();
        setRole(null);
        navigate('/');
    };

    const menuItems = {
        teacher: [
            { title: 'Dashboard', icon: <LayoutDashboard size={20} />, path: '/teacher/dashboard' },
            { title: 'Classes', icon: <BookOpen size={20} />, path: '/teacher/classes' },
            { title: 'Study Material', icon: <Layers size={20} />, path: '/teacher/study-material' },
            // { title: 'Writing Fingerprint', icon: <Fingerprint size={20} />, path: '/teacher/fingerprint' },
            { title: 'Assignments', icon: <ClipboardList size={20} />, path: '/teacher/assignments' },
            { title: 'Grading', icon: <GraduationCap size={20} />, path: '/teacher/grading' },
            { title: 'Calendar', icon: <Calendar size={20} />, path: '/teacher/calendar' },
            // { title: 'Analytics', icon: <BarChart2 size={20} />, path: '/teacher/analytics' },
            { type: 'spacer' },
            { title: 'Settings', icon: <Settings size={20} />, path: '/school/setting' },
            { title: 'Help', icon: <HelpCircle size={20} />, path: '/teacher/faqs' },
        ],
        student: [
            { title: 'Papers', icon: <BookOpen size={20} />, path: '/student/class' },
            { title: 'Study Material', icon: <Layers size={20} />, path: '/student/study-material' },
            { title: 'Practices', icon: <ClipboardList size={20} />, path: '/student/assignment' },
            { title: 'Result', icon: <GraduationCap size={20} />, path: '/student/result' },
            { title: 'Calendar', icon: <Calendar size={20} />, path: '/student/calendar' },
            { title: 'Settings', icon: <Settings size={20} />, path: '/school/setting' },
            { title: 'Help', icon: <HelpCircle size={20} />, path: '/student/faqs' },
        ],
        platform_admin: [
            { title: 'Dashboard', icon: <LayoutDashboard size={20} />, path: '/admin/dashboard' },
            { title: 'Schools', icon: <BookOpen size={20} />, path: '/admin/school' },
            { title: 'Users', icon: <User size={20} />, path: '/admin/user' },
            { title: 'Dictionary', icon: <ClipboardList size={20} />, path: '/admin/dictionary' },
            { title: 'Security', icon: <Shield size={20} />, path: '/admin/security' },
            { title: 'API Quotas', icon: <Activity size={20} />, path: '/admin/api-quotas' },
            { type: 'spacer' },
            { title: 'Settings', icon: <Settings size={20} />, path: '/school/setting' },
            { title: 'Help', icon: <HelpCircle size={20} />, path: '/admin/faqs' },
        ],
        institute_admin: [
            { title: 'Dashboard', icon: <LayoutDashboard size={20} />, path: '/admin/dashboard' },
            { title: 'Schools', icon: <BookOpen size={20} />, path: '/admin/school' },
            { title: 'Users', icon: <User size={20} />, path: '/admin/user' },
            { type: 'spacer' },
            { title: 'Settings', icon: <Settings size={20} />, path: '/school/setting' },
            { title: 'Help', icon: <HelpCircle size={20} />, path: '/admin/faqs' },
        ]
    };

    const activeItems = isTeacher
        ? menuItems.teacher
        : isStudent
            ? menuItems.student
            : isPlatformAdmin
                ? menuItems.platform_admin
                : isInstituteAdmin
                    ? menuItems.institute_admin
                    : [];

    const toggleSidebar = () => {
        const newState = !isCondensed;
        setIsCondensed(newState);
        localStorage.setItem('sidebarCondensed', newState.toString());
    };

    let customLogoUrl = null;
    try {
        const data = localStorage.getItem('userData');
        if (data) {
            const parsed = JSON.parse(data);
            if (parsed.logo_url) {
                customLogoUrl = `${import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000'}${parsed.logo_url}`;
            }
        }
    } catch (e) {
        // use default
    }

    return (
        <div className={`${styles.sidebar} ${isCondensed ? styles.condensed : ''}`}>
            <div className={styles.logoSection} onClick={toggleSidebar}>
                <img
                    src={customLogoUrl ? customLogoUrl : (isCondensed ? LogoCircle : Logo)}
                    alt="Logo"
                    className={styles.logo}
                    style={customLogoUrl ? { objectFit: 'contain', maxHeight: '45px', width: 'auto' } : {}}
                />
            </div>

            <nav className={styles.nav}>
                {activeItems.map((item, index) => {
                    if (item.type === 'spacer') return <div key={index} className={styles.spacer} />;

                    const isActive = location.pathname === item.path;

                    return (
                        <div
                            key={index}
                            className={`${styles.navItem} ${isActive ? styles.active : ''}`}
                            onClick={() => navigate(item.path)}
                        >
                            <div className={styles.icon}>{item.icon}</div>
                            {!isCondensed && <span className={styles.title}>{item.title}</span>}
                        </div>
                    );
                })}
            </nav>

            <div className={styles.userProfile}>
                <div className={styles.avatar}>
                    <User size={20} />
                </div>
                {!isCondensed && (
                    <>
                        <div className={styles.userInfo}>
                            <span className={styles.userName}>{userName}</span>
                            <span className={styles.userId}>{userCode}</span>
                        </div>
                        <button className={styles.logoutBtn} onClick={handleLogout} title="Logout">
                            <LogOut size={18} />
                        </button>
                    </>
                )}
            </div>
        </div>
    );
};

export default Sidebar;
