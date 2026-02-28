import React, { useState, useEffect } from 'react';
import {
    Plus,
    FileText,
    Video,
    Link as LinkIcon,
    MoreVertical,
    Download,
    ExternalLink,
    Search,
    Filter,
    Layers
} from 'lucide-react';
import MainLayout from '../../components/layout/MainLayout';
import TitleBar from '../../components/layout/TitleBar';
import Typography from '../../components/common/Typography';
import CreateMaterialDialog from './CreateMaterialDialog';
import teacherService from '../../services/teacherService';
import styles from './StudyMaterial.module.css';

const StudyMaterialPage = () => {
    const [materials, setMaterials] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [isAddModalOpen, setIsAddModalOpen] = useState(false);

    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    const teacherId = userData.role_entity_id;

    useEffect(() => {
        fetchMaterials();
    }, [teacherId]);

    const fetchMaterials = async () => {
        setIsLoading(true);
        try {
            const response = await teacherService.getStudyMaterials({ teacher_id: teacherId });
            if (response.success) {
                setMaterials(response.data || []);
            }
        } catch (err) {
            console.error('Error:', err);
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
        m.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (m.grade_name && m.grade_name.toLowerCase().includes(searchTerm.toLowerCase()))
    );

    const handleViewPDF = (material) => {
        setViewingMaterial(material);
    };

    const getFullUrl = (url) => {
        if (!url) return '';
        if (url.startsWith('http')) return url;
        return `http://localhost:8000${url}`;
    };

    return (
        <MainLayout>
            <TitleBar
                title="Study Material"
                subTitle="Upload and manage resources for your students"
                buttonTitle="Add Material"
                onTap={() => setIsAddModalOpen(true)}
            />

            <div className={styles.container}>
                <div className={styles.controls}>
                    <div className={styles.searchWrapper}>
                        <Search className={styles.searchIcon} size={18} />
                        <input
                            type="text"
                            className={styles.searchInput}
                            placeholder="Search by title, topic or category..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                </div>

                {isLoading ? (
                    <div className={styles.loading}>Loading materials...</div>
                ) : filteredMaterials.length === 0 ? (
                    <div className={styles.emptyState}>
                        <Layers size={48} color="#D1D5DB" />
                        <Typography variant="titleLarge">No study materials found</Typography>
                        <p>Click "Add Material" to upload your first resource.</p>
                    </div>
                ) : (
                    <div className={styles.grid}>
                        {filteredMaterials.map((material) => (
                            <div key={material.material_id} className={styles.card}>
                                <div className={styles.cardHeader}>
                                    <div className={styles.typeIcon}>
                                        {getTypeIcon(material.material_type)}
                                    </div>
                                    <button className={styles.moreBtn}>
                                        <MoreVertical size={18} />
                                    </button>
                                </div>
                                <div className={styles.cardBody}>
                                    <h3 className={styles.materialTitle}>{material.title}</h3>
                                    <p className={styles.materialDesc}>{material.description}</p>
                                    <div className={styles.meta}>
                                        <span className={styles.gradeTag}>{material.grade_name}</span>
                                        <span className={styles.date}>{new Date(material.created_at).toLocaleDateString()}</span>
                                    </div>
                                </div>
                                <div className={styles.cardFooter}>
                                    {material.material_type === 'PDF' ? (
                                        <button
                                            onClick={() => handleViewPDF(material)}
                                            className={styles.actionBtn}
                                            style={{ background: '#004AAD', color: 'white', border: 'none', width: '100%', cursor: 'pointer' }}
                                        >
                                            <FileText size={16} /> Preview PDF
                                        </button>
                                    ) : material.material_type === 'LINK' || material.material_type === 'VIDEO' ? (
                                        <a href={material.external_link} target="_blank" rel="noopener noreferrer" className={styles.actionBtn}>
                                            <ExternalLink size={16} /> Open Link
                                        </a>
                                    ) : (
                                        <a href={getFullUrl(material.file_url)} target="_blank" rel="noopener noreferrer" download className={styles.actionBtn}>
                                            <Download size={16} /> Download
                                        </a>
                                    )}
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>

            {/* PDF Preview Modal */}
            {viewingMaterial && (
                <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.8)', zIndex: 1100, display: 'flex', flexDirection: 'column', padding: '20px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px', color: 'white' }}>
                        <h3 style={{ margin: 0 }}>{viewingMaterial.title} - Preview</h3>
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

            <CreateMaterialDialog
                isOpen={isAddModalOpen}
                onClose={() => setIsAddModalOpen(false)}
                onCreated={fetchMaterials}
            />
        </MainLayout>
    );
};

export default StudyMaterialPage;
