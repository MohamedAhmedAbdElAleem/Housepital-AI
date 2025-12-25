import React from 'react';
import {
    LineChart, Line, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
    BarChart, Bar, PieChart, Pie, Cell
} from 'recharts';
import { Brain, TrendingUp, Users, Activity } from 'lucide-react';

const MockAnalytics = () => {
    const lineData = [
        { name: 'Mon', visits: 45, predicted: 48 },
        { name: 'Tue', visits: 52, predicted: 50 },
        { name: 'Wed', visits: 48, predicted: 55 },
        { name: 'Thu', visits: 61, predicted: 58 },
        { name: 'Fri', visits: 55, predicted: 62 },
        { name: 'Sat', visits: 72, predicted: 68 },
        { name: 'Sun', visits: 65, predicted: 70 },
    ];

    const pieData = [
        { name: 'Nurses', value: 65, color: '#6366f1' },
        { name: 'Doctors', value: 25, color: '#f59e0b' },
        { name: 'Physiotherapy', value: 10, color: '#10b981' },
    ];

    const barData = [
        { name: 'Cardiology', count: 120 },
        { name: 'General', count: 210 },
        { name: 'Pediatrics', count: 85 },
        { name: 'Orthopedic', count: 140 },
        { name: 'Nursing', count: 320 },
    ];

    return (
        <div className="bg-slate-50 p-6 rounded-xl animate-in fade-in duration-700">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
                {/* Prediction Insights */}
                <div className="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
                    <div className="flex items-center justify-between mb-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-indigo-50 rounded-lg">
                                <Brain className="text-indigo-600" size={20} />
                            </div>
                            <h4 className="font-bold text-slate-800">Visit Demand Prediction (AI)</h4>
                        </div>
                        <div className="flex gap-4 text-xs font-semibold px-3 py-1 bg-slate-50 rounded-full border">
                            <span className="flex items-center gap-1.5 text-indigo-600">
                                <span className="w-2 h-2 rounded-full bg-indigo-600"></span> Actual
                            </span>
                            <span className="flex items-center gap-1.5 text-slate-400">
                                <span className="w-2 h-2 rounded-full bg-slate-300"></span> Predicted
                            </span>
                        </div>
                    </div>
                    <div className="h-[300px] w-full">
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={lineData}>
                                <defs>
                                    <linearGradient id="colorVisits" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="#6366f1" stopOpacity={0.1} />
                                        <stop offset="95%" stopColor="#6366f1" stopOpacity={0} />
                                    </linearGradient>
                                </defs>
                                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#94a3b8' }} dy={10} />
                                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#94a3b8' }} />
                                <Tooltip
                                    contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
                                />
                                <Area type="monotone" dataKey="visits" stroke="#6366f1" strokeWidth={3} fillOpacity={1} fill="url(#colorVisits)" />
                                <Line type="monotone" dataKey="predicted" stroke="#cbd5e1" strokeWidth={2} strokeDasharray="5 5" dot={false} />
                            </AreaChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                {/* Resources Distribution */}
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
                    <h4 className="font-bold text-slate-800 mb-6 flex items-center gap-2">
                        <Users className="text-amber-500" size={20} /> Staff Allocation
                    </h4>
                    <div className="h-[250px] w-full">
                        <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                                <Pie
                                    data={pieData}
                                    cx="50%"
                                    cy="50%"
                                    innerRadius={60}
                                    outerRadius={80}
                                    paddingAngle={8}
                                    dataKey="value"
                                >
                                    {pieData.map((entry, index) => (
                                        <Cell key={`cell-${index}`} fill={entry.color} />
                                    ))}
                                </Pie>
                                <Tooltip />
                            </PieChart>
                        </ResponsiveContainer>
                    </div>
                    <div className="space-y-3 mt-4">
                        {pieData.map((item) => (
                            <div key={item.name} className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <div className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }}></div>
                                    <span className="text-sm font-medium text-slate-600">{item.name}</span>
                                </div>
                                <span className="text-sm font-bold text-slate-800">{item.value}%</span>
                            </div>
                        ))}
                    </div>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
                <div className="lg:col-span-3 bg-white p-6 rounded-2xl border border-slate-100 shadow-sm">
                    <h4 className="font-bold text-slate-800 mb-6 flex items-center gap-2">
                        <Activity className="text-emerald-500" size={20} /> Service Volume by Specialty
                    </h4>
                    <div className="h-[200px] w-full">
                        <ResponsiveContainer width="100%" height="100%">
                            <BarChart data={barData}>
                                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#94a3b8' }} />
                                <YAxis hide />
                                <Tooltip />
                                <Bar dataKey="count" fill="#10b981" radius={[6, 6, 0, 0]} barSize={40} />
                            </BarChart>
                        </ResponsiveContainer>
                    </div>
                </div>
                <div className="bg-indigo-600 p-6 rounded-2xl text-white shadow-xl shadow-indigo-200">
                    <div className="flex items-center gap-2 mb-4 opacity-80">
                        <TrendingUp size={18} />
                        <span className="text-sm font-semibold uppercase tracking-wider">Growth Factor</span>
                    </div>
                    <p className="text-4xl font-bold mb-2">24.8%</p>
                    <p className="text-sm opacity-70 leading-relaxed">System-wide efficiency increased by almost a quarter since last month's optimization.</p>
                    <div className="mt-8 pt-6 border-t border-white/10">
                        <button className="w-full bg-white/10 hover:bg-white/20 py-3 rounded-xl font-bold text-sm transition-colors border border-white/10">
                            View Full Report
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default MockAnalytics;
