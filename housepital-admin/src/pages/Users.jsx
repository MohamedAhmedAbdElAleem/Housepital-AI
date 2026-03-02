import React, { useState, useEffect, useRef } from 'react';
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
    Clock,
    Eye,
    Ban,
    Trash2,
    KeyRound,
    XCircle,
    Loader2,
    CheckCircle2,
    UserPlus
} from 'lucide-react';

const Users = () => {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [filter, setFilter] = useState('all');
    const [openMenu, setOpenMenu] = useState(null);
    const [selectedUser, setSelectedUser] = useState(null);
    const [actionLoading, setActionLoading] = useState(false);
    const [suspendModal, setSuspendModal] = useState({ open: false, user: null });
    const [inviteModal, setInviteModal] = useState(false);
    const [inviteForm, setInviteForm] = useState({ name: '', email: '', mobile: '', password: '', role: 'nurse', gender: 'male' });
    const [inviteLoading, setInviteLoading] = useState(false);
    const menuRef = useRef(null);

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

    // Close menu when clicking outside
    useEffect(() => {
        const handleClickOutside = (event) => {
            if (menuRef.current && !menuRef.current.contains(event.target)) {
                setOpenMenu(null);
            }
        };
        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
    }, []);

    const openSuspendModal = (user) => {
        setSuspendModal({ open: true, user });
        setOpenMenu(null);
    };

    const handleSuspendUser = async () => {
        const user = suspendModal.user;
        if (!user) return;
        
        try {
            setActionLoading(true);
            await api.patch(`/api/admin/insights/user/${user._id}/status`, {
                status: user.status === 'suspended' ? 'approved' : 'suspended'
            });
            fetchUsers();
            setSuspendModal({ open: false, user: null });
        } catch (error) {
            alert('Error: ' + (error.response?.data?.message || 'Failed to update user status'));
        } finally {
            setActionLoading(false);
        }
    };

    const handleInviteStaff = async (e) => {
        e.preventDefault();
        try {
            setInviteLoading(true);
            const response = await api.post('/api/admin/insights/staff', inviteForm);
            if (response.data.success) {
                alert('Staff member added successfully!');
                setInviteModal(false);
                setInviteForm({ name: '', email: '', mobile: '', password: '', role: 'nurse', gender: 'male' });
                fetchUsers();
            }
        } catch (error) {
            alert('Error: ' + (error.response?.data?.message || 'Failed to add staff member'));
        } finally {
            setInviteLoading(false);
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
                <button 
                    onClick={() => {
                        setInviteForm({ name: '', email: '', mobile: '', password: '', role: 'nurse', gender: 'male' });
                        setInviteModal(true);
                    }}
                    className="bg-primary-600 text-white px-5 py-3 rounded-xl text-sm font-semibold hover:bg-primary-700 transition-all shadow-sm hover:shadow-md active:scale-95 flex items-center gap-2"
                >
                    <UserPlus size={18} />
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
                                        <td className="px-6 py-4 text-right relative" ref={openMenu === user._id ? menuRef : null}>
                                            <button 
                                                onClick={() => setOpenMenu(openMenu === user._id ? null : user._id)}
                                                className="p-2 hover:bg-white rounded-lg border border-transparent hover:border-slate-200 transition-all"
                                            >
                                                <MoreVertical size={18} className="text-slate-400" />
                                            </button>
                                            
                                            {/* Dropdown Menu */}
                                            {openMenu === user._id && (
                                                <div className="absolute right-6 top-12 w-48 bg-white rounded-xl border border-slate-200 shadow-lg py-2 z-10">
                                                    <button
                                                        onClick={() => {
                                                            setSelectedUser(user);
                                                            setOpenMenu(null);
                                                        }}
                                                        className="w-full flex items-center gap-2 px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 transition-colors"
                                                    >
                                                        <Eye size={16} className="text-slate-400" />
                                                        View Details
                                                    </button>
                                                    <button
                                                        onClick={() => openSuspendModal(user)}
                                                        className="w-full flex items-center gap-2 px-4 py-2 text-sm text-orange-600 hover:bg-orange-50 transition-colors"
                                                    >
                                                        <Ban size={16} />
                                                        {user.status === 'suspended' ? 'Activate User' : 'Suspend User'}
                                                    </button>
                                                </div>
                                            )}
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* User Details Modal */}
            {selectedUser && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-2xl shadow-xl w-full max-w-md overflow-hidden">
                        <div className="p-6 border-b flex items-center justify-between">
                            <div className="flex items-center gap-3">
                                <div className="w-12 h-12 rounded-xl bg-primary-100 flex items-center justify-center text-primary-700 font-bold text-lg">
                                    {selectedUser.name?.charAt(0) || '?'}
                                </div>
                                <div>
                                    <h3 className="text-lg font-bold text-slate-900">{selectedUser.name}</h3>
                                    <span className={getRoleBadge(selectedUser.role)}>{selectedUser.role?.toUpperCase()}</span>
                                </div>
                            </div>
                            <button
                                onClick={() => setSelectedUser(null)}
                                className="p-2 hover:bg-slate-100 rounded-lg transition-all"
                            >
                                <XCircle size={20} className="text-slate-400" />
                            </button>
                        </div>
                        <div className="p-6 space-y-4">
                            <div>
                                <span className="text-xs text-slate-400 uppercase tracking-wider">Email</span>
                                <p className="font-medium text-slate-900 flex items-center gap-2">
                                    <Mail size={16} className="text-slate-400" /> {selectedUser.email}
                                </p>
                            </div>
                            <div>
                                <span className="text-xs text-slate-400 uppercase tracking-wider">Mobile</span>
                                <p className="font-medium text-slate-900 flex items-center gap-2">
                                    <Phone size={16} className="text-slate-400" /> {selectedUser.mobile || 'N/A'}
                                </p>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <span className="text-xs text-slate-400 uppercase tracking-wider">Status</span>
                                    <p className={`font-bold ${selectedUser.status === 'active' || !selectedUser.status ? 'text-green-600' : 'text-red-600'}`}>
                                        {selectedUser.status || 'Active'}
                                    </p>
                                </div>
                                <div>
                                    <span className="text-xs text-slate-400 uppercase tracking-wider">Gender</span>
                                    <p className="font-medium text-slate-900 capitalize">{selectedUser.gender || 'N/A'}</p>
                                </div>
                            </div>
                            <div>
                                <span className="text-xs text-slate-400 uppercase tracking-wider">Joined</span>
                                <p className="font-medium text-slate-900">
                                    {new Date(selectedUser.createdAt).toLocaleDateString()} at {new Date(selectedUser.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                </p>
                            </div>
                            {selectedUser.verificationStatus && (
                                <div>
                                    <span className="text-xs text-slate-400 uppercase tracking-wider">Verification</span>
                                    <p className="font-medium text-slate-900 capitalize">{selectedUser.verificationStatus}</p>
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            )}

            {/* Suspend/Activate Modal */}
            {suspendModal.open && suspendModal.user && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-2xl shadow-xl w-full max-w-md overflow-hidden">
                        <div className={`p-6 border-b ${suspendModal.user.status === 'suspended' ? 'bg-green-50' : 'bg-orange-50'}`}>
                            <div className="flex items-center gap-3">
                                <div className={`p-3 rounded-xl ${suspendModal.user.status === 'suspended' ? 'bg-green-100' : 'bg-orange-100'}`}>
                                    {suspendModal.user.status === 'suspended' 
                                        ? <CheckCircle2 size={24} className="text-green-600" />
                                        : <Ban size={24} className="text-orange-600" />
                                    }
                                </div>
                                <div>
                                    <h3 className="text-lg font-bold text-slate-900">
                                        {suspendModal.user.status === 'suspended' ? 'Activate User' : 'Suspend User'}
                                    </h3>
                                    <p className="text-sm text-slate-500">{suspendModal.user.name}</p>
                                </div>
                            </div>
                        </div>
                        <div className="p-6">
                            <p className="text-slate-600 mb-4">
                                {suspendModal.user.status === 'suspended' 
                                    ? `Are you sure you want to reactivate ${suspendModal.user.name}'s account? They will be able to access the system again.`
                                    : `Are you sure you want to suspend ${suspendModal.user.name}'s account? They will not be able to access the system until reactivated.`
                                }
                            </p>
                            <div className="bg-slate-50 p-4 rounded-xl mb-4">
                                <div className="flex items-center gap-3">
                                    <div className="w-10 h-10 rounded-full bg-slate-200 flex items-center justify-center font-bold">
                                        {suspendModal.user.name?.charAt(0) || '?'}
                                    </div>
                                    <div>
                                        <p className="font-semibold text-slate-900">{suspendModal.user.name}</p>
                                        <p className="text-xs text-slate-500">{suspendModal.user.email}</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div className="p-6 border-t bg-slate-50 flex gap-3">
                            <button
                                onClick={() => setSuspendModal({ open: false, user: null })}
                                className="flex-1 px-4 py-3 border border-slate-200 rounded-xl font-semibold text-slate-600 hover:bg-white transition-all"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleSuspendUser}
                                disabled={actionLoading}
                                className={`flex-1 px-4 py-3 rounded-xl font-semibold transition-all disabled:opacity-50 flex items-center justify-center gap-2 ${
                                    suspendModal.user.status === 'suspended'
                                        ? 'bg-green-600 text-white hover:bg-green-700'
                                        : 'bg-orange-600 text-white hover:bg-orange-700'
                                }`}
                            >
                                {actionLoading ? (
                                    <Loader2 size={18} className="animate-spin" />
                                ) : suspendModal.user.status === 'suspended' ? (
                                    <CheckCircle2 size={18} />
                                ) : (
                                    <Ban size={18} />
                                )}
                                {suspendModal.user.status === 'suspended' ? 'Activate' : 'Suspend'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Invite Staff Modal */}
            {inviteModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-2xl shadow-xl w-full max-w-md overflow-hidden">
                        <div className="p-6 border-b bg-primary-50">
                            <div className="flex items-center gap-3">
                                <div className="p-3 rounded-xl bg-primary-100">
                                    <UserPlus size={24} className="text-primary-600" />
                                </div>
                                <div>
                                    <h3 className="text-lg font-bold text-slate-900">Invite Staff Member</h3>
                                    <p className="text-sm text-slate-500">Add a new nurse or doctor to the system</p>
                                </div>
                            </div>
                        </div>
                        <form onSubmit={handleInviteStaff} className="p-6 space-y-4" autoComplete="off">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Full Name</label>
                                <input
                                    type="text"
                                    required
                                    value={inviteForm.name}
                                    onChange={(e) => setInviteForm({...inviteForm, name: e.target.value})}
                                    className="w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                                    placeholder="Enter full name"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Email</label>
                                <input
                                    type="email"
                                    required
                                    value={inviteForm.email}
                                    onChange={(e) => setInviteForm({...inviteForm, email: e.target.value})}
                                    className="w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                                    placeholder="email@example.com"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Mobile</label>
                                <input
                                    type="text"
                                    required
                                    value={inviteForm.mobile}
                                    onChange={(e) => setInviteForm({...inviteForm, mobile: e.target.value})}
                                    className="w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                                    placeholder="01xxxxxxxxx"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Password</label>
                                <input
                                    type="password"
                                    required
                                    value={inviteForm.password}
                                    onChange={(e) => setInviteForm({...inviteForm, password: e.target.value})}
                                    className="w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                                    placeholder="Create a password"
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Role</label>
                                    <select
                                        value={inviteForm.role}
                                        onChange={(e) => setInviteForm({...inviteForm, role: e.target.value})}
                                        className="w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary-500"
                                    >
                                        <option value="nurse">Nurse</option>
                                        <option value="doctor">Doctor</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Gender</label>
                                    <select
                                        value={inviteForm.gender}
                                        onChange={(e) => setInviteForm({...inviteForm, gender: e.target.value})}
                                        className="w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary-500"
                                    >
                                        <option value="male">Male</option>
                                        <option value="female">Female</option>
                                    </select>
                                </div>
                            </div>
                            <div className="flex gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={() => setInviteModal(false)}
                                    className="flex-1 px-4 py-3 border border-slate-200 rounded-xl font-semibold text-slate-600 hover:bg-slate-50 transition-all"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    disabled={inviteLoading}
                                    className="flex-1 px-4 py-3 bg-primary-600 text-white rounded-xl font-semibold hover:bg-primary-700 transition-all disabled:opacity-50 flex items-center justify-center gap-2"
                                >
                                    {inviteLoading ? <Loader2 size={18} className="animate-spin" /> : <UserPlus size={18} />}
                                    Add Staff
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Users;
