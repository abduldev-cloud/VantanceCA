import React, { useState } from 'react';
import { ChevronDown } from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import Typography from '../../components/common/Typography';
import styles from './FAQPage.module.css';

const FAQPage = () => {
    const [openIndex, setOpenIndex] = useState(null);

    const faqs = [
        {
            question: "How do I submit my writing assignment?",
            answer: "Navigate to the 'Practices' or 'Papers' section, select your assignment, and open the Writing Pad. Once you've finished your work, click the 'Submit' button at the bottom right of the editor. You'll receive a confirmation modal once successful."
        },
        {
            question: "Can I edit my assignment after submission?",
            answer: "No, once an assignment is submitted, it is locked for grading. You can view your submitted content in read-only mode, but you cannot make further changes unless an instructor resets the submission for you."
        },
        {
            question: "What is Sage AI and how does it help me?",
            answer: "Sage AI is your personal writing assistant. It helps you brainstorm ideas, structure your thesis, and provides feedback on grammar and clarity. Note that Sage AI is a helper, and your final work should be original."
        },
        {
            question: "Where can I see my grades and feedback?",
            answer: "Go to the 'Result' section from the sidebar. Here you can see a list of all graded assignments. Click on an assignment to view detailed feedback, rubric scores, and specific comments from your educator."
        },
        {
            question: "How do I change my profile name or email?",
            answer: "For security reasons, profile details like name and email are managed by your institution. Please contact your school administrator if you need to update your personal information."
        }
    ];

    return (
        <MainLayout>
            <div className={styles.container}>
                <div className={styles.header}>
                    <Typography variant="displaySmall" weight="700">Help & FAQs</Typography>
                    <Typography variant="bodyMedium" color="#666">
                        Find answers to common questions about using VantanceCA.
                    </Typography>
                </div>

                <div className={styles.faqList}>
                    {faqs.map((faq, index) => (
                        <div key={index} className={styles.faqItem}>
                            <button
                                className={styles.question}
                                onClick={() => setOpenIndex(openIndex === index ? null : index)}
                            >
                                <span className={styles.questionTitle}>{faq.question}</span>
                                <ChevronDown className={`${styles.icon} ${openIndex === index ? styles.iconOpen : ''}`} size={20} />
                            </button>
                            {openIndex === index && (
                                <div className={styles.answer}>
                                    {faq.answer}
                                </div>
                            )}
                        </div>
                    ))}
                </div>
            </div>
        </MainLayout>
    );
};

export default FAQPage;
