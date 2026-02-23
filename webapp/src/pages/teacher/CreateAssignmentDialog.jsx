import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import teacherService from '../../services/teacherService';
import styles from './CreateAssignmentDialog.module.css';

const CreateAssignmentDialog = ({ isOpen, onClose }) => {
    const [step, setStep] = useState(1);
    const [rubricCount, setRubricCount] = useState(1);
    const [currentRubric, setCurrentRubric] = useState(1);
    const [classes, setClasses] = useState([]);
    const [isLoading, setIsLoading] = useState(false);

    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    const teacherId = userData.role_entity_id;

    // Form States
    const [formData, setFormData] = useState({
        title: '',
        targetWords: '',
        prompt: '',
        dueDate: '',
        dueTime: '',
        classId: '',
        grade: '',
        rubrics: [],
        strongThesis: '',
        strongReason: '',
        weakThesis: '',
        weakReason: ''
    });

    useEffect(() => {
        if (isOpen && teacherId) {
            const fetchClasses = async () => {
                try {
                    const response = await teacherService.getClasses(teacherId);
                    if (response.success) {
                        setClasses(response.data);
                    }
                } catch (err) {
                    console.error('Error fetching classes:', err);
                }
            };
            fetchClasses();
        }
    }, [isOpen, teacherId]);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
    };

    if (!isOpen) return null;

    const handleNext = async () => {
        if (step === 1) {
            setStep(2);
            setCurrentRubric(1);
        } else if (step === 2) {
            if (currentRubric < rubricCount) {
                setCurrentRubric(currentRubric + 1);
            } else {
                setStep(3);
            }
        } else {
            // Final step - Create Assignment
            setIsLoading(true);
            try {
                const payload = {
                    task_title: formData.title,
                    task_description: formData.prompt,
                    teacher_id: teacherId,
                    class_id: formData.classId,
                    due_date: formData.dueDate ? `${formData.dueDate}T${formData.dueTime || '23:59:00'}` : null,
                    max_score: 100
                };

                await teacherService.createAssignment(payload);
                alert('Assignment created successfully!');
                onClose();
            } catch (err) {
                console.error('Error creating assignment:', err);
                alert('Failed to create assignment.');
            } finally {
                setIsLoading(false);
            }
        }
    };

    const renderStep1 = () => (
        <div className={styles.form}>
            <div className={styles.field}>
                <label>Assignment Title</label>
                <input
                    name="title"
                    className={styles.input}
                    placeholder="Enter title"
                    value={formData.title}
                    onChange={handleChange}
                />
            </div>
            <div className={styles.row}>
                <div className={styles.field}>
                    <label>Target Words</label>
                    <input
                        name="targetWords"
                        className={styles.input}
                        placeholder="e.g. 500"
                        value={formData.targetWords}
                        onChange={handleChange}
                    />
                </div>
                <div className={styles.field}>
                    <label>Number of Rubrics</label>
                    <select className={styles.select} value={rubricCount} onChange={e => setRubricCount(parseInt(e.target.value))}>
                        {[1, 2, 3, 4, 5].map(n => <option key={n} value={n}>{n}</option>)}
                    </select>
                </div>
            </div>
            <div className={styles.field}>
                <label>Assignment Prompt</label>
                <textarea
                    name="prompt"
                    className={styles.textarea}
                    placeholder="Enter instructions..."
                    value={formData.prompt}
                    onChange={handleChange}
                />
            </div>
            <div className={styles.row}>
                <div className={styles.field}>
                    <label>Due Date</label>
                    <input
                        name="dueDate"
                        type="date"
                        className={styles.input}
                        value={formData.dueDate}
                        onChange={handleChange}
                    />
                </div>
                <div className={styles.field}>
                    <label>Due Time</label>
                    <input
                        name="dueTime"
                        type="time"
                        className={styles.input}
                        value={formData.dueTime}
                        onChange={handleChange}
                    />
                </div>
            </div>
            <div className={styles.row}>
                <div className={styles.field}>
                    <label>Class</label>
                    <select
                        name="classId"
                        className={styles.select}
                        value={formData.classId}
                        onChange={handleChange}
                    >
                        <option value="">Select Class</option>
                        {classes.map(cls => (
                            <option key={cls.class_id} value={cls.class_id}>{cls.class_name}</option>
                        ))}
                    </select>
                </div>
                <div className={styles.field}>
                    <label>Grade Level</label>
                    <select
                        name="grade"
                        className={styles.select}
                        value={formData.grade}
                        onChange={handleChange}
                    >
                        <option value="">Select Grade</option>
                        <option value="Grade 10">Grade 10</option>
                        <option value="Grade 11">Grade 11</option>
                        <option value="Grade 12">Grade 12</option>
                    </select>
                </div>
            </div>
        </div>
    );

    const renderStep2 = () => (
        <div className={styles.form}>
            <div className={styles.field}>
                <label>Rubric Criteria</label>
                <input className={styles.input} placeholder="e.g. Thesis Strength" />
            </div>
            <div className={styles.field}>
                <label>Max Points</label>
                <input className={styles.input} type="number" placeholder="e.g. 10" />
            </div>
            <div className={styles.rubricGrid}>
                <div className={styles.rubricLevel}>
                    <label style={{ color: '#0A8041' }}>Strong (Exceeds Expectations)</label>
                    <textarea className={styles.textarea} placeholder="Criteria for strong performance" />
                </div>
                <div className={styles.rubricLevel}>
                    <label style={{ color: '#FF9933' }}>Medium (Meets Expectations)</label>
                    <textarea className={styles.textarea} placeholder="Criteria for medium performance" />
                </div>
                <div className={styles.rubricLevel}>
                    <label style={{ color: '#EF4444' }}>Weak (Below Expectations)</label>
                    <textarea className={styles.textarea} placeholder="Criteria for weak performance" />
                </div>
            </div>
        </div>
    );

    const renderStep3 = () => (
        <div className={styles.form}>
            <div className={styles.field}>
                <label>Strong Thesis Example</label>
                <textarea className={styles.textarea} placeholder="Enter a high-quality example" />
            </div>
            <div className={styles.field}>
                <label>Why is it strong?</label>
                <textarea className={styles.textarea} placeholder="Explain the strengths" />
            </div>
            <div className={styles.field}>
                <label>Weak Thesis Example</label>
                <textarea className={styles.textarea} placeholder="Enter a low-quality example" />
            </div>
            <div className={styles.field}>
                <label>Why is it weak?</label>
                <textarea className={styles.textarea} placeholder="Explain the weaknesses" />
            </div>
        </div>
    );

    const getHeaderTitle = () => {
        if (step === 1) return "Create Assignment";
        if (step === 2) return `Rubric ${currentRubric} of ${rubricCount}`;
        return "Create Example";
    };

    const getHeaderSub = () => {
        if (step === 1) return "Complete the fields to set up your assignment";
        if (step === 2) return "Enter details for this grading criteria";
        return "Provide examples to guide students";
    };

    return (
        <div className={styles.overlay}>
            <div className={styles.modal}>
                <button className={styles.btnClose} onClick={onClose}><X size={24} /></button>

                <div className={styles.header}>
                    <h2>{getHeaderTitle()}</h2>
                    <p>{getHeaderSub()}</p>
                </div>

                {step === 1 && renderStep1()}
                {step === 2 && renderStep2()}
                {step === 3 && renderStep3()}

                <div className={styles.footer}>
                    <button className={styles.btnNext} onClick={handleNext}>
                        {step === 3 ? 'Create' : 'Next'}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default CreateAssignmentDialog;
