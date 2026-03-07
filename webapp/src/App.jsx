import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { RoleProvider } from './hooks/useRole';
import LoginPage from './pages/auth/LoginPage';
import TeacherDashboard from './pages/teacher/Dashboard';
import TeacherClasses from './pages/teacher/TeacherClasses';
import TeacherClassDetail from './pages/teacher/TeacherClassDetail';
import StudyMaterial from './pages/teacher/StudyMaterial';
import WritingFingerprint from './pages/teacher/WritingFingerprint';
import Grading from './pages/teacher/Grading';
import TeacherCalendar from './pages/teacher/TeacherCalendar';
import Analytics from './pages/teacher/Analytics';
import AssignmentDetail from './pages/teacher/AssignmentDetail';
import GradingReview from './pages/teacher/GradingReview';
import TeacherAssignmentsPage from './pages/teacher/Assignments';
import StudentPapers from './pages/student/StudentPapers';
import StudentStudyMaterial from './pages/student/StudentStudyMaterial';
import StudentPractices from './pages/student/StudentPractices';
import StudentResults from './pages/student/StudentResults';
import StudentCalendar from './pages/student/StudentCalendar';
import PerformanceReport from './pages/student/PerformanceReport';
import ClassDetail from './pages/student/ClassDetail';
import WritingPad from './pages/student/WritingPad/WritingPad';
import SettingsPage from './pages/student/SettingsPage';
import SubscriptionPage from './pages/student/SubscriptionPage';
import SecurityPrivacyPage from './pages/student/SecurityPrivacyPage';
import FAQPage from './pages/student/FAQPage';
import AdminDashboard from './pages/admin/AdminDashboard';
import AdminSchools from './pages/admin/AdminSchools';
import AdminUsers from './pages/admin/AdminUsers';
import AdminAnalytics from './pages/admin/AdminAnalytics';
import AdminDictionary from './pages/admin/AdminDictionary';
import AdminSecurityLogs from './pages/admin/AdminSecurityLogs';
import AdminApiQuotas from './pages/admin/AdminApiQuotas';
import './styles/global.css';

function App() {
    useEffect(() => {
        try {
            const data = localStorage.getItem('userData');
            if (data) {
                const parsed = JSON.parse(data);
                if (parsed.primary_color) {
                    document.documentElement.style.setProperty('--primary-color', parsed.primary_color);
                } else {
                    document.documentElement.style.setProperty('--primary-color', '#004AAD'); // generic platform default
                }
            }
        } catch (e) {
            console.error('Failed to parse userData for branding', e);
        }
    }, [window.location.pathname]);

    return (
        <RoleProvider>
            <Router>
                <Routes>
                    <Route path="/auth/login" element={<LoginPage />} />
                    <Route path="/teacher/dashboard" element={<TeacherDashboard />} />
                    <Route path="/teacher/classes" element={<TeacherClasses />} />
                    <Route path="/teacher/classes/:id" element={<TeacherClassDetail />} />
                    <Route path="/teacher/study-material" element={<StudyMaterial />} />
                    <Route path="/teacher/fingerprint" element={<WritingFingerprint />} />
                    <Route path="/teacher/grading" element={<Grading />} />
                    <Route path="/teacher/calendar" element={<TeacherCalendar />} />
                    <Route path="/teacher/analytics" element={<Analytics />} />
                    <Route path="/teacher/assignments/:id" element={<AssignmentDetail />} />
                    <Route path="/teacher/grading-review" element={<GradingReview />} />
                    <Route path="/teacher/assignments" element={<TeacherAssignmentsPage />} />

                    {/* Admin Routes */}
                    <Route path="/admin/dashboard" element={<AdminDashboard />} />
                    <Route path="/admin/school" element={<AdminSchools />} />
                    <Route path="/admin/user" element={<AdminUsers />} />
                    <Route path="/admin/dictionary" element={<AdminDictionary />} />
                    <Route path="/admin/security" element={<AdminSecurityLogs />} />
                    <Route path="/admin/api-quotas" element={<AdminApiQuotas />} />
                    <Route path="/admin/analytics" element={<AdminAnalytics />} />

                    {/* Student Routes */}
                    <Route path="/student/class" element={<StudentPapers />} />
                    <Route path="/student/study-material" element={<StudentStudyMaterial />} />
                    <Route path="/student/class/:id" element={<ClassDetail />} />
                    <Route path="/student/assignment" element={<StudentPractices />} />
                    <Route path="/student/result" element={<StudentResults />} />
                    <Route path="/student/calendar" element={<StudentCalendar />} />
                    <Route path="/student/performance" element={<PerformanceReport />} />
                    <Route path="/student/writingpad" element={<WritingPad />} />
                    <Route path="/school/setting" element={<SettingsPage />} />
                    <Route path="/student/subscription" element={<SubscriptionPage />} />
                    <Route path="/student/security" element={<SecurityPrivacyPage />} />
                    <Route path="/student/faqs" element={<FAQPage />} />
                    <Route path="/teacher/faqs" element={<FAQPage />} />
                    <Route path="/admin/faqs" element={<FAQPage />} />

                    {/* Default routes */}
                    <Route path="/" element={<Navigate to="/auth/login" replace />} />
                    <Route path="*" element={<Navigate to="/auth/login" replace />} />
                </Routes>
            </Router>
        </RoleProvider>
    );
}

export default App;
