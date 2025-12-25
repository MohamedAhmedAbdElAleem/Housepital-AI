import React from 'react';
import Sidebar from '../components/Sidebar';

const DashboardLayout = ({ children }) => {
    return (
        <div className="flex bg-gray-50 min-h-screen">
            <Sidebar />
            <main className="flex-1 ml-64 p-8">
                <header className="mb-8 flex justify-between items-center">
                    <div>
                        <h2 className="text-2xl font-bold text-gray-900 tracking-tight">System Control Center</h2>
                        <p className="text-gray-500 text-sm mt-1">Real-time health informatics and patient management analytics.</p>
                    </div>
                    <div className="flex gap-4 items-center">
                        <div className="bg-white px-4 py-2 rounded-lg border shadow-sm flex items-center gap-2">
                            <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
                            <span className="text-sm font-medium text-gray-600">Health System Live</span>
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
