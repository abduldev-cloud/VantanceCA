import React, { createContext, useContext, useState, useEffect } from 'react';

const RoleContext = createContext();

export const RoleProvider = ({ children }) => {
    const [role, setRole] = useState(localStorage.getItem('userRole') || 'teacher'); // Default to teacher for now or guest

    const isTeacher = role?.toUpperCase() === 'TEACHER';
    const isStudent = role?.toUpperCase() === 'LEARNER';
    const isInstituteAdmin = role?.toUpperCase() === 'INSTITUTE_ADMIN';
    const isPlatformAdmin = role?.toUpperCase() === 'ADMIN';

    return (
        <RoleContext.Provider value={{ role, setRole, isTeacher, isStudent, isInstituteAdmin, isPlatformAdmin }}>
            {children}
        </RoleContext.Provider>
    );
};

export const useRole = () => useContext(RoleContext);
