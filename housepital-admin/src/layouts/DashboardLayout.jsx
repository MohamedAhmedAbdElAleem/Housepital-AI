import React from 'react';
import Sidebar from '../components/Sidebar';

const DashboardLayout = ({ children }) => {
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
