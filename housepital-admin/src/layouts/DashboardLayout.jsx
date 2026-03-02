import React, { useState, useEffect } from 'react';
import Sidebar from '../components/Sidebar';
import { Bell } from 'lucide-react';
import api from '../services/api';

const DashboardLayout = ({ children }) => {
    const [notifications, setNotifications] = useState(0);

    useEffect(() => {
        const checkNotifications = async () => {
            try {
                // Determine if there are "unread" logs. 
                // For simplicity, we just fetch count of logs from last 24h or similar, 
                // or just random for demo if no read-state exists.
                // Better approach: Get latest log timestamp from localStorage, compare with API.
                const lastCheck = localStorage.getItem('lastNotificationCheck') || new Date().toISOString();
                const response = await api.get('/api/admin/insights/logs?limit=5');
                
                if (response.data.success && response.data.logs.length > 0) {
                    const newLogs = response.data.logs.filter(log => new Date(log.timestamp) > new Date(lastCheck));
                    if (newLogs.length > 0) {
                         setNotifications(newLogs.length);
                    }
                }
            } catch (err) {
                console.error("Notification check failed", err);
            }
        };
        
        // Initial check
        checkNotifications();

        // Poll every 30s
        const interval = setInterval(checkNotifications, 30000);
        return () => clearInterval(interval);
    }, []);

    const clearNotifications = () => {
        setNotifications(0);
        localStorage.setItem('lastNotificationCheck', new Date().toISOString());
    };

    return (
        <div className="flex bg-slate-50 min-h-screen">
            <Sidebar />
            <main className="flex-1 ml-64 p-8">
                <header className="mb-8 flex justify-between items-center">
                    <div>
                        <h2 className="text-3xl font-bold text-slate-900 tracking-tight">System Control Center</h2>
                        <p className="text-slate-500 text-sm mt-1 font-medium">Real-time health informatics and patient management analytics.</p>
                    </div>
                    <div className="flex gap-4 items-center">
                        <button 
                            onClick={clearNotifications}
                            className="relative p-2.5 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 transition-colors shadow-sm"
                        >
                            <Bell size={20} className="text-slate-600" />
                            {notifications > 0 && (
                                <span className="absolute -top-1 -right-1 flex h-4 w-4">
                                    <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                                    <span className="relative inline-flex rounded-full h-4 w-4 bg-red-500 text-[10px] text-white font-bold items-center justify-center">
                                        {notifications}
                                    </span>
                                </span>
                            )}
                        </button>
                        <div className="bg-white px-4 py-2.5 rounded-xl border border-slate-200 shadow-sm flex items-center gap-2.5 hover:shadow-md transition-shadow">
                            <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse shadow-lg shadow-green-500/50"></span>
                            <span className="text-sm font-semibold text-slate-700">Health System Live</span>
                        </div>
                    </div>
                </header>
                <div className="max-w-7xl mx-auto">
                    {children}
                </div>
            </main>
        </div>
    );
};

export default DashboardLayout;
