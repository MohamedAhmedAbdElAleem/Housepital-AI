import React, { useState, useEffect } from 'react';
import api from '../services/api';
import {
    DollarSign,
    TrendingUp,
    TrendingDown,
    CreditCard,
    Wallet,
    ArrowUpRight,
    ArrowDownRight,
    RefreshCw,
    Calendar,
    Loader2,
    PiggyBank,
    Receipt,
    Download
} from 'lucide-react';
import { exportToCSV } from '../utils/exportUtils';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, AreaChart, Area } from 'recharts';

const Financial = () => {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [period, setPeriod] = useState('month');

    useEffect(() => {
        fetchFinancialData();
    }, [period]);

    const fetchFinancialData = async () => {
        try {
            setLoading(true);
            const response = await api.get(`/api/admin/insights/financial`, {
                params: { period }
            });
            if (response.data.success) {
                setData(response.data.data);
            }
        } catch (error) {
            console.error('Error fetching financial data:', error);
        } finally {
            setLoading(false);
        }
    };

    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('en-EG', {
            style: 'currency',
            currency: 'EGP',
            minimumFractionDigits: 0
        }).format(amount || 0);
    };

    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center h-[60vh] gap-4">
                <Loader2 className="w-12 h-12 text-primary-500 animate-spin" />
                <p className="text-slate-500 font-medium">Loading financial analytics...</p>
            </div>
        );
    }


    const handleExport = () => {
        if (!data || !data.revenueTrend) return;
        const exportData = data.revenueTrend.map(d => ({
            Date: d._id,
            Revenue: d.totalRevenue,
            Bookings: d.count
        }));
        exportToCSV(exportData, `financial_report_${period}_${new Date().toISOString().split('T')[0]}`);
    };

    const stats = [

        {
            label: 'Total Revenue',
            value: formatCurrency(data?.transactionBreakdown?.booking_payment?.total || 0),
            change: '+12.5%',
            trend: 'up',
            icon: DollarSign,
            color: 'emerald'
        },
        {
            label: 'Platform Fees',
            value: formatCurrency(data?.transactionBreakdown?.platform_fee?.total || 0),
            change: '+8.2%',
            trend: 'up',
            icon: PiggyBank,
            color: 'blue'
        },
        {
            label: 'Refunds',
            value: formatCurrency(data?.transactionBreakdown?.refund?.total || 0),
            change: '-3.1%',
            trend: 'down',
            icon: Receipt,
            color: 'red'
        },
        {
            label: 'Withdrawals',
            value: formatCurrency(data?.transactionBreakdown?.withdrawal?.total || 0),
            change: '+5.4%',
            trend: 'up',
            icon: Wallet,
            color: 'purple'
        }
    ];

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-slate-900 tracking-tight">Financial Analytics</h1>
                    <p className="text-slate-500 text-sm mt-1 font-medium">Track revenue, transactions, and financial performance</p>
                </div>
                <div className="flex items-center gap-3">
                    <div className="flex bg-white rounded-xl border border-slate-200 p-1">
                    <button
                        onClick={handleExport}
                        className="p-2 hover:bg-slate-50 rounded-lg text-slate-500 hover:text-primary-600 transition-colors mr-2"
                        title="Export Report"
                    >
                        <Download size={20} />
                    </button>
                    {['week', 'month', 'year'].map((p) => (
                            <button
                                key={p}
                                onClick={() => setPeriod(p)}
                                className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                                    period === p
                                        ? 'bg-primary-600 text-white'
                                        : 'text-slate-600 hover:bg-slate-50'
                                }`}
                            >
                                {p.charAt(0).toUpperCase() + p.slice(1)}
                            </button>
                        ))}
                    </div>
                    <button
                        onClick={fetchFinancialData}
                        className="p-3 bg-white border rounded-xl hover:bg-slate-50 transition-all"
                    >
                        <RefreshCw size={20} className="text-slate-600" />
                    </button>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {stats.map((stat, idx) => (
                    <div key={idx} className="bg-white p-6 rounded-2xl border shadow-sm hover:shadow-md transition-all">
                        <div className="flex items-center justify-between mb-4">
                            <div className={`p-3 rounded-xl bg-${stat.color}-50 border border-${stat.color}-100`}>
                                <stat.icon className={`text-${stat.color}-600`} size={24} />
                            </div>
                            <span className={`flex items-center gap-1 text-xs font-bold ${
                                stat.trend === 'up' ? 'text-green-600' : 'text-red-600'
                            }`}>
                                {stat.trend === 'up' ? <ArrowUpRight size={14} /> : <ArrowDownRight size={14} />}
                                {stat.change}
                            </span>
                        </div>
                        <p className="text-slate-500 text-sm font-medium mb-1">{stat.label}</p>
                        <p className="text-2xl font-bold text-slate-900">{stat.value}</p>
                    </div>
                ))}
            </div>

            {/* Revenue Chart */}
            <div className="bg-white rounded-2xl border shadow-sm p-6">
                <h3 className="text-lg font-bold text-slate-900 mb-6">Revenue Trend</h3>
                <div className="h-80">
                    <ResponsiveContainer width="100%" height="100%">
                        <AreaChart data={data?.revenueTrend || []}>
                            <defs>
                                <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                                    <stop offset="5%" stopColor="#10b981" stopOpacity={0.3}/>
                                    <stop offset="95%" stopColor="#10b981" stopOpacity={0}/>
                                </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                            <XAxis dataKey="_id" stroke="#94a3b8" fontSize={12} />
                            <YAxis stroke="#94a3b8" fontSize={12} />
                            <Tooltip 
                                contentStyle={{ 
                                    backgroundColor: 'white', 
                                    border: '1px solid #e2e8f0', 
                                    borderRadius: '12px',
                                    boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)'
                                }}
                                formatter={(value) => [formatCurrency(value), 'Revenue']}
                            />
                            <Area 
                                type="monotone" 
                                dataKey="revenue" 
                                stroke="#10b981" 
                                strokeWidth={2}
                                fillOpacity={1} 
                                fill="url(#colorRevenue)" 
                            />
                        </AreaChart>
                    </ResponsiveContainer>
                </div>
            </div>

            {/* Top Earners */}
            <div className="bg-white rounded-2xl border shadow-sm overflow-hidden">
                <div className="p-6 border-b">
                    <h3 className="text-lg font-bold text-slate-900">Top Earning Nurses</h3>
                </div>
                <div className="divide-y">
                    {(data?.topEarners || []).length === 0 ? (
                        <div className="p-12 text-center">
                            <p className="text-slate-500">No earnings data yet</p>
                        </div>
                    ) : (
                        data?.topEarners?.map((nurse, idx) => (
                            <div key={idx} className="p-4 flex items-center justify-between hover:bg-slate-50 transition-colors">
                                <div className="flex items-center gap-3">
                                    <div className="w-10 h-10 rounded-full bg-primary-100 flex items-center justify-center text-primary-700 font-bold">
                                        {nurse.name?.charAt(0) || '?'}
                                    </div>
                                    <div>
                                        <p className="font-semibold text-slate-900">{nurse.name}</p>
                                        <p className="text-xs text-slate-500">{nurse.completedVisits || 0} visits completed</p>
                                    </div>
                                </div>
                                <div className="text-right">
                                    <p className="font-bold text-emerald-600">{formatCurrency(nurse.totalEarnings)}</p>
                                    <p className="text-xs text-slate-400">Total Earnings</p>
                                </div>
                            </div>
                        ))
                    )}
                </div>
            </div>
        </div>
    );
};

export default Financial;
