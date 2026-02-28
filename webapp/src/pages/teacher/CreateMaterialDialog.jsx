import React, { useState, useEffect } from 'react';
import { X, Upload, Link, FileText, Video as VideoIcon } from 'lucide-react';
import teacherService from '../../services/teacherService';
import styles from './StudyMaterial.module.css';

const CreateMaterialDialog = ({ isOpen, onClose, onCreated }) => {
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [type, setType] = useState('PDF');
    const [externalLink, setExternalLink] = useState('');
    const [gradeLevelId, setGradeLevelId] = useState('');
    const [gradeLevels, setGradeLevels] = useState([]);
    const [selectedFile, setSelectedFile] = useState(null);
    const [isSaving, setIsSaving] = useState(false);

    useEffect(() => {
        if (isOpen) {
            fetchGrades();
        }
    }, [isOpen]);

    const fetchGrades = async () => {
        try {
            const response = await teacherService.getGradeLevels();
            if (response.success) setGradeLevels(response.data || []);
        } catch (err) {
            console.error(err);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setIsSaving(true);
        const userData = JSON.parse(localStorage.getItem('userData') || '{}');
        const teacherId = userData.role_entity_id;

        try {
            let finalFileUrl = '';
            let finalExternalLink = '';

            if (type === 'PDF' && selectedFile) {
                const uploadRes = await teacherService.uploadStudyMaterial(selectedFile);
                if (uploadRes.success) {
                    finalFileUrl = uploadRes.file_url;
                } else {
                    throw new Error('Upload failed');
                }
            } else {
                finalExternalLink = externalLink;
            }

            const res = await teacherService.createStudyMaterial({
                title,
                description,
                material_type: type,
                file_url: finalFileUrl,
                external_link: finalExternalLink,
                teacher_id: teacherId,
                grade_level_id: gradeLevelId,
            });
            if (res.success) {
                onCreated();
                onClose();
            }
        } catch (err) {
            alert('Failed to create material: ' + err.message);
        } finally {
            setIsSaving(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000, backdropFilter: 'blur(4px)' }}>
            <div style={{ background: 'white', width: '500px', borderRadius: '20px', padding: '32px', position: 'relative' }}>
                <button onClick={onClose} style={{ position: 'absolute', top: '24px', right: '24px', background: 'none', border: 'none', cursor: 'pointer', color: '#6B7280' }}><X /></button>
                <h2 style={{ fontSize: '24px', fontWeight: '700', margin: '0 0 8px' }}>Add Study Material</h2>
                <p style={{ color: '#6B7280', fontSize: '14px', margin: '0 0 24px' }}>Share resources like PDFs, Videos or Links with your students.</p>

                <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                    <div>
                        <label style={{ display: 'block', fontSize: '14px', fontWeight: '600', marginBottom: '8px' }}>Title</label>
                        <input required value={title} onChange={e => setTitle(e.target.value)} style={{ width: '100%', padding: '12px', borderRadius: '10px', border: '1px solid #E5E7EB', outline: 'none' }} placeholder="Introduction to Taxation" />
                    </div>

                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                        <div>
                            <label style={{ display: 'block', fontSize: '14px', fontWeight: '600', marginBottom: '8px' }}>Resource Type</label>
                            <select value={type} onChange={e => setType(e.target.value)} style={{ width: '100%', padding: '12px', borderRadius: '10px', border: '1px solid #E5E7EB', outline: 'none' }}>
                                <option value="PDF">PDF Document</option>
                                <option value="VIDEO">Video Link</option>
                                <option value="LINK">External Link</option>
                            </select>
                        </div>
                        <div>
                            <label style={{ display: 'block', fontSize: '14px', fontWeight: '600', marginBottom: '8px' }}>Grade Level</label>
                            <select required value={gradeLevelId} onChange={e => setGradeLevelId(e.target.value)} style={{ width: '100%', padding: '12px', borderRadius: '10px', border: '1px solid #E5E7EB', outline: 'none' }}>
                                <option value="">Select Grade</option>
                                {gradeLevels.map(gl => <option key={gl.grade_level_id} value={gl.grade_level_id}>{gl.grade_name}</option>)}
                            </select>
                        </div>
                    </div>

                    <div>
                        <label style={{ display: 'block', fontSize: '14px', fontWeight: '600', marginBottom: '8px' }}>
                            {type === 'PDF' ? 'Upload PDF Document' : 'Resource Link'}
                        </label>
                        {type === 'PDF' ? (
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                                <div style={{ border: '2px dashed #E5E7EB', borderRadius: '12px', padding: '20px', textAlign: 'center', cursor: 'pointer', position: 'relative' }}>
                                    <input
                                        type="file"
                                        accept=".pdf"
                                        onChange={e => setSelectedFile(e.target.files[0])}
                                        style={{ position: 'absolute', inset: 0, opacity: 0, cursor: 'pointer' }}
                                    />
                                    <Upload size={24} color="#6B7280" style={{ marginBottom: '8px' }} />
                                    <p style={{ fontSize: '14px', color: '#6B7280', margin: 0 }}>
                                        {selectedFile ? selectedFile.name : 'Click or drag to upload PDF'}
                                    </p>
                                </div>
                                <p style={{ fontSize: '12px', color: '#6B7280' }}>Only .pdf files are supported.</p>
                            </div>
                        ) : (
                            <input
                                required
                                value={externalLink}
                                onChange={e => setExternalLink(e.target.value)}
                                style={{ width: '100%', padding: '12px', borderRadius: '10px', border: '1px solid #E5E7EB', outline: 'none' }}
                                placeholder={type === 'VIDEO' ? 'YouTube or Video link' : 'https://...'}
                            />
                        )}
                    </div>

                    <div>
                        <label style={{ display: 'block', fontSize: '14px', fontWeight: '600', marginBottom: '8px' }}>Description</label>
                        <textarea value={description} onChange={e => setDescription(e.target.value)} style={{ width: '100%', padding: '12px', borderRadius: '10px', border: '1px solid #E5E7EB', outline: 'none', height: '80px' }} placeholder="Brief overview of the material" />
                    </div>

                    <button
                        disabled={isSaving || (type === 'PDF' && !selectedFile)}
                        type="submit"
                        style={{
                            background: (isSaving || (type === 'PDF' && !selectedFile)) ? '#9CA3AF' : '#004AAD',
                            color: 'white',
                            border: 'none',
                            padding: '14px',
                            borderRadius: '12px',
                            fontWeight: '600',
                            cursor: (isSaving || (type === 'PDF' && !selectedFile)) ? 'not-allowed' : 'pointer',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            gap: '8px',
                            transition: 'all 0.2s'
                        }}
                    >
                        {isSaving ? 'Creating...' : 'Share Material'}
                    </button>
                </form>
            </div>
        </div>
    );
};

export default CreateMaterialDialog;
