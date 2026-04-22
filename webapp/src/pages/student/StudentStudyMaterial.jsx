import React, { useState, useEffect } from 'react';
import {
    FileText,
    Video,
    Link as LinkIcon,
    Download,
    ExternalLink,
    Search,
    BookOpen
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import Typography from '../../components/common/Typography';
import teacherService from '../../services/teacherService';
import styles from '../teacher/StudyMaterial.module.css'; // Corrected path to reuse teacher styles

const StudentStudyMaterialPage = () => {
    const [materials, setMaterials] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');

    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    const gradeLevelId = userData.grade_level_id;

    useEffect(() => {
        fetchMaterials();
    }, [gradeLevelId]);

    const fetchMaterials = async () => {
        setIsLoading(true);
        try {
            const response = await teacherService.getStudyMaterials({ grade_level_id: gradeLevelId });
            if (response.success) {
                setMaterials(response.data || []);
            }
        } catch (err) {
            console.error('Error fetching materials:', err);
        } finally {
            setIsLoading(false);
        }
    };

    const getTypeIcon = (type) => {
        switch (type) {
            case 'PDF': return <FileText size={24} color="#E02424" />;
            case 'VIDEO': return <Video size={24} color="#004AAD" />;
            case 'LINK': return <LinkIcon size={24} color="#057A55" />;
            default: return <FileText size={24} color="#6B7280" />;
        }
    };

    const [viewingMaterial, setViewingMaterial] = useState(null);

    const filteredMaterials = materials.filter(m =>
        m.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        m.description.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const handleViewPDF = (material) => {
        setViewingMaterial(material);
    };

    const getFullUrl = (url) => {
        if (!url) return '';
        if (url.startsWith('http')) return url;
        return `${import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000'}${url}`;
    };

    return (
        <MainLayout>
            <TitleBar
                title="Study Resources"
                subTitle="Explore notes, videos and resources for your exams"
            />

            <div className={styles.container}>
                <div className={styles.controls}>
                    <div className={styles.searchWrapper}>
                        <Search className={styles.searchIcon} size={18} />
                        <input
                            type="text"
                            className={styles.searchInput}
                            placeholder="Find study material..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                </div>

                {isLoading ? (
                    <div className={styles.loading}>Loading your resources...</div>
                ) : filteredMaterials.length === 0 ? (
                    <div className={styles.emptyState}>
                        <BookOpen size={48} color="#D1D5DB" />
                        <Typography variant="titleLarge">No resources available</Typography>
                        <p>Your teacher hasn't shared any study material yet.</p>
                    </div>
                ) : (
                    <div className={styles.grid}>
                        {filteredMaterials.map((material) => (
                            <div key={material.material_id} className={styles.card}>
                                <div className={styles.cardHeader}>
                                    <div className={styles.typeIcon}>
                                        {getTypeIcon(material.material_type)}
                                    </div>
                                    <span style={{ fontSize: '11px', color: '#6B7280', fontWeight: '500' }}>
                                        {material.material_type}
                                    </span>
                                </div>
                                <div className={styles.cardBody}>
                                    <h3 className={styles.materialTitle}>{material.title}</h3>
                                    <p className={styles.materialDesc}>{material.description}</p>
                                    <div className={styles.meta}>
                                        <span className={styles.gradeTag}>{material.grade_name}</span>
                                        <span style={{ fontSize: '12px', color: '#4B5563' }}>By {material.first_name}</span>
                                    </div>
                                </div>
                                <div className={styles.cardFooter}>
                                    {material.material_type === 'PDF' ? (
                                        <button
                                            onClick={() => handleViewPDF(material)}
                                            className={styles.actionBtn}
                                            style={{ background: '#004AAD', color: 'white', border: 'none', width: '100%', cursor: 'pointer' }}
                                        >
                                            <FileText size={16} /> View PDF Document
                                        </button>
                                    ) : (
                                        <a href={material.external_link} target="_blank" rel="noopener noreferrer" className={styles.actionBtn}>
                                            <ExternalLink size={16} /> Open Resource
                                        </a>
                                    )}
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>

            {/* PDF Viewer Modal */}
            {viewingMaterial && (
                <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.8)', zIndex: 1100, display: 'flex', flexDirection: 'column', padding: '20px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px', color: 'white' }}>
                        <h3 style={{ margin: 0 }}>{viewingMaterial.title}</h3>
                        <button
                            onClick={() => setViewingMaterial(null)}
                            style={{ background: 'white', border: 'none', borderRadius: '50%', width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}
                        >
                            <span style={{ fontSize: '20px', fontWeight: 'bold' }}>&times;</span>
                        </button>
                    </div>
                    <div style={{ flex: 1, background: 'white', borderRadius: '12px', overflow: 'hidden' }}>
                        <iframe
                            src={getFullUrl(viewingMaterial.file_url)}
                            title={viewingMaterial.title}
                            style={{ width: '100%', height: '100%', border: 'none' }}
                        />
                    </div>
                </div>
            )}
        </MainLayout>
    );
};

export default StudentStudyMaterialPage;
