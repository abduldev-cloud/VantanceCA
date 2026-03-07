import React, { useState, useEffect } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';
import { Book, Calendar, Clock, Layout, Pencil, Save, Play, CheckCircle2 } from 'lucide-react';
import WritingPadLeft from './WritingPadLeft';
import studentService from '../../../services/studentService';
import styles from './WritingPad.module.css';

const WritingPad = () => {
    const [searchParams] = useSearchParams();
    const navigate = useNavigate();
    const taskId = searchParams.get('id');

    const [content, setContent] = useState('');
    const [wordCount, setWordCount] = useState(0);
    const [zoom, setZoom] = useState(1);
    const [taskData, setTaskData] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [lastSavedTime, setLastSavedTime] = useState('Not saved yet');

    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    const learnerId = userData.role_entity_id;

    useEffect(() => {
        const fetchTask = async () => {
            if (!taskId) {
                setIsLoading(false);
                return;
            }
            try {
                const response = await studentService.getAssignmentDetails(taskId, learnerId);
                if (response.success) {
                    const data = response.data;
                    setTaskData({
                        id: data.task_id,
                        learnerTaskId: data.learner_task_id,
                        title: data.task_title,
                        prompt: data.task_description,
                        dueDate: data.due_date ? new Date(data.due_date).toLocaleDateString() : 'No due date',
                        dueTime: data.due_date ? new Date(data.due_date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '',
                        targetWords: 500,
                        learnerName: `${userData.first_name || ''} ${userData.last_name || ''}`.trim() || 'Student',
                        className: data.class_name,
                        gradeName: data.grade_name || 'N/A',
                        taskType: data.task_type || 'ASSIGNMENT',
                    });
                    // Load previously saved content if any
                    if (data.submission_text) {
                        setContent(data.submission_text);
                    }
                }
            } catch (err) {
                console.error('Error fetching task:', err);
            } finally {
                setIsLoading(false);
            }
        };
        fetchTask();
    }, [taskId, learnerId]);

    const handleSubmit = async () => {
        if (!taskData?.learnerTaskId) return;

        setIsSubmitting(true);
        try {
            await studentService.submitAssignment(taskData.learnerTaskId, content, wordCount);
            alert('Assignment submitted successfully!');
            navigate('/student/assignment');
        } catch (err) {
            console.error('Error submitting:', err);
            alert('Failed to submit assignment.');
        } finally {
            setIsSubmitting(false);
        }
    };

    const calculateWordCount = (html) => {
        const text = html.replace(/<[^>]*>/g, ' ');
        const words = text.trim().split(/\s+/).filter(word => word.length > 0);
        return words.length;
    };

    useEffect(() => {
        setWordCount(calculateWordCount(content));
    }, [content]);

    const modules = {
        toolbar: [
            [{ 'header': [1, 2, false] }],
            ['bold', 'italic', 'underline', 'strike', 'blockquote'],
            [{ 'list': 'ordered' }, { 'list': 'bullet' }, { 'indent': '-1' }, { 'indent': '+1' }],
            ['link', 'image'],
            ['clean']
        ],
    };

    if (isLoading) return <div className={styles.page}>Loading task...</div>;
    if (!taskData) return <div className={styles.page}>Task not found</div>;

    return (
        <div className={styles.page}>
            <WritingPadLeft
                learnerName={taskData.learnerName}
                className={taskData.className}
                gradeName={taskData.gradeName}
                taskType={taskData.taskType}
            />

            <div className={styles.mainContent}>
                <div className={styles.instructionsArea}>
                    <div className={styles.instrHeader}>
                        <div className={styles.instrIconBox}>
                            <Book size={20} color="white" />
                        </div>
                        <span className={styles.instrTitle}>Assignment Instructions</span>
                    </div>

                    <div className={styles.instrCard}>
                        <div className={styles.instrScroll}>
                            {taskData.prompt}
                        </div>
                    </div>

                    <div className={styles.metaRow}>
                        <div className={styles.metaItem}>
                            <Calendar size={24} color="#004AAD" />
                            <div>
                                <div className={styles.metaLabel}>Due <span className={styles.metaText}>{taskData.dueDate}</span></div>
                                <div className={styles.metaLabel}>at <span className={styles.metaText}>{taskData.dueTime}</span></div>
                            </div>
                        </div>

                        <div className={styles.metaItem}>
                            <Clock size={24} color="#004AAD" />
                            <div>
                                <div className={styles.metaText}>12:05:01</div>
                                <div className={styles.metaLabel}>to finish</div>
                            </div>
                        </div>

                        <div className={styles.metaItem}>
                            <Layout size={24} color="#004AAD" />
                            <div>
                                <span className={styles.metaText}>Target:</span>
                                <span className={styles.metaLabel}> {taskData.targetWords} words</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div className={styles.editorWrapper}>
                    <div className={styles.statsBar}>
                        <div className={styles.wordCountBox}>
                            <div className={styles.wordCountText}>{wordCount} Words</div>
                            <div className={styles.progressBarRow}>
                                <span className={styles.progressBarLabel}>0</span>
                                <div className={styles.progressBar}>
                                    <div
                                        className={styles.progressFill}
                                        style={{ width: `${Math.min((wordCount / taskData.targetWords) * 100, 100)}%` }}
                                    ></div>
                                </div>
                                <span className={styles.progressBarLabel}>{taskData.targetWords}</span>
                            </div>
                        </div>
                    </div>

                    <div className={styles.bottomControls}>
                        <div className={styles.taskTitleBox}>
                            <div className={styles.pencilIconBox}>
                                <Pencil size={18} color="white" />
                            </div>
                            <span className={styles.actualTaskTitle}>{taskData.title}</span>
                        </div>

                        <div className={styles.actionButtons}>
                            <div className={styles.savedIndicator}>
                                <CheckCircle2 size={20} color="black" />
                                <span className={styles.savedText}>Saved </span>
                                <span className={styles.savedTime}>{lastSavedTime}</span>
                            </div>

                            <button className={styles.btn}>
                                <Save size={16} />
                                <span>Save Draft</span>
                            </button>

                            <button
                                className={styles.btn}
                                onClick={handleSubmit}
                                disabled={isSubmitting}
                            >
                                <Play size={16} />
                                <span>{isSubmitting ? 'Submitting...' : 'Submit'}</span>
                            </button>
                        </div>
                    </div>

                    <div className={styles.editorContainer} style={{ transform: `scale(${zoom})`, transformOrigin: 'top center' }}>
                        <ReactQuill
                            theme="snow"
                            value={content}
                            onChange={setContent}
                            modules={modules}
                            placeholder="Enter..."
                        />
                    </div>
                </div>
            </div>
        </div>
    );
};

export default WritingPad;
