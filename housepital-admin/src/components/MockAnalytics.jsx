import React from 'react';
import {
    LineChart, Line, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
    BarChart, Bar, PieChart, Pie, Cell
} from 'recharts';
import { Brain, TrendingUp, Users, Activity, Loader2 } from 'lucide-react';

const MockAnalytics = ({ dashboardData }) => {
    // If data is still loading or missing, show a subtle loader
    if (!dashboardData) {
        return (
            <div className="h-[400px] flex items-center justify-center">
                <Loader2 className="w-8 h-8 text-emerald-500 animate-spin" />
            </div>
        );
    }

    // Map Booking Trend Data from Backend
    // Backend format: [{ _id: 'YYYY-MM-DD', total: 10, completed: 8, cancelled: 2 }]
    const lineData = dashboardData.bookings?.byType || [];

    // For the line chart, we'll simulate a weekly trend if the actual trend data is in a sub-endpoint
    // or use the data available from the dashboard overview.
    // Let's use recent bookings to show a simple volume trend if available
    const recentTrend = [
        { name: 'Mon', visits: 45, predicted: 48 },
        { name: 'Tue', visits: 52, predicted: 50 },
        { name: 'Wed', visits: 48, predicted: 55 },
        { name: 'Thu', visits: 61, predicted: 58 },
        { name: 'Fri', visits: 55, predicted: 62 },
        { name: 'Sat', visits: 72, predicted: 68 },
        { name: 'Sun', visits: 65, predicted: 70 },
    ];

    // Staff Allocation Data from Backend
    const pieData = [
        { name: 'Nurses', value: dashboardData.providers?.nurses?.total || 0, color: '#2ECC71' },
        { name: 'Doctors', value: dashboardData.providers?.doctors?.total || 0, color: '#f59e0b' },
        { name: 'Admins', value: dashboardData.users?.byRole?.admin?.total || 0, color: '#6366f1' },
    ];

    // Service Volume Data from Backend
    // Backend format: bookings.byType = { nurse_visit: 50, doctor_consult: 30 }
    const barData = Object.entries(dashboardData.bookings?.byType || {}).map(([key, val]) => ({
        name: key.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' '),
        count: val
    }));

    // If no type data, use status data as fallback
    const fallbackBarData = Object.entries(dashboardData.bookings?.byStatus || {}).map(([key, val]) => ({
        name: key.charAt(0).toUpperCase() + key.slice(1),
        count: val
    }));

    const finalBarData = barData.length > 0 ? barData : fallbackBarData;

    return (
        <div className="p-8 space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Visit Demand Prediction (AI) */}
                <div className="lg:col-span-2 bg-slate-50 p-8 rounded-[2rem] border border-slate-100 shadow-inner">
                    <div className="flex items-center justify-between mb-8">
                        <div className="flex items-center gap-4">
                            <div className="p-3 bg-emerald-500 rounded-2xl shadow-lg shadow-emerald-500/20">
                                <Brain className="text-white" size={24} />
                            </div>
                            <div>
                                <h4 className="font-black text-slate-800 text-lg">Predictive Visit Trends</h4>
                                <p className="text-xs text-slate-500 font-bold uppercase tracking-widest">AI Forecasting</p>
                            </div>
                        </div>
                        <div className="flex gap-6 text-[10px] font-black px-4 py-2 bg-white rounded-2xl shadow-sm border border-slate-100">
                            <span className="flex items-center gap-2 text-emerald-600">
                                <span className="w-2.5 h-2.5 rounded-full bg-emerald-500"></span> ACTUAL
                            </span>
                            <span className="flex items-center gap-2 text-slate-400">
                                <span className="w-2.5 h-2.5 rounded-full bg-slate-200"></span> PREDICTED
                            </span>
                        </div>
                    </div>
                    <div className="h-[350px] w-full">
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={recentTrend}>
                                <defs>
                                    <linearGradient id="colorVisits" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="#10b981" stopOpacity={0.2} />
                                        <stop offset="95%" stopColor="#10b981" stopOpacity={0} />
                                    </linearGradient>
                                </defs>
                                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 11, fontWeight: 700, fill: '#94a3b8' }} dy={10} />
                                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fontWeight: 700, fill: '#94a3b8' }} />
                                <Tooltip
                                    contentStyle={{
                                        borderRadius: '20px',
                                        border: 'none',
                                        boxShadow: '0 10px 30px rgba(0,0,0,0.1)',
                                        padding: '12px 16px'
                                    }}
                                />
                                <Area type="monotone" dataKey="visits" stroke="#10b981" strokeWidth={4} fillOpacity={1} fill="url(#colorVisits)" />
                                <Line type="monotone" dataKey="predicted" stroke="#cbd5e1" strokeWidth={2} strokeDasharray="6 6" dot={false} />
                            </AreaChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                {/* Staff Allocation */}
                <div className="bg-white p-8 rounded-[2rem] border border-slate-100 shadow-xl flex flex-col">
                    <h4 className="font-black text-slate-800 mb-8 flex items-center gap-3">
                        <Users className="text-amber-500" size={24} />
                        <span>Staff Distribution</span>
                    </h4>
                    <div className="h-[280px] w-full relative">
                        <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                                <Pie
                                    data={pieData}
                                    cx="50%"
                                    cy="50%"
                                    innerRadius={75}
                                    outerRadius={100}
                                    paddingAngle={10}
                                    dataKey="value"
                                >
                                    {pieData.map((entry, index) => (
                                        <Cell key={`cell-${index}`} fill={entry.color} className="hover:opacity-80 transition-opacity" />
                                    ))}
                                </Pie>
                                <Tooltip />
                            </PieChart>
                        </ResponsiveContainer>
                        <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                            <div className="text-center">
                                <p className="text-xs font-black text-slate-400 uppercase tracking-widest">Total</p>
                                <p className="text-3xl font-black text-slate-800">
                                    {pieData.reduce((acc, curr) => acc + curr.value, 0)}
                                </p>
                            </div>
                        </div>
                    </div>
                    <div className="space-y-4 mt-8">
                        {pieData.map((item) => (
                            <div key={item.name} className="flex items-center justify-between p-3 bg-slate-50 rounded-xl hover:bg-slate-100 transition-colors">
                                <div className="flex items-center gap-3">
                                    <div className="w-4 h-4 rounded-full shadow-sm" style={{ backgroundColor: item.color }}></div>
                                    <span className="text-sm font-bold text-slate-600">{item.name}</span>
                                </div>
                                <span className="text-sm font-black text-slate-800">{item.value}</span>
                            </div>
                        ))}
                    </div>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
                {/* Service Volume */}
                <div className="lg:col-span-3 bg-white p-8 rounded-[2rem] border border-slate-200 shadow-lg">
                    <h4 className="font-black text-slate-800 mb-8 flex items-center gap-3">
                        <Activity className="text-emerald-500" size={24} />
                        <span>System Activity Volume</span>
                    </h4>
                    <div className="h-[250px] w-full">
                        <ResponsiveContainer width="100%" height="100%">
                            <BarChart data={finalBarData}>
                                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 10, fontWeight: 700, fill: '#94a3b8' }} />
                                <YAxis hide />
                                <Tooltip
                                    cursor={{ fill: '#f8fafc', radius: 10 }}
                                    contentStyle={{ borderRadius: '15px', border: 'none', boxShadow: '0 8px 24px rgba(0,0,0,0.1)' }}
                                />
                                <Bar dataKey="count" fill="#10b981" radius={[8, 8, 0, 0]} barSize={50} />
                            </BarChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                {/* System Efficiency Card */}
                <div className="bg-gradient-to-br from-emerald-500 to-teal-600 p-8 rounded-[2rem] text-white shadow-2xl shadow-emerald-500/30 flex flex-col justify-between items-start relative overflow-hidden group">
                    <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:scale-150 transition-transform duration-700">
                        <TrendingUp size={120} />
                    </div>
                    <div className="relative z-10 w-full">
                        <div className="flex items-center gap-2 mb-6 bg-white/20 w-fit px-4 py-1.5 rounded-full backdrop-blur-md border border-white/30">
                            <TrendingUp size={16} />
                            <span className="text-xs font-black uppercase tracking-wider">Growth Index</span>
                        </div>
                        <p className="text-5xl font-black mb-2 tracking-tighter">
                            {dashboardData.bookings?.total > 100 ? '24.8%' : 'New'}
                        </p>
                        <p className="text-sm font-medium opacity-80 leading-relaxed max-w-[200px]">
                            {dashboardData.today?.completedBookings > 0
                                ? "Efficiency is scaling with today's activity."
                                : "Awaiting more data for today's performance analysis."}
                        </p>
                    </div>
                    <div className="mt-8 pt-8 border-t border-white/20 w-full relative z-10">
                        <button className="w-full bg-white/10 hover:bg-white text-white hover:text-emerald-600 py-4 rounded-2xl font-black text-xs transition-all border border-white/20 uppercase tracking-widest active:scale-95 shadow-lg shadow-black/5">
                            Detailed System Audit
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default MockAnalytics;
