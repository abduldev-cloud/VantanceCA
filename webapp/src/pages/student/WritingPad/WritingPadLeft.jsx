import React, { useState } from 'react';
import { Send, Lightbulb, Star, CheckCircle2, Search, HelpCircle } from 'lucide-react';
import SageLogo from '../../../assets/images/logo/elephantSmall.png';
import styles from './WritingPadLeft.module.css';

const WritingPadLeft = ({ learnerName, className, gradeName, taskType }) => {
    const [activeTab, setActiveTab] = useState(0); // 0: AI Helper, 1: Rubric, 2: Examples
    const [aiInput, setAiInput] = useState('');

    const getInitials = (name) => {
        return name ? name.charAt(0).toUpperCase() : '';
    };

    const tabs = [
        { id: 0, title: 'AI Helper' },
        { id: 1, title: 'Rubric' },
        { id: 2, title: 'Examples' }
    ];

    if (taskType === 'FINGERPRINT') {
        return (
            <div className={styles.sidebar}>
                <div className={styles.profileRow}>
                    <div className={styles.initialsCircle}>{getInitials(learnerName)}</div>
                    <div className={styles.profileInfo}>
                        <h3>{learnerName}'s Writing Pad</h3>
                        <p>{gradeName} - {className}</p>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className={styles.sidebar}>
            <div className={styles.profileRow}>
                <div className={styles.initialsCircle}>{getInitials(learnerName)}</div>
                <div className={styles.profileInfo}>
                    <h3>{learnerName}'s Writing Pad</h3>
                    <p>{gradeName}<br />{className}</p>
                </div>
            </div>

            <div className={styles.tabsContainer}>
                <div className={styles.tabHeader}>
                    {tabs.map((tab) => (
                        <div
                            key={tab.id}
                            className={`${styles.tab} ${activeTab === tab.id ? styles.activeTab : ''}`}
                            onClick={() => setActiveTab(tab.id)}
                        >
                            {tab.title}
                        </div>
                    ))}
                </div>

                <div className={styles.tabContent}>
                    {activeTab === 0 && (
                        <>
                            <div className={styles.aiHeader}>
                                <img src={SageLogo} alt="Sage AI" className={styles.aiIcon} />
                                <div className={styles.aiTitle}>
                                    <h4>Sage AI</h4>
                                    <p>0/5 prompts used</p>
                                </div>
                            </div>

                            <button className={styles.brainstormBtn}>
                                <Lightbulb size={20} color="#FFD700" />
                                <span>Help me brainstorm!</span>
                                <Star size={16} color="#CB6CE6" />
                            </button>

                            <div className={styles.chatList}>
                                <div className={`${styles.chatMessage} ${styles.ai}`}>
                                    Hello! How can I help you with your writing today?
                                </div>
                            </div>

                            <div className={styles.aiInputArea}>
                                <input
                                    type="text"
                                    placeholder="Type your message..."
                                    value={aiInput}
                                    onChange={(e) => setAiInput(e.target.value)}
                                />
                                <button className={styles.sendBtn}>
                                    <Send size={18} color="white" />
                                </button>
                            </div>
                        </>
                    )}

                    {activeTab === 1 && (
                        <div className={styles.chatList}>
                            <div className={styles.rubricCard}>
                                <div className={styles.rubricHeader}>
                                    <div className={styles.rubricTitle}>Argument Strength</div>
                                    <div className={styles.rubricPoints}>10 points</div>
                                </div>
                                <div className={styles.criteriaItem}>
                                    <CheckCircle2 className={styles.checkIcon} color="#0A8041" />
                                    <span>Clearly states a position with strong supporting evidence.</span>
                                </div>
                            </div>
                        </div>
                    )}

                    {activeTab === 2 && (
                        <div className={styles.chatList}>
                            <div className={styles.exampleHeader}>
                                <div className={styles.exampleIconBox}>
                                    <Search size={22} color="white" />
                                </div>
                                <div className={styles.aiTitle}>
                                    <h4>Examples</h4>
                                    <p>Writing samples to guide you</p>
                                </div>
                            </div>
                            <div className={styles.exampleCard}>
                                <div className={`${styles.exampleTitle} ${styles.strongThesis}`}>Strong Thesis</div>
                                <div className={styles.exampleText}>"Climate change represents the single greatest threat to global biodiversity."</div>
                                <div className={`${styles.exampleTitle} ${styles.strongThesis}`}>Why It's Strong:</div>
                                <div className={styles.exampleText}>It is specific, arguable, and clearly states a position.</div>
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

export default WritingPadLeft;
