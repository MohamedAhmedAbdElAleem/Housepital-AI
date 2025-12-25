import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import DashboardLayout from './layouts/DashboardLayout';
import Overview from './pages/Overview';
import Users from './pages/Users';
import Activity from './pages/Activity';
import Login from './pages/Login';

// Protected Route Component
const ProtectedRoute = ({ children }) => {
    const { user, isLoading } = useAuth();

    if (isLoading) {
        return (
            <div className="min-h-screen bg-slate-900 flex items-center justify-center">
                <div className="w-12 h-12 border-4 border-indigo-600/30 border-t-indigo-600 rounded-full animate-spin"></div>
            </div>
        );
    }

    if (!user) {
        return <Navigate to="/login" replace />;
    }

    return children;
};

// Placeholder for Settings
const Placeholder = ({ title }) => (
    <div className="p-8 bg-white rounded-2xl border shadow-sm h-64 flex items-center justify-center">
        <div className="text-center">
            <h2 className="text-xl font-bold text-gray-800">{title}</h2>
            <p className="text-gray-500 mt-2">This module is currently being optimized for enterprise performance.</p>
        </div>
    </div>
);

function App() {
    return (
        <AuthProvider>
            <Router>
                <Routes>
                    {/* Public Route */}
                    <Route path="/login" element={<Login />} />

                    {/* Protected Routes */}
                    <Route path="/" element={
                        <ProtectedRoute>
                            <DashboardLayout><Overview /></DashboardLayout>
                        </ProtectedRoute>
                    } />
                    <Route path="/users" element={
                        <ProtectedRoute>
                            <DashboardLayout><Users /></DashboardLayout>
                        </ProtectedRoute>
                    } />
                    <Route path="/activity" element={
                        <ProtectedRoute>
                            <DashboardLayout><Activity /></DashboardLayout>
                        </ProtectedRoute>
                    } />
                    <Route path="/settings" element={
                        <ProtectedRoute>
                            <DashboardLayout><Placeholder title="Global Configuration" /></DashboardLayout>
                        </ProtectedRoute>
                    } />

                    {/* Redirect any other route to home */}
                    <Route path="*" element={<Navigate to="/" replace />} />
                </Routes>
            </Router>
        </AuthProvider>
    );
}

export default App;
