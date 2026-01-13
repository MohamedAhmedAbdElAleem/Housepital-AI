import React, { useState, useEffect } from 'react';
import api from '../services/api';
import {
    Search,
    Filter,
    UserCheck,
    UserX,
    MoreVertical,
    Mail,
    Phone,
    Shield,
    Clock
} from 'lucide-react';

const Users = () => {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [filter, setFilter] = useState('all');

    useEffect(() => {
        fetchUsers();
    }, [filter]);

    const fetchUsers = async () => {
        try {
            setLoading(true);
            // Using the same endpoint we created earlier for the mobile app
            const response = await api.get(`/api/admin/insights/all-users`, {
                params: { role: filter, search }
            });
            if (response.data.success) {
                setUsers(response.data.users);
            }
        } catch (error) {
            console.error('Error fetching users:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSearch = (e) => {
        if (e.key === 'Enter') {
            fetchUsers();
        }
    };

    const getRoleBadge = (role) => {
        const roles = {
            admin: 'bg-purple-100 text-purple-700 border-purple-200',
            doctor: 'bg-green-100 text-green-700 border-green-200',
            nurse: 'bg-green-100 text-green-700 border-green-200',
            customer: 'bg-orange-100 text-orange-700 border-orange-200',
        };
        return `px-3 py-1 rounded-full text-xs font-bold border ${roles[role.toLowerCase()] || 'bg-gray-100 text-gray-700 border-gray-200'}`;
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-slate-900 tracking-tight">User Management</h1>
                    <p className="text-slate-500 text-sm mt-1 font-medium">Manage and monitor all system users and staff members.</p>
                </div>
                <button className="bg-primary-600 text-white px-5 py-3 rounded-xl text-sm font-semibold hover:bg-primary-700 transition-all shadow-sm hover:shadow-md active:scale-95 flex items-center gap-2">
                    <Shield size={18} />
                    <span>Invite Staff</span>
                </button>
            </div>

            {/* Filters & Search */}
            <div className="bg-white p-4 rounded-2xl border shadow-sm flex flex-wrap gap-4 items-center justify-between">
                <div className="flex gap-2">
                    {['all', 'customer', 'nurse', 'doctor', 'admin'].map((role) => (
                        <button
                            key={role}
                            onClick={() => setFilter(role)}
                            className={`px-4 py-2 rounded-xl text-sm font-medium transition-all ${filter === role
                                ? 'bg-primary-600 text-white'
                                : 'bg-slate-50 text-slate-600 hover:bg-slate-100'
                                }`}
                        >
                            {role.charAt(0).toUpperCase() + role.slice(1)}s
                        </button>
                    ))}
                </div>
                <div className="relative min-w-[300px]">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                    <input
                        type="text"
                        placeholder="Search by name, email or mobile..."
                        className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 transition-all"
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        onKeyDown={handleSearch}
                    />
                </div>
            </div>

            {/* Users Table */}
            <div className="bg-white rounded-2xl border shadow-sm overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full text-left">
                        <thead>
                            <tr className="bg-slate-50/50 border-b">
                                <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">User</th>
                                <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Role</th>
                                <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Contact</th>
                                <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Status</th>
                                <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y">
                            {loading ? (
                                [...Array(5)].map((_, idx) => (
                                    <tr key={idx} className="animate-pulse">
                                        <td className="px-6 py-6"><div className="h-4 bg-slate-100 rounded w-48"></div></td>
                                        <td className="px-6 py-6"><div className="h-4 bg-slate-100 rounded w-20"></div></td>
                                        <td className="px-6 py-6"><div className="h-4 bg-slate-100 rounded w-32"></div></td>
                                        <td className="px-6 py-6"><div className="h-4 bg-slate-100 rounded w-16"></div></td>
                                        <td className="px-6 py-6"><div className="h-4 bg-slate-100 rounded w-8 ml-auto"></div></td>
                                    </tr>
                                ))
                            ) : users.length === 0 ? (
                                <tr>
                                    <td colSpan="5" className="px-6 py-12 text-center text-slate-500">
                                        No users found matching your criteria.
                                    </td>
                                </tr>
                            ) : (
                                users.map((user) => (
                                    <tr key={user._id} className="hover:bg-slate-50/50 transition-colors">
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-3">
                                                <div className="w-10 h-10 rounded-full bg-primary-100 flex items-center justify-center text-primary-700 font-bold shrink-0">
                                                    {user.name.charAt(0)}
                                                </div>
                                                <div>
                                                    <p className="font-semibold text-gray-900">{user.name}</p>
                                                    <p className="text-xs text-slate-500 flex items-center gap-1">
                                                        <Clock size={12} /> Joined {new Date(user.createdAt).toLocaleDateString()}
                                                    </p>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className={getRoleBadge(user.role)}>
                                                {user.role.toUpperCase()}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-sm text-slate-600">
                                            <p className="flex items-center gap-2"><Mail size={14} className="text-slate-400" /> {user.email}</p>
                                            <p className="flex items-center gap-2 mt-1"><Phone size={14} className="text-slate-400" /> {user.mobile}</p>
                                        </td>
                                        <td className="px-6 py-4">
                                            {user.status === 'active' || !user.status ? (
                                                <span className="flex items-center gap-1.5 text-green-600 font-medium text-sm">
                                                    <span className="w-2 h-2 rounded-full bg-green-500"></span>
                                                    Active
                                                </span>
                                            ) : (
                                                <span className="flex items-center gap-1.5 text-red-600 font-medium text-sm">
                                                    <span className="w-2 h-2 rounded-full bg-red-500"></span>
                                                    {user.status}
                                                </span>
                                            )}
                                        </td>
                                        <td className="px-6 py-4 text-right">
                                            <button className="p-2 hover:bg-white rounded-lg border border-transparent hover:border-slate-200 transition-all">
                                                <MoreVertical size={18} className="text-slate-400" />
                                            </button>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
};

export default Users;
