import React, { createContext, useContext, useState, useEffect } from 'react';
import api from '../services/api';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const checkAuth = async () => {
            const token = localStorage.getItem('admin_token');
            if (token) {
                api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
                try {
                    const res = await api.get('/api/auth/me');
                    if (res.data.success && res.data.user.role === 'admin') {
                        setUser(res.data.user);
                    } else {
                        localStorage.removeItem('admin_token');
                        delete api.defaults.headers.common['Authorization'];
                    }
                } catch (err) {
                    localStorage.removeItem('admin_token');
                    delete api.defaults.headers.common['Authorization'];
                }
            }
            setLoading(false);
        };
        checkAuth();
    }, []);

    const login = async (email, password) => {
        const res = await api.post('/api/auth/login', { email, password });
        if (res.data.success) {
            if (res.data.user.role !== 'admin') {
                throw new Error('Access denied. Admin role required.');
            }
            localStorage.setItem('admin_token', res.data.token);
            api.defaults.headers.common['Authorization'] = `Bearer ${res.data.token}`;
            setUser(res.data.user);
            return res.data.user;
        }
        throw new Error(res.data.message || 'Login failed');
    };

    const logout = () => {
        localStorage.removeItem('admin_token');
        delete axios.defaults.headers.common['Authorization'];
        setUser(null);
    };

    return (
        <AuthContext.Provider value={{ user, login, logout, isLoading: loading }}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => useContext(AuthContext);
