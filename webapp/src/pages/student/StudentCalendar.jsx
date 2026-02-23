import React, { useState } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import styles from './StudentCalendar.module.css';

const StudentCalendar = () => {
    const [currentDate, setCurrentDate] = useState(new Date());
    const [view, setView] = useState('month');

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

    const renderDays = () => {
        const totalDays = daysInMonth(currentDate.getMonth(), currentDate.getFullYear());
        const firstDay = firstDayOfMonth(currentDate.getMonth(), currentDate.getFullYear());
        const days = [];

        // Fill empty slots for previous month
        for (let i = 0; i < firstDay; i++) {
            days.push(<div key={`empty-${i}`} className={styles.dayEmpty}></div>);
        }

        // Fill actual days
        for (let i = 1; i <= totalDays; i++) {
            const isToday = i === new Date().getDate() &&
                currentDate.getMonth() === new Date().getMonth() &&
                currentDate.getFullYear() === new Date().getFullYear();

            days.push(
                <div key={i} className={`${styles.day} ${isToday ? styles.today : ''}`}>
                    <span>{i}</span>
                    {/* Mock event */}
                    {i % 10 === 0 && <div className={styles.eventMarker}>Climate Essay</div>}
                </div>
            );
        }

        return days;
    };

    return (
        <MainLayout>
            <TitleBar
                title="Calendar"
                subTitle="Track upcoming assignments and deadlines."
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
        </MainLayout>
    );
};

export default StudentCalendar;
