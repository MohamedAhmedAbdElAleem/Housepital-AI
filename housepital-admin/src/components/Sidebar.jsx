import React from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import {
    ShieldCheck,
    LayoutDashboard,
    Users,
    Activity,
    LogOut,
    ChevronRight
} from 'lucide-react';

const Sidebar = () => {
    const { user, logout } = useAuth();
    const navigate = useNavigate();

    const handleLogout = () => {
        logout();
        navigate('/login');
    };

    const navItems = [
        { path: '/', icon: LayoutDashboard, label: 'Overview', exact: true },
        { path: '/users', icon: Users, label: 'Users' },
        { path: '/activity', icon: Activity, label: 'Activity Logs' },
    ];

    return (
        <aside className="fixed left-0 top-0 h-screen w-64 bg-white border-r border-slate-200 flex flex-col shadow-sm">
            {/* Logo Section */}
            <div className="p-6 border-b border-slate-200">
                <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-2xl flex items-center justify-center shadow-lg shadow-emerald-500/20">
                        <ShieldCheck className="text-white w-7 h-7" strokeWidth={2.5} />
                    </div>
                    <div>
                        <h1 className="text-slate-900 font-bold text-xl tracking-tight">Housepital</h1>
                        <p className="text-slate-500 text-xs font-medium">Admin Portal</p>
                    </div>
                </div>
            </div>

            {/* Navigation */}
            <nav className="flex-1 px-3 py-6 space-y-1 overflow-y-auto">
                {navItems.map((item) => (
                    <NavLink
                        key={item.path}
                        to={item.path}
                        end={item.exact}
                        className={({ isActive }) =>
                            `flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 group ${isActive
                                ? 'bg-emerald-500 text-white shadow-lg shadow-emerald-500/20'
                                : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
                            }`
                        }
                    >
                        {({ isActive }) => (
                            <>
                                <item.icon
                                    size={20}
                                    className={isActive ? 'text-white' : 'text-slate-400 group-hover:text-emerald-500 transition-colors'}
                                    strokeWidth={2.5}
                                />
                                <span className={`font-semibold text-sm flex-1 ${isActive ? 'text-white' : ''}`}>{item.label}</span>
                                {isActive && (
                                    <ChevronRight size={16} className="text-white/80" strokeWidth={2.5} />
                                )}
                            </>
                        )}
                    </NavLink>
                ))}
            </nav>

            {/* User Section */}
            <div className="p-4 border-t border-slate-200 space-y-3">
                {/* User Info */}
                <div className="px-3 py-3 bg-slate-50 rounded-xl border border-slate-200">
                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">
                        Logged in as
                    </p>
                    <p className="text-sm font-bold text-slate-900 truncate">
                        {user?.name || user?.email || 'Admin'}
                    </p>
                    <p className="text-xs text-slate-500 capitalize mt-0.5 font-medium">
                        {user?.role || 'Administrator'}
                    </p>
                </div>

                {/* Logout Button */}
                <button
                    onClick={handleLogout}
                    className="w-full flex items-center gap-2 px-4 py-2.5 rounded-xl bg-slate-50 hover:bg-red-50 text-slate-600 hover:text-red-600 transition-all duration-200 group border border-slate-200 hover:border-red-200"
                >
                    <LogOut size={18} className="group-hover:scale-110 transition-transform" strokeWidth={2.5} />
                    <span className="font-semibold text-sm">Logout</span>
                </button>
            </div>
        </aside>
    );
};

export default Sidebar;
