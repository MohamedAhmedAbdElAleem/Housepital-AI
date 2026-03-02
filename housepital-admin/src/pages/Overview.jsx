import React, { useState, useEffect } from 'react';
import DashboardCharts from '../components/DashboardCharts';
import api from '../services/api';
import {
    Users,
    TrendingUp,
    Clock,
    AlertCircle,
    Loader2
} from 'lucide-react';

const Overview = () => {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchDashboardData = async () => {
            try {
                setLoading(true);
                const response = await api.get('/api/admin/insights');
                if (response.data.success) {
                    setData(response.data.data);
                }
            } catch (err) {
                console.error('Error fetching dashboard insights:', err);
                setError('Failed to load dashboard data. Please try again later.');
            } finally {
                setLoading(false);
            }
        };

        fetchDashboardData();
    }, []);

    const kpis = [
        {
            label: 'Active Nurses',
            value: data?.providers?.nurses?.online || '0',
            change: `of ${data?.providers?.nurses?.total || 0}`,
            icon: Users,
            color: 'text-emerald-600',
            bg: 'bg-emerald-50',
            borderColor: 'border-emerald-100'
        },
        {
            label: 'Visits Today',
            value: data?.today?.newBookings || '0',
            change: `+${data?.today?.completedBookings || 0} done`,
            icon: TrendingUp,
            color: 'text-green-600',
            bg: 'bg-green-50',
            borderColor: 'border-green-100'
        },
        {
            label: 'Avg. Rating',
            value: data?.bookings?.avgRating || '0.0',
            change: `${data?.bookings?.total || 0} total`,
            icon: Clock,
            color: 'text-emerald-600',
            bg: 'bg-emerald-50',
            borderColor: 'border-emerald-100'
        },
        {
            label: 'Pending Alerts',
            value: data?.pendingVerifications?.total || '0',
            change: 'Action Required',
            icon: AlertCircle,
            color: 'text-red-600',
            bg: 'bg-red-50',
            borderColor: 'border-red-100'
        },
    ];

    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center h-[60vh] gap-4">
                <Loader2 className="w-12 h-12 text-primary-500 animate-spin" />
                <p className="text-slate-500 font-medium animate-pulse">Loading intelligent insights...</p>
            </div>
        );
    }

    if (error) {
        return (
            <div className="p-8 bg-red-50 border border-red-100 rounded-2xl flex items-center gap-4 text-red-700">
                <AlertCircle className="w-8 h-8 flex-shrink-0" />
                <div>
                    <h3 className="font-bold text-lg">System Insight Error</h3>
                    <p className="text-sm opacity-90">{error}</p>
                </div>
            </div>
        );
    }

    return (
        <div className="space-y-8 animate-fade-in">
            {/* KPI Section */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {kpis.map((kpi, index) => (
                    <div key={index} className={`p-6 rounded-2xl border ${kpi.borderColor} ${kpi.bg} flex items-start justify-between shadow-sm hover:shadow-md transition-shadow`}>
                        <div>
                            <p className="text-slate-500 text-sm font-semibold mb-1">{kpi.label}</p>
                            <h3 className={`text-2xl font-bold ${kpi.color} mb-1`}>{kpi.value}</h3>
                            <p className="text-xs font-medium text-slate-500">{kpi.change}</p>
                        </div>
                        <div className={`p-3 rounded-xl bg-white/60 backdrop-blur-sm border ${kpi.borderColor}`}>
                            <kpi.icon className={`w-6 h-6 ${kpi.color}`} />
                        </div>
                    </div>
                ))}
            </div>

            <div className="bg-white rounded-3xl border border-slate-200 shadow-xl overflow-hidden">
                <div className="p-8 border-b border-slate-200 bg-gradient-to-r from-slate-50 to-white">
                    <h3 className="text-2xl font-black text-slate-900 mb-1 tracking-tight">AI Analytics Dashboard</h3>
                    <p className="text-sm text-slate-500 font-medium">Real-time system performance and predictive insights</p>
                </div>
                <DashboardCharts dashboardData={data} />
            </div>
        </div>
    );
};

export default Overview;
