import React, { useState, useEffect } from 'react';
import api from '../services/api';
import {
    FileText,
    History,
    CheckCircle2,
    XCircle,
    User,
    ArrowRight,
    ShieldAlert,
    Calendar
} from 'lucide-react';

const Activity = () => {
    const [logs, setLogs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [stats, setStats] = useState({ total: 0, approvals: 0, alerts: 0 });

    useEffect(() => {
        fetchLogs();
    }, []);

    const fetchLogs = async () => {
        try {
            setLoading(true);
            const response = await api.get(`/api/admin/insights/logs`);
            if (response.data.success) {
                setLogs(response.data.logs);
                // Calculate basic stats for display
                const approvals = response.data.logs.filter(l => l.action.includes('APPROVE')).length;
                const alerts = response.data.logs.filter(l => l.action.includes('REJECT')).length;
                setStats({ total: response.data.total, approvals, alerts });
            }
        } catch (error) {
            console.error('Error fetching logs:', error);
        } finally {
            setLoading(false);
        }
    };

    const getActionIcon = (action) => {
        if (action.includes('APPROVE')) return <CheckCircle2 className="text-green-500" size={20} />;
        if (action.includes('REJECT')) return <XCircle className="text-red-500" size={20} />;
        if (action.includes('REGISTER')) return <User className="text-blue-500" size={20} />;
        return <ShieldAlert className="text-orange-500" size={20} />;
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 tracking-tight">System Audit Logs</h1>
                    <p className="text-slate-500 text-sm mt-1">Global activity monitoring for security and compliance.</p>
                </div>
                <button
                    onClick={fetchLogs}
                    className="p-2 bg-white border rounded-xl hover:bg-slate-50 transition-colors shadow-sm"
                    title="Refresh Logs"
                >
                    <History size={20} className="text-slate-600" />
                </button>
            </div>

            {/* Mini Stats Row */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {[
                    { label: 'Total Events', value: stats.total, color: 'indigo' },
                    { label: 'Staff Approvals', value: stats.approvals, color: 'green' },
                    { label: 'Security Alerts', value: stats.alerts, color: 'red' },
                ].map((s, i) => (
                    <div key={i} className="bg-white p-4 rounded-2xl border shadow-sm flex items-center justify-between">
                        <span className="text-sm font-medium text-slate-500">{s.label}</span>
                        <span className={`text-xl font-bold text-${s.color}-600`}>{s.value}</span>
                    </div>
                ))}
            </div>

            {/* Activity Timeline */}
            <div className="bg-white rounded-2xl border shadow-sm overflow-hidden">
                <div className="p-6 border-b bg-slate-50/50">
                    <h3 className="font-bold text-slate-800">Event Stream</h3>
                </div>
                <div className="divide-y">
                    {loading ? (
                        [...Array(6)].map((_, i) => (
                            <div key={i} className="p-6 animate-pulse flex items-center gap-4">
                                <div className="w-10 h-10 rounded-full bg-slate-100"></div>
                                <div className="flex-1 space-y-2">
                                    <div className="h-4 bg-slate-100 rounded w-3/4"></div>
                                    <div className="h-3 bg-slate-100 rounded w-1/2"></div>
                                </div>
                            </div>
                        ))
                    ) : logs.length === 0 ? (
                        <div className="p-12 text-center">
                            <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-4">
                                <FileText size={32} className="text-slate-300" />
                            </div>
                            <p className="text-slate-500 font-medium">No activity recorded yet.</p>
                        </div>
                    ) : (
                        logs.map((log) => (
                            <div key={log._id} className="p-6 hover:bg-slate-50/50 transition-all group">
                                <div className="flex items-start gap-4">
                                    <div className={`p-2 rounded-xl bg-white border shadow-sm group-hover:scale-110 transition-transform`}>
                                        {getActionIcon(log.action)}
                                    </div>
                                    <div className="flex-1">
                                        <div className="flex justify-between items-start">
                                            <div>
                                                <h4 className="font-bold text-slate-900 mb-1">
                                                    {log.action} <span className="text-slate-400 font-normal mx-2">on</span> {log.targetUser?.name || 'Unknown User'}
                                                </h4>
                                                <p className="text-sm text-slate-600 leading-relaxed">{log.description}</p>
                                            </div>
                                            <div className="text-right shrink-0">
                                                <span className="text-xs font-bold text-slate-400 flex items-center gap-1">
                                                    <Calendar size={12} /> {new Date(log.timestamp).toLocaleDateString()}
                                                </span>
                                                <p className="text-xs font-medium text-slate-400 mt-1">
                                                    {new Date(log.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                                </p>
                                            </div>
                                        </div>

                                        <div className="mt-4 flex items-center gap-6">
                                            <div className="flex items-center gap-2">
                                                <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Performed By</span>
                                                <div className="flex items-center gap-1.5">
                                                    <div className="w-5 h-5 rounded-full bg-slate-200 flex items-center justify-center text-[10px] font-bold">
                                                        {log.performedBy?.name?.charAt(0) || 'S'}
                                                    </div>
                                                    <span className="text-xs font-semibold text-indigo-600">{log.performedBy?.name || 'System'}</span>
                                                </div>
                                            </div>

                                            <div className="flex items-center gap-2">
                                                <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Target Role</span>
                                                <span className="text-xs font-semibold px-2 py-0.5 rounded bg-slate-100 text-slate-700">
                                                    {log.targetUser?.role || 'N/A'}
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        ))
                    )}
                </div>
            </div>
        </div>
    );
};

export default Activity;
