import React, { useRef } from 'react';
import PowerBIReport from '../components/PowerBIReport';
import {
    Users,
    TrendingUp,
    Clock,
    AlertCircle
} from 'lucide-react';

const Overview = () => {
    // Demo Report ID - Replace with your actual Power BI Report ID from production
    const PBI_REPORT_ID = "YOUR_POWERBI_REPORT_ID_HERE";
    const reportRef = useRef(null);

    const kpis = [
        { label: 'Active Nurses', value: '142', change: '+12%', icon: Users, color: 'text-blue-600', bg: 'bg-blue-100' },
        { label: 'Visits Today', value: '84', change: '+5%', icon: TrendingUp, color: 'text-green-600', bg: 'bg-green-100' },
        { label: 'Avg. Response', value: '12m', change: '-2m', icon: Clock, color: 'text-purple-600', bg: 'bg-purple-100' },
        { label: 'Pending Alerts', value: '3', change: 'New', icon: AlertCircle, color: 'text-red-600', bg: 'bg-red-100' },
    ];

    const handleFullScreen = () => {
        if (reportRef.current) {
            reportRef.current.handleFullscreen();
        }
    };

    return (
        <div className="space-y-8">
            {/* KPI Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {kpis.map((kpi, idx) => (
                    <div key={idx} className="bg-white p-6 rounded-2xl border shadow-sm hover:shadow-md transition-shadow">
                        <div className="flex items-center justify-between mb-4">
                            <div className={`p-3 rounded-xl ${kpi.bg}`}>
                                <kpi.icon className={kpi.color} size={24} />
                            </div>
                            <span className={`text-sm font-bold ${kpi.change.startsWith('+') ? 'text-green-600' : 'text-red-600'}`}>
                                {kpi.change}
                            </span>
                        </div>
                        <h3 className="text-gray-500 text-sm font-medium">{kpi.label}</h3>
                        <p className="text-3xl font-bold text-gray-900 mt-1">{kpi.value}</p>
                    </div>
                ))}
            </div>

            {/* Analytics Insight */}
            <div className="bg-white rounded-2xl border shadow-sm overflow-hidden">
                <div className="p-6 border-b flex justify-between items-center bg-slate-50/50">
                    <div>
                        <h3 className="text-lg font-bold text-gray-900">AI Predictive Analytics Dashboard</h3>
                        <p className="text-sm text-gray-500">Live Power BI Embedded Insights</p>
                    </div>
                    <button
                        onClick={handleFullScreen}
                        className="text-indigo-600 text-sm font-semibold hover:underline"
                    >
                        Full Screen View
                    </button>
                </div>
                <div className="p-6">
                    <PowerBIReport ref={reportRef} reportId={PBI_REPORT_ID} />
                </div>
            </div>
        </div>
    );
};

export default Overview;
