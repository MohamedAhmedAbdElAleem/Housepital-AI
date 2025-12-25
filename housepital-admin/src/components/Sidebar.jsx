import React from 'react';
import { NavLink } from 'react-router-dom';
import {
    LayoutDashboard,
    Users,
    Activity,
    Settings,
    LogOut,
    ShieldCheck
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';

const Sidebar = () => {
    const { user, logout } = useAuth();
    const menuItems = [
        { icon: LayoutDashboard, label: 'Overview', path: '/' },
        { icon: Users, label: 'Users', path: '/users' },
        { icon: Activity, label: 'Activity Logs', path: '/activity' },
        { icon: Settings, label: 'Settings', path: '/settings' },
    ];

    return (
        <div className="h-screen w-64 bg-slate-900 text-slate-300 flex flex-col fixed left-0 top-0">
            <div className="p-6 flex items-center gap-3 border-b border-slate-800">
                <div className="p-2 bg-indigo-600 rounded-lg">
                    <ShieldCheck className="text-white w-6 h-6" />
                </div>
                <h1 className="text-xl font-bold text-white tracking-tight">Housepital AI</h1>
            </div>

            <nav className="flex-1 p-4 space-y-2 mt-4">
                {menuItems.map((item) => (
                    <NavLink
                        key={item.path}
                        to={item.path}
                        className={({ isActive }) => `
              flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200
              ${isActive
                                ? 'bg-indigo-600/10 text-indigo-400 font-semibold border-r-4 border-indigo-600 rounded-r-none'
                                : 'hover:bg-slate-800 hover:text-white'}
            `}
                    >
                        <item.icon size={20} />
                        <span>{item.label}</span>
                    </NavLink>
                ))}
            </nav>

            <div className="p-4 border-t border-slate-800">
                <div className="p-4 bg-slate-800/50 rounded-xl mb-4 text-xs">
                    <p className="text-slate-500 mb-1 font-medium">LOGGED IN AS</p>
                    <p className="text-white font-semibold">{user?.name || 'System Admin'}</p>
                </div>
                <button
                    onClick={logout}
                    className="flex items-center gap-3 px-4 py-3 w-full rounded-xl hover:bg-red-500/10 hover:text-red-400 transition-colors"
                >
                    <LogOut size={20} />
                    <span>Logout</span>
                </button>
            </div>
        </div>
    );
};

export default Sidebar;
