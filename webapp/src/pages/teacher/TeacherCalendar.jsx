import React, { useState } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import CreateAssignmentDialog from './CreateAssignmentDialog';
import styles from './TeacherCalendar.module.css';

const TeacherCalendar = () => {
    const [currentDate, setCurrentDate] = useState(new Date());
    const [view, setView] = useState('month');
    const [isModalOpen, setIsModalOpen] = useState(false);

    const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
    ];

    const daysInMonth = (month, year) => new Date(year, month + 1, 0).getDate();
    const firstDayOfMonth = (month, year) => new Date(year, month, 1).getDay();

    const prevMonth = () => {
        setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1));
    };

    const nextMonth = () => {
        setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
    };

    const mockEvents = {
        '10': { class: 'Grade 11-A', title: 'Orwell Essay Due' },
        '15': { class: 'Grade 10-B', title: 'Creative Writing Sub' },
        '22': { class: 'Grade 12-C', title: 'Fingerprint Session' }
    };

    const renderDays = () => {
        const totalDays = daysInMonth(currentDate.getMonth(), currentDate.getFullYear());
        const firstDay = firstDayOfMonth(currentDate.getMonth(), currentDate.getFullYear());
        const days = [];

        // Fill empty slots for previous month
        for (let i = 0; i < firstDay; i++) {
            days.push(<div key={`empty-${i}`} className={`${styles.day} ${styles.dayEmpty}`}></div>);
        }

        // Fill actual days
        for (let i = 1; i <= totalDays; i++) {
            const isToday = i === new Date().getDate() &&
                currentDate.getMonth() === new Date().getMonth() &&
                currentDate.getFullYear() === new Date().getFullYear();

            days.push(
                <div key={i} className={styles.day}>
                    <div className={isToday ? styles.todayCircle : styles.dayNumber}>{i}</div>
                    {mockEvents[i] && (
                        <div className={styles.event}>
                            <span className={styles.eventClass}>{mockEvents[i].class}</span>
                            <span className={styles.eventTitle}>{mockEvents[i].title}</span>
                        </div>
                    )}
                </div>
            );
        }

        return days;
    };

    return (
        <MainLayout>
            <TitleBar
                title="Calendar"
                subTitle="Track upcoming assignments and deadlines"
                buttonTitle="Create Assignment"
                onTap={() => setIsModalOpen(true)}
            />

            <div className={styles.calendarCard}>
                <div className={styles.calendarHeader}>
                    <div className={styles.navControls}>
                        <button onClick={prevMonth} className={styles.navBtn}><ChevronLeft size={20} /></button>
                        <button onClick={nextMonth} className={styles.navBtn}><ChevronRight size={20} /></button>
                        <span className={styles.currentMonth}>
                            {months[currentDate.getMonth()]} {currentDate.getFullYear()}
                        </span>
                    </div>

                    <div className={styles.viewTabs}>
                        <button
                            className={`${styles.tabBtn} ${view === 'today' ? styles.activeTab : ''}`}
                            onClick={() => setView('today')}
                        >
                            Today
                        </button>
                        <button
                            className={`${styles.tabBtn} ${view === 'month' ? styles.activeTab : ''}`}
                            onClick={() => setView('month')}
                        >
                            Month
                        </button>
                        <button
                            className={`${styles.tabBtn} ${view === 'schedule' ? styles.activeTab : ''}`}
                            onClick={() => setView('schedule')}
                        >
                            Schedule
                        </button>
                    </div>
                </div>

                <div className={styles.calendarGrid}>
                    <div className={styles.weekHeader}>
                        {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(day => (
                            <div key={day} className={styles.weekDay}>{day}</div>
                        ))}
                    </div>
                    <div className={styles.daysGrid}>
                        {renderDays()}
                    </div>
                </div>
            </div>
            <CreateAssignmentDialog isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
        </MainLayout>
    );
};

export default TeacherCalendar;
