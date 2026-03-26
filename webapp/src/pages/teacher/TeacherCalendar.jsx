import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    ChevronLeft, ChevronRight, Clock, FileText, CheckCircle,
    PenTool, AlertCircle, CalendarDays, ListChecks, X,
    Plus, Trash2, Bell, Check
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import CreateAssignmentDialog from './CreateAssignmentDialog';
import teacherService from '../../services/teacherService';
import styles from './TeacherCalendar.module.css';

const EVENT_CONFIG = {
    deadline: { icon: AlertCircle, label: 'Due Date', bg: '#FEF2F2', border: '#EF4444', text: '#B91C1C' },
    submission: { icon: FileText, label: 'Submission', bg: '#FFF7ED', border: '#F59E0B', text: '#92400E' },
    graded: { icon: CheckCircle, label: 'Graded', bg: '#F0FDF4', border: '#10B981', text: '#065F46' },
    created: { icon: PenTool, label: 'Created', bg: '#EFF6FF', border: '#3B82F6', text: '#1E40AF' },
    reminder: { icon: Bell, label: 'Reminder', bg: '#EEF2FF', border: '#6366F1', text: '#3730A3' }
};

const TeacherCalendar = () => {
    const [currentDate, setCurrentDate] = useState(new Date());
    const [view, setView] = useState('month');
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [events, setEvents] = useState([]);
    const [reminders, setReminders] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [selectedDay, setSelectedDay] = useState(null);
    const [filterType, setFilterType] = useState('all');
    const [showAddReminder, setShowAddReminder] = useState(false);
    const [reminderTitle, setReminderTitle] = useState('');
    const [reminderDesc, setReminderDesc] = useState('');
    const [reminderType, setReminderType] = useState('personal');
    const [reminderColor, setReminderColor] = useState('#6366F1');
    const [isSavingReminder, setIsSavingReminder] = useState(false);
    const navigate = useNavigate();

    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    const teacherId = userData.role_entity_id;

    const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
    ];

    const fetchData = async () => {
        if (!teacherId) return;
        setIsLoading(true);
        try {
            const [eventsRes, remindersRes] = await Promise.all([
                teacherService.getCalendarEvents(teacherId),
                teacherService.getReminders(teacherId)
            ]);
            if (eventsRes.success) setEvents(eventsRes.data || []);
            if (remindersRes.success) setReminders(remindersRes.data || []);
        } catch (err) {
            console.error('Error fetching calendar data:', err);
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, [teacherId]);

    const handleAddReminder = async () => {
        if (!reminderTitle.trim() || !selectedDay) return;
        setIsSavingReminder(true);
        try {
            const dateStr = getDateStr(selectedDay);
            const res = await teacherService.createReminder(teacherId, {
                title: reminderTitle,
                date: dateStr,
                description: reminderDesc,
                type: reminderType,
                color: reminderColor
            });
            if (res.success) {
                setReminderTitle('');
                setReminderDesc('');
                setShowAddReminder(false);
                fetchData();
            }
        } catch (err) {
            console.error('Error creating reminder:', err);
            alert('Failed to create reminder.');
        } finally {
            setIsSavingReminder(false);
        }
    };

    const handleDeleteReminder = async (reminderId) => {
        try {
            await teacherService.deleteReminder(reminderId);
            fetchData();
        } catch (err) {
            console.error('Error deleting reminder:', err);
        }
    };

    const handleToggleReminder = async (reminderId) => {
        try {
            await teacherService.toggleReminder(reminderId);
            fetchData();
        } catch (err) {
            console.error('Error toggling reminder:', err);
        }
    };

    const daysInMonth = (month, year) => new Date(year, month + 1, 0).getDate();
    const firstDayOfMonth = (month, year) => new Date(year, month, 1).getDay();

    const prevMonth = () => {
        setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1));
        setSelectedDay(null);
    };

    const nextMonth = () => {
        setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
        setSelectedDay(null);
    };

    const goToToday = () => {
        setCurrentDate(new Date());
        setSelectedDay(new Date().getDate());
        setView('month');
    };

    const getDateStr = (day) => {
        const m = String(currentDate.getMonth() + 1).padStart(2, '0');
        const d = String(day).padStart(2, '0');
        return `${currentDate.getFullYear()}-${m}-${d}`;
    };

    const getEventsForDay = (day) => {
        const dateStr = getDateStr(day);
        let dayEvents = events.filter(e => e.date === dateStr);
        // Add reminders as events
        const dayReminders = reminders.filter(r => r.reminder_date === dateStr).map(r => ({
            ...r,
            type: 'reminder',
            title: r.reminder_title,
            color: r.color || '#6366F1',
            date: r.reminder_date
        }));
        dayEvents = [...dayEvents, ...dayReminders];
        if (filterType !== 'all' && filterType !== 'reminder') dayEvents = dayEvents.filter(e => e.type === filterType);
        if (filterType === 'reminder') dayEvents = dayEvents.filter(e => e.type === 'reminder');
        return dayEvents;
    };

    // Stats
    const monthEvents = events.filter(e => {
        const d = new Date(e.date);
        return d.getMonth() === currentDate.getMonth() && d.getFullYear() === currentDate.getFullYear();
    });
    const deadlineCount = monthEvents.filter(e => e.type === 'deadline').length;
    const submissionCount = monthEvents.filter(e => e.type === 'submission').length;
    const gradedCount = monthEvents.filter(e => e.type === 'graded').length;
    const monthReminders = reminders.filter(r => {
        const d = new Date(r.reminder_date);
        return d.getMonth() === currentDate.getMonth() && d.getFullYear() === currentDate.getFullYear();
    });

    // Upcoming deadlines (next 7 days)
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const nextWeek = new Date(today);
    nextWeek.setDate(nextWeek.getDate() + 7);
    const upcomingDeadlines = events
        .filter(e => e.type === 'deadline' && new Date(e.date) >= today && new Date(e.date) <= nextWeek)
        .sort((a, b) => new Date(a.date) - new Date(b.date));

    // Schedule view data
    const allMonthEvents = [...monthEvents].sort((a, b) => new Date(a.date) - new Date(b.date));

    const selectedDayEvents = selectedDay ? getEventsForDay(selectedDay) : [];
    const selectedDayReminders = selectedDay ? reminders.filter(r => r.reminder_date === getDateStr(selectedDay)) : [];

    const renderDays = () => {
        const totalDays = daysInMonth(currentDate.getMonth(), currentDate.getFullYear());
        const firstDay = firstDayOfMonth(currentDate.getMonth(), currentDate.getFullYear());
        const days = [];

        for (let i = 0; i < firstDay; i++) {
            days.push(<div key={`empty-${i}`} className={`${styles.day} ${styles.dayEmpty}`}></div>);
        }

        for (let i = 1; i <= totalDays; i++) {
            const isToday = i === new Date().getDate() &&
                currentDate.getMonth() === new Date().getMonth() &&
                currentDate.getFullYear() === new Date().getFullYear();
            const dayEvents = getEventsForDay(i);
            const isSelected = selectedDay === i;

            days.push(
                <div
                    key={i}
                    className={`${styles.day} ${isSelected ? styles.daySelected : ''} ${dayEvents.length > 0 ? styles.dayHasEvents : ''}`}
                    onClick={() => setSelectedDay(i === selectedDay ? null : i)}
                >
                    <div className={isToday ? styles.todayCircle : styles.dayNumber}>{i}</div>
                    <div className={styles.eventDots}>
                        {dayEvents.slice(0, 3).map((ev, idx) => (
                            <div key={idx} className={styles.eventPill} style={{ background: EVENT_CONFIG[ev.type]?.border || '#6B7280' }}>
                                <span className={styles.eventPillText}>{ev.title}</span>
                            </div>
                        ))}
                        {dayEvents.length > 3 && (
                            <div className={styles.moreEvents}>+{dayEvents.length - 3} more</div>
                        )}
                    </div>
                </div>
            );
        }

        return days;
    };

    return (
        <MainLayout>
            <TitleBar
                title="Calendar"
                subTitle="Track upcoming assignments, submissions, and deadlines"
                buttonTitle="Create Assignment"
                onTap={() => setIsModalOpen(true)}
            />

            <div className={styles.calendarLayout}>
                {/* Left: Calendar */}
                <div className={styles.calendarMain}>
                    {/* Stats */}
                    <div className={styles.statsRow}>
                        <div className={styles.statCard} style={{ borderLeft: '4px solid #EF4444' }}>
                            <div className={styles.statValue} style={{ color: '#EF4444' }}>{deadlineCount}</div>
                            <div className={styles.statLabel}>Deadlines</div>
                        </div>
                        <div className={styles.statCard} style={{ borderLeft: '4px solid #F59E0B' }}>
                            <div className={styles.statValue} style={{ color: '#F59E0B' }}>{submissionCount}</div>
                            <div className={styles.statLabel}>Submissions</div>
                        </div>
                        <div className={styles.statCard} style={{ borderLeft: '4px solid #10B981' }}>
                            <div className={styles.statValue} style={{ color: '#10B981' }}>{gradedCount}</div>
                            <div className={styles.statLabel}>Graded</div>
                        </div>
                        <div className={styles.statCard} style={{ borderLeft: '4px solid #6366F1' }}>
                            <div className={styles.statValue} style={{ color: '#6366F1' }}>{monthReminders.length}</div>
                            <div className={styles.statLabel}>Reminders</div>
                        </div>
                    </div>

                    {/* Calendar Card */}
                    <div className={styles.calendarCard}>
                        <div className={styles.calendarHeader}>
                            <div className={styles.navControls}>
                                <button onClick={prevMonth} className={styles.navBtn}><ChevronLeft size={20} /></button>
                                <button onClick={nextMonth} className={styles.navBtn}><ChevronRight size={20} /></button>
                                <span className={styles.currentMonth}>
                                    {months[currentDate.getMonth()]} {currentDate.getFullYear()}
                                </span>
                            </div>

                            <div className={styles.headerRight}>
                                {/* Filter Chips */}
                                <div className={styles.filterChips}>
                                    {[
                                        { key: 'all', label: 'All' },
                                        { key: 'deadline', label: 'Deadlines', color: '#EF4444' },
                                        { key: 'submission', label: 'Submissions', color: '#F59E0B' },
                                        { key: 'graded', label: 'Graded', color: '#10B981' },
                                        { key: 'reminder', label: 'Reminders', color: '#6366F1' }
                                    ].map(f => (
                                        <button
                                            key={f.key}
                                            className={`${styles.filterChip} ${filterType === f.key ? styles.filterChipActive : ''}`}
                                            onClick={() => setFilterType(f.key)}
                                            style={filterType === f.key && f.color ? { background: f.color, color: '#fff', borderColor: f.color } : {}}
                                        >
                                            {f.color && <span className={styles.chipDot} style={{ background: f.color }}></span>}
                                            {f.label}
                                        </button>
                                    ))}
                                </div>

                                {/* View Tabs */}
                                <div className={styles.viewTabs}>
                                    <button
                                        className={`${styles.tabBtn} ${view === 'month' ? styles.activeTab : ''}`}
                                        onClick={() => setView('month')}
                                    >
                                        <CalendarDays size={14} /> Month
                                    </button>
                                    <button
                                        className={`${styles.tabBtn} ${view === 'schedule' ? styles.activeTab : ''}`}
                                        onClick={() => setView('schedule')}
                                    >
                                        <ListChecks size={14} /> Schedule
                                    </button>
                                    <button className={styles.todayBtn} onClick={goToToday}>Today</button>
                                </div>
                            </div>
                        </div>

                        {view === 'month' ? (
                            <div className={styles.calendarGrid}>
                                <div className={styles.weekHeader}>
                                    {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(day => (
                                        <div key={day} className={styles.weekDay}>{day}</div>
                                    ))}
                                </div>
                                <div className={styles.daysGrid}>
                                    {isLoading ? (
                                        <div className={styles.loadingOverlay}>Loading events...</div>
                                    ) : renderDays()}
                                </div>
                            </div>
                        ) : (
                            /* Schedule View */
                            <div className={styles.scheduleView}>
                                {allMonthEvents.length === 0 ? (
                                    <div className={styles.emptySchedule}>
                                        <CalendarDays size={48} color="#CBD5E1" />
                                        <p>No events this month</p>
                                    </div>
                                ) : (
                                    allMonthEvents.map((ev, idx) => {
                                        const cfg = EVENT_CONFIG[ev.type] || EVENT_CONFIG.created;
                                        const Icon = cfg.icon;
                                        return (
                                            <div key={idx} className={styles.scheduleItem} style={{ borderLeft: `4px solid ${cfg.border}` }}>
                                                <div className={styles.scheduleDate}>
                                                    <span className={styles.scheduleDateDay}>{new Date(ev.date).getDate()}</span>
                                                    <span className={styles.scheduleDateMonth}>{months[new Date(ev.date).getMonth()].slice(0, 3)}</span>
                                                </div>
                                                <div className={styles.scheduleContent}>
                                                    <div className={styles.scheduleTitle}>
                                                        <Icon size={14} color={cfg.border} />
                                                        <span>{ev.title}</span>
                                                    </div>
                                                    <div className={styles.scheduleMeta}>
                                                        <span className={styles.scheduleTag} style={{ background: cfg.bg, color: cfg.text }}>{cfg.label}</span>
                                                        <span className={styles.scheduleClass}>{ev.class_name}</span>
                                                        {ev.task_title && <span className={styles.scheduleClass}>• {ev.task_title}</span>}
                                                    </div>
                                                </div>
                                                {ev.type === 'deadline' && (
                                                    <div className={styles.scheduleProgress}>
                                                        {ev.submission_count}/{ev.student_count} submitted
                                                    </div>
                                                )}
                                            </div>
                                        );
                                    })
                                )}
                            </div>
                        )}
                    </div>
                </div>

                {/* Right Sidebar */}
                <div className={styles.sidebar}>
                    {/* Selected Day Detail */}
                    {selectedDay && (
                        <div className={styles.sidebarCard}>
                            <div className={styles.sidebarCardHeader}>
                                <h3>{months[currentDate.getMonth()]} {selectedDay}, {currentDate.getFullYear()}</h3>
                                <button className={styles.closeBtn} onClick={() => { setSelectedDay(null); setShowAddReminder(false); }}><X size={16} /></button>
                            </div>
                            
                            {/* Events for this day */}
                            {selectedDayEvents.filter(e => e.type !== 'reminder').length > 0 && (
                                <div className={styles.dayEventsList}>
                                    {selectedDayEvents.filter(e => e.type !== 'reminder').map((ev, idx) => {
                                        const cfg = EVENT_CONFIG[ev.type] || EVENT_CONFIG.created;
                                        const Icon = cfg.icon;
                                        return (
                                            <div
                                                key={idx}
                                                className={styles.dayEventItem}
                                                style={{ background: cfg.bg, borderLeft: `3px solid ${cfg.border}` }}
                                                onClick={() => ev.task_id && navigate(`/teacher/assignments/${ev.task_id}`)}
                                            >
                                                <Icon size={16} color={cfg.border} />
                                                <div>
                                                    <div className={styles.dayEventTitle}>{ev.title}</div>
                                                    <div className={styles.dayEventMeta}>
                                                        {ev.class_name}
                                                        {ev.task_type && ` • ${ev.task_type}`}
                                                    </div>
                                                </div>
                                            </div>
                                        );
                                    })}
                                </div>
                            )}

                            {/* Reminders for this day */}
                            {selectedDayReminders.length > 0 && (
                                <div style={{ marginTop: '10px' }}>
                                    <div style={{ fontSize: '12px', fontWeight: '600', color: '#6366F1', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '4px' }}>
                                        <Bell size={12} /> Reminders
                                    </div>
                                    <div className={styles.dayEventsList}>
                                        {selectedDayReminders.map((rem) => (
                                            <div
                                                key={rem.reminder_id}
                                                className={styles.reminderItem}
                                                style={{ borderLeft: `3px solid ${rem.color || '#6366F1'}` }}
                                            >
                                                <button 
                                                    className={styles.reminderToggle}
                                                    onClick={() => handleToggleReminder(rem.reminder_id)}
                                                    style={{ background: rem.is_completed ? '#10B981' : 'transparent', borderColor: rem.is_completed ? '#10B981' : '#CBD5E1' }}
                                                >
                                                    {rem.is_completed && <Check size={10} color="#fff" />}
                                                </button>
                                                <div style={{ flex: 1, minWidth: 0 }}>
                                                    <div className={styles.dayEventTitle} style={{ textDecoration: rem.is_completed ? 'line-through' : 'none', opacity: rem.is_completed ? 0.6 : 1 }}>
                                                        {rem.reminder_title}
                                                    </div>
                                                    {rem.reminder_description && (
                                                        <div className={styles.dayEventMeta}>{rem.reminder_description}</div>
                                                    )}
                                                </div>
                                                <button 
                                                    className={styles.reminderDeleteBtn}
                                                    onClick={() => handleDeleteReminder(rem.reminder_id)}
                                                >
                                                    <Trash2 size={13} />
                                                </button>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            )}

                            {/* Add Reminder */}
                            {!showAddReminder ? (
                                <button 
                                    className={styles.addReminderBtn}
                                    onClick={() => setShowAddReminder(true)}
                                >
                                    <Plus size={14} /> Add Reminder
                                </button>
                            ) : (
                                <div className={styles.reminderForm}>
                                    <div className={styles.reminderFormTitle}>
                                        <Bell size={14} color="#6366F1" /> New Reminder
                                    </div>
                                    <input
                                        className={styles.reminderInput}
                                        placeholder="Reminder title..."
                                        value={reminderTitle}
                                        onChange={(e) => setReminderTitle(e.target.value)}
                                        autoFocus
                                    />
                                    <textarea
                                        className={styles.reminderTextarea}
                                        placeholder="Description (optional)"
                                        value={reminderDesc}
                                        onChange={(e) => setReminderDesc(e.target.value)}
                                        rows={2}
                                    />
                                    <div className={styles.reminderFormRow}>
                                        <select
                                            className={styles.reminderSelect}
                                            value={reminderType}
                                            onChange={(e) => setReminderType(e.target.value)}
                                        >
                                            <option value="personal">Personal</option>
                                            <option value="class">Class</option>
                                            <option value="deadline">Deadline</option>
                                        </select>
                                        <div className={styles.colorPicker}>
                                            {['#6366F1', '#EF4444', '#F59E0B', '#10B981', '#EC4899', '#8B5CF6'].map(c => (
                                                <button
                                                    key={c}
                                                    className={`${styles.colorDot} ${reminderColor === c ? styles.colorDotActive : ''}`}
                                                    style={{ background: c }}
                                                    onClick={() => setReminderColor(c)}
                                                />
                                            ))}
                                        </div>
                                    </div>
                                    <div className={styles.reminderFormActions}>
                                        <button
                                            className={styles.cancelBtn}
                                            onClick={() => { setShowAddReminder(false); setReminderTitle(''); setReminderDesc(''); }}
                                        >
                                            Cancel
                                        </button>
                                        <button
                                            className={styles.saveReminderBtn}
                                            onClick={handleAddReminder}
                                            disabled={!reminderTitle.trim() || isSavingReminder}
                                        >
                                            {isSavingReminder ? 'Saving...' : 'Save'}
                                        </button>
                                    </div>
                                </div>
                            )}

                            {selectedDayEvents.filter(e => e.type !== 'reminder').length === 0 && selectedDayReminders.length === 0 && !showAddReminder && (
                                <div className={styles.emptyDay}>No events on this day. Add a reminder!</div>
                            )}
                        </div>
                    )}

                    {/* Upcoming Deadlines */}
                    <div className={styles.sidebarCard}>
                        <div className={styles.sidebarCardHeader}>
                            <h3><Clock size={16} /> Upcoming Deadlines</h3>
                        </div>
                        {upcomingDeadlines.length === 0 ? (
                            <div className={styles.emptyDay}>No deadlines in the next 7 days!</div>
                        ) : (
                            <div className={styles.dayEventsList}>
                                {upcomingDeadlines.map((ev, idx) => {
                                    const daysLeft = Math.ceil((new Date(ev.date) - today) / (1000 * 60 * 60 * 24));
                                    return (
                                        <div
                                            key={idx}
                                            className={styles.deadlineItem}
                                            onClick={() => ev.task_id && navigate(`/teacher/assignments/${ev.task_id}`)}
                                        >
                                            <div className={styles.deadlineInfo}>
                                                <div className={styles.dayEventTitle}>{ev.title}</div>
                                                <div className={styles.dayEventMeta}>{ev.class_name}</div>
                                            </div>
                                            <div className={styles.deadlineBadge} style={{
                                                background: daysLeft <= 1 ? '#FEF2F2' : daysLeft <= 3 ? '#FFF7ED' : '#F0FDF4',
                                                color: daysLeft <= 1 ? '#B91C1C' : daysLeft <= 3 ? '#92400E' : '#065F46'
                                            }}>
                                                {daysLeft === 0 ? 'Today' : daysLeft === 1 ? 'Tomorrow' : `${daysLeft}d left`}
                                            </div>
                                        </div>
                                    );
                                })}
                            </div>
                        )}
                    </div>

                    {/* Legend */}
                    <div className={styles.sidebarCard}>
                        <div className={styles.sidebarCardHeader}>
                            <h3>Legend</h3>
                        </div>
                        <div className={styles.legendList}>
                            {Object.entries(EVENT_CONFIG).map(([key, cfg]) => {
                                const Icon = cfg.icon;
                                return (
                                    <div key={key} className={styles.legendItem}>
                                        <div className={styles.legendDot} style={{ background: cfg.border }}></div>
                                        <Icon size={14} color={cfg.border} />
                                        <span>{cfg.label}</span>
                                    </div>
                                );
                            })}
                        </div>
                    </div>
                </div>
            </div>

            <CreateAssignmentDialog isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
        </MainLayout>
    );
};

export default TeacherCalendar;
