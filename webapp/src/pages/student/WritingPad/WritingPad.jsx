import React, { useState, useEffect } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';
import { Book, Calendar, Clock, Layout, Pencil, Save, Play, CheckCircle2, MessageSquare, Send, X } from 'lucide-react';
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
    const [error, setError] = useState(null);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [lastSavedTime, setLastSavedTime] = useState('Not saved yet');
    const [isChatOpen, setIsChatOpen] = useState(false);
    const [chatMessages, setChatMessages] = useState([]);
    const [chatInput, setChatInput] = useState('');
    const [isAITyping, setIsAITyping] = useState(false);

    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    const learnerId = userData.role_entity_id;

    useEffect(() => {
        const fetchTask = async () => {
            if (!taskId) {
                setIsLoading(false);
                setError('Task ID is missing in the URL.');
                return;
            }

            if (!learnerId) {
                console.warn('No burner ID found in userData');
                // Fallback to check if we can get it from user_id if needed, but role_entity_id is standard now
                setIsLoading(false);
                setError('Learner session not found. Please log in again.');
                return;
            }

            try {
                const response = await studentService.getAssignmentDetails(taskId, learnerId);
                if (response.success && response.data) {
                    const data = response.data;

                    if (!data.learner_task_id) {
                        setError('Assignment record not found for this student. Ensure you are enrolled in this class.');
                        setTaskData(null);
                        return;
                    }

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
                } else {
                    setError('Failed to load assignment details.');
                }
            } catch (err) {
                console.error('Error fetching task:', err);
                setError('An error occurred while loading the task.');
            } finally {
                setIsLoading(false);
            }
        };
        fetchTask();
    }, [taskId, learnerId]);

    const handleSubmit = async () => {
        if (!taskData?.learnerTaskId) {
            alert('Unable to submit: Student assignment record not found. Please contact your teacher.');
            return;
        }

        setIsSubmitting(true);
        try {
            const res = await studentService.submitAssignment(taskData.learnerTaskId, content, wordCount);
            if (res.success) {
                alert('Assignment submitted successfully!');
                navigate('/student/assignment');
            } else {
                alert(res.message || 'Failed to submit assignment.');
            }
        } catch (err) {
            console.error('Error submitting:', err);
            alert('Failed to submit assignment. Please try again.');
        } finally {
            setIsSubmitting(false);
        }
    };

    const handleSaveDraft = async (silent = false) => {
        if (!taskData?.learnerTaskId) return;

        try {
            const res = await studentService.saveAssignmentDraft(taskData.learnerTaskId, content);
            if (res.success) {
                const now = new Date();
                setLastSavedTime(now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }));
                if (!silent) alert('Draft saved successfully!');
            }
        } catch (err) {
            console.error('Error saving draft:', err);
            if (!silent) alert('Failed to save draft.');
        }
    };

    // Auto-save every 30 seconds
    useEffect(() => {
        const timer = setInterval(() => {
            if (content && content.length > 50) { // Only auto-save if there's significant content
                handleSaveDraft(true);
            }
        }, 30000);
        return () => clearInterval(timer);
    }, [content, taskData?.learnerTaskId]);

    const calculateWordCount = (html) => {
        const text = html.replace(/<[^>]*>/g, ' ');
        const words = text.trim().split(/\s+/).filter(word => word.length > 0);
        return words.length;
    };

    useEffect(() => {
        setWordCount(calculateWordCount(content));
    }, [content]);

    useEffect(() => {
        if (isChatOpen && taskData?.learnerTaskId) {
            const fetchChatHistory = async () => {
                try {
                    const res = await studentService.getChatHistory(taskData.learnerTaskId);
                    if (res.success) {
                        setChatMessages(res.data || []);
                    }
                } catch (err) {
                    console.error('Error fetching chat:', err);
                }
            };
            fetchChatHistory();
        }
    }, [isChatOpen, taskData?.learnerTaskId]);

    const handleSendMessage = async () => {
        if (!chatInput.trim() || !taskData?.learnerTaskId) {
            console.warn('Chat send blocked: missing input or task ID', { input: chatInput, taskData });
            return;
        }

        const userMsg = chatInput;
        setChatInput('');
        setIsAITyping(true);
        // alert('Sending message to: ' + taskData.learnerTaskId);

        try {
            console.log('Sending chat message to:', taskData.learnerTaskId);
            const res = await studentService.sendChatMessage(taskData.learnerTaskId, userMsg);
            console.log('Chat response:', res);

            if (res && res.success) {
                setChatMessages(prev => [...prev,
                { sender: 'STUDENT', message_content: userMsg },
                { sender: 'AI', message_content: res.ai_response.content }
                ]);
            } else {
                console.error('Chat error:', res);
                alert('Failed to send message: ' + (res?.message || 'Server error'));
            }
        } catch (err) {
            console.error('Error sending chat:', err);
            alert('Failed to connect to AI assistant. Please check your internet connection.');
        } finally {
            setIsAITyping(false);
        }
    };

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
    if (error) return (
        <div className={styles.page} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: '20px' }}>
            <div style={{ fontSize: '18px', color: '#EF4444' }}>{error}</div>
            <button
                onClick={() => navigate(-1)}
                style={{ padding: '10px 20px', background: '#004AAD', color: 'white', border: 'none', borderRadius: '8px', cursor: 'pointer' }}
            >
                Go Back
            </button>
        </div>
    );
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

                            <button
                                className={styles.btn}
                                onClick={() => handleSaveDraft()}
                                disabled={isSubmitting}
                            >
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

            {/* AI Chat Widget */}
            <div className={styles.aiChatFloating}>
                {!isChatOpen ? (
                    <button className={styles.chatToggle} onClick={() => setIsChatOpen(true)}>
                        <MessageSquare size={28} />
                    </button>
                ) : (
                    <div className={styles.chatWindow}>
                        <div className={styles.chatHeader}>
                            <h3>AI Assistant</h3>
                            <button className={styles.close_btn} onClick={() => setIsChatOpen(false)}>
                                <X size={20} />
                            </button>
                        </div>
                        <div className={styles.chatMessages}>
                            {chatMessages.length === 0 ? (
                                <div style={{ fontSize: '13px', color: '#6B7280', textAlign: 'center', marginTop: '50px' }}>
                                    How can I help you with your writing today?
                                </div>
                            ) : (
                                chatMessages.map((msg, i) => (
                                    <div key={i} className={`${styles.message} ${msg.sender === 'STUDENT' ? styles.studentMsg : styles.aiMsg}`}>
                                        {msg.message_content}
                                    </div>
                                ))
                            )}
                            {isAITyping && <div className={styles.typing}>AI is thinking...</div>}
                        </div>
                        <div className={styles.chatInputArea}>
                            <input
                                type="text"
                                className={styles.chatInput}
                                placeholder="Ask a question..."
                                value={chatInput}
                                onChange={(e) => setChatInput(e.target.value)}
                                onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
                                disabled={isAITyping}
                            />
                            <button
                                className={styles.send_btn}
                                onClick={handleSendMessage}
                                disabled={!chatInput.trim() || isAITyping}
                            >
                                <Send size={18} />
                            </button>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
};

export default WritingPad;
