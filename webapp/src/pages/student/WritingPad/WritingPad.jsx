import React, { useState, useEffect } from 'react';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';
import { Book, Calendar, Clock, Layout, Pencil, Save, Play, CheckCircle2 } from 'lucide-react';
import WritingPadLeft from './WritingPadLeft';
import styles from './WritingPad.module.css';

const WritingPad = () => {
    const [content, setContent] = useState('');
    const [wordCount, setWordCount] = useState(0);
    const [zoom, setZoom] = useState(1);

    // Mock data
    const taskData = {
        title: "The Impact of Climate Change",
        prompt: "Write a 500-word essay discussing the primary causes and effects of climate change on global biodiversity.",
        dueDate: "March 15, 2026",
        dueTime: "11:59 PM PST",
        targetWords: 500,
        learnerName: "John Doe",
        className: "Environmental Science",
        gradeName: "Grade 12",
        taskType: "ASSIGNMENT",
        lastSaved: "2 minutes ago"
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
                                <span className={styles.savedTime}>{taskData.lastSaved}</span>
                            </div>

                            <button className={styles.btn}>
                                <Save size={16} />
                                <span>Save Draft</span>
                            </button>

                            <button className={styles.btn}>
                                <Play size={16} />
                                <span>Submit</span>
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
