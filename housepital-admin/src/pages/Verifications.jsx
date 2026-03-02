import React, { useState, useEffect } from 'react';
import api from '../services/api';
import {
    ShieldCheck,
    ShieldX,
    User,
    Mail,
    Phone,
    FileText,
    Award,
    Clock,
    AlertCircle,
    CheckCircle2,
    XCircle,
    Loader2,
    ExternalLink,
    Stethoscope,
    Heart
} from 'lucide-react';

const Verifications = () => {
    const [verifications, setVerifications] = useState([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState('all');
    const [actionLoading, setActionLoading] = useState(null);
    const [rejectModal, setRejectModal] = useState({ open: false, item: null });
    const [rejectReason, setRejectReason] = useState('');
    const [stats, setStats] = useState({ nurses: 0, doctors: 0 });

    useEffect(() => {
        fetchVerifications();
    }, []);

    const fetchVerifications = async () => {
        try {
            setLoading(true);
            const response = await api.get('/api/admin/insights/pending-verifications');
            if (response.data.success) {
                setVerifications(response.data.verifications);
                setStats({
                    nurses: response.data.nurses,
                    doctors: response.data.doctors
                });
            }
        } catch (error) {
            console.error('Error fetching verifications:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleAction = async (item, action) => {
        if (action === 'reject') {
            setRejectModal({ open: true, item });
            return;
        }

        try {
            setActionLoading(item.id);
            const response = await api.post(`/api/admin/insights/verify/${item.type}/${item.id}`, {
                action: 'approve'
            });
            
            if (response.data.success) {
                setVerifications(prev => prev.filter(v => v.id !== item.id));
                setStats(prev => ({
                    ...prev,
                    [item.type === 'nurse' ? 'nurses' : 'doctors']: prev[item.type === 'nurse' ? 'nurses' : 'doctors'] - 1
                }));
            }
        } catch (error) {
            console.error('Error approving:', error);
            alert('Error: ' + (error.response?.data?.message || 'Failed to approve'));
        } finally {
            setActionLoading(null);
        }
    };

    const handleReject = async () => {
        const item = rejectModal.item;
        if (!item) return;

        try {
            setActionLoading(item.id);
            const response = await api.post(`/api/admin/insights/verify/${item.type}/${item.id}`, {
                action: 'reject',
                reason: rejectReason
            });
            
            if (response.data.success) {
                setVerifications(prev => prev.filter(v => v.id !== item.id));
                setStats(prev => ({
                    ...prev,
                    [item.type === 'nurse' ? 'nurses' : 'doctors']: prev[item.type === 'nurse' ? 'nurses' : 'doctors'] - 1
                }));
                setRejectModal({ open: false, item: null });
                setRejectReason('');
            }
        } catch (error) {
            console.error('Error rejecting:', error);
            alert('Error: ' + (error.response?.data?.message || 'Failed to reject'));
        } finally {
            setActionLoading(null);
        }
    };

    const filteredVerifications = filter === 'all' 
        ? verifications 
        : verifications.filter(v => v.type === filter);

    const getTypeIcon = (type) => {
        return type === 'nurse' 
            ? <Heart className="text-pink-500" size={18} />
            : <Stethoscope className="text-blue-500" size={18} />;
    };

    const getTypeBadge = (type) => {
        return type === 'nurse'
            ? 'bg-pink-100 text-pink-700 border-pink-200'
            : 'bg-blue-100 text-blue-700 border-blue-200';
    };

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-slate-900 tracking-tight">Staff Verifications</h1>
                    <p className="text-slate-500 text-sm mt-1 font-medium">Review and approve nurse & doctor applications</p>
                </div>
                <button
                    onClick={fetchVerifications}
                    className="p-3 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 hover:border-primary-300 transition-all shadow-sm hover:shadow-md active:scale-95 group"
                >
                    <Clock size={20} className="text-slate-600 group-hover:text-primary-600 transition-colors" />
                </button>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm hover:shadow-md transition-all flex items-center justify-between group">
                    <div>
                        <span className="text-sm font-semibold text-slate-500 block mb-1">Total Pending</span>
                        <span className="text-3xl font-bold text-slate-900">{verifications.length}</span>
                    </div>
                    <div className="p-3 bg-amber-50 rounded-xl border border-amber-100 group-hover:scale-110 transition-transform">
                        <AlertCircle className="text-amber-500" size={24} />
                    </div>
                </div>
                <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm hover:shadow-md transition-all flex items-center justify-between group">
                    <div>
                        <span className="text-sm font-semibold text-slate-500 block mb-1">Pending Nurses</span>
                        <span className="text-3xl font-bold text-pink-600">{stats.nurses}</span>
                    </div>
                    <div className="p-3 bg-pink-50 rounded-xl border border-pink-100 group-hover:scale-110 transition-transform">
                        <Heart className="text-pink-500" size={24} />
                    </div>
                </div>
                <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm hover:shadow-md transition-all flex items-center justify-between group">
                    <div>
                        <span className="text-sm font-semibold text-slate-500 block mb-1">Pending Doctors</span>
                        <span className="text-3xl font-bold text-blue-600">{stats.doctors}</span>
                    </div>
                    <div className="p-3 bg-blue-50 rounded-xl border border-blue-100 group-hover:scale-110 transition-transform">
                        <Stethoscope className="text-blue-500" size={24} />
                    </div>
                </div>
            </div>

            {/* Filters */}
            <div className="bg-white p-4 rounded-2xl border shadow-sm flex gap-2">
                {['all', 'nurse', 'doctor'].map((type) => (
                    <button
                        key={type}
                        onClick={() => setFilter(type)}
                        className={`px-4 py-2 rounded-xl text-sm font-medium transition-all ${
                            filter === type
                                ? 'bg-primary-600 text-white'
                                : 'bg-slate-50 text-slate-600 hover:bg-slate-100'
                        }`}
                    >
                        {type.charAt(0).toUpperCase() + type.slice(1)}s
                    </button>
                ))}
            </div>

            {/* Verifications List */}
            <div className="space-y-4">
                {loading ? (
                    <div className="bg-white rounded-2xl border p-12 flex flex-col items-center justify-center">
                        <Loader2 className="w-12 h-12 text-primary-500 animate-spin mb-4" />
                        <p className="text-slate-500 font-medium">Loading pending verifications...</p>
                    </div>
                ) : filteredVerifications.length === 0 ? (
                    <div className="bg-white rounded-2xl border p-12 flex flex-col items-center justify-center">
                        <div className="w-16 h-16 bg-green-50 rounded-full flex items-center justify-center mb-4">
                            <CheckCircle2 className="text-green-500" size={32} />
                        </div>
                        <h3 className="text-lg font-bold text-slate-900 mb-1">All Caught Up!</h3>
                        <p className="text-slate-500">No pending verifications at the moment.</p>
                    </div>
                ) : (
                    filteredVerifications.map((item) => (
                        <div 
                            key={item.id} 
                            className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden hover:shadow-md transition-all"
                        >
                            {/* Header */}
                            <div className="p-6 border-b border-slate-100">
                                <div className="flex items-start justify-between">
                                    <div className="flex items-center gap-4">
                                        <div className="w-14 h-14 rounded-xl bg-slate-100 flex items-center justify-center text-slate-600 font-bold text-lg shrink-0">
                                            {item.profilePicture ? (
                                                <img src={item.profilePicture} alt="" className="w-full h-full rounded-xl object-cover" />
                                            ) : (
                                                item.name?.charAt(0) || '?'
                                            )}
                                        </div>
                                        <div>
                                            <div className="flex items-center gap-2 mb-1">
                                                <h3 className="text-lg font-bold text-slate-900">{item.name}</h3>
                                                <span className={`px-2 py-0.5 rounded-full text-xs font-bold border ${getTypeBadge(item.type)}`}>
                                                    {item.type.toUpperCase()}
                                                </span>
                                            </div>
                                            <div className="flex items-center gap-4 text-sm text-slate-500">
                                                <span className="flex items-center gap-1"><Mail size={14} /> {item.email}</span>
                                                <span className="flex items-center gap-1"><Phone size={14} /> {item.mobile}</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div className="text-right">
                                        <span className="text-xs text-slate-400">Submitted</span>
                                        <p className="text-sm font-medium text-slate-600">
                                            {new Date(item.submittedAt).toLocaleDateString()}
                                        </p>
                                    </div>
                                </div>
                            </div>

                            {/* Details */}
                            <div className="p-6 bg-slate-50/50">
                                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
                                    <div>
                                        <span className="text-xs text-slate-400 uppercase tracking-wider">License</span>
                                        <p className="font-semibold text-slate-900">{item.licenseNumber || 'N/A'}</p>
                                    </div>
                                    <div>
                                        <span className="text-xs text-slate-400 uppercase tracking-wider">Specialization</span>
                                        <p className="font-semibold text-slate-900">{item.specialization || 'N/A'}</p>
                                    </div>
                                    <div>
                                        <span className="text-xs text-slate-400 uppercase tracking-wider">Experience</span>
                                        <p className="font-semibold text-slate-900">{item.yearsOfExperience || 0} years</p>
                                    </div>
                                    <div>
                                        <span className="text-xs text-slate-400 uppercase tracking-wider">Gender</span>
                                        <p className="font-semibold text-slate-900 capitalize">{item.gender || 'N/A'}</p>
                                    </div>
                                </div>

                                {item.bio && (
                                    <div className="mb-4">
                                        <span className="text-xs text-slate-400 uppercase tracking-wider">Bio</span>
                                        <p className="text-sm text-slate-600 mt-1">{item.bio}</p>
                                    </div>
                                )}

                                {/* Documents */}
                                <div className="flex flex-wrap gap-2 mb-4">
                                    {item.documents?.nationalId && (
                                        <a 
                                            href={item.documents.nationalId} 
                                            target="_blank" 
                                            rel="noopener noreferrer"
                                            className="flex items-center gap-1.5 px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-xs font-medium text-slate-600 hover:border-primary-300 hover:text-primary-600 transition-all"
                                        >
                                            <FileText size={14} /> National ID <ExternalLink size={12} />
                                        </a>
                                    )}
                                    {item.documents?.degree && (
                                        <a 
                                            href={item.documents.degree} 
                                            target="_blank" 
                                            rel="noopener noreferrer"
                                            className="flex items-center gap-1.5 px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-xs font-medium text-slate-600 hover:border-primary-300 hover:text-primary-600 transition-all"
                                        >
                                            <Award size={14} /> Degree <ExternalLink size={12} />
                                        </a>
                                    )}
                                    {item.documents?.license && (
                                        <a 
                                            href={item.documents.license} 
                                            target="_blank" 
                                            rel="noopener noreferrer"
                                            className="flex items-center gap-1.5 px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-xs font-medium text-slate-600 hover:border-primary-300 hover:text-primary-600 transition-all"
                                        >
                                            <ShieldCheck size={14} /> License <ExternalLink size={12} />
                                        </a>
                                    )}
                                </div>

                                {/* Actions */}
                                <div className="flex gap-3 pt-4 border-t border-slate-200">
                                    <button
                                        onClick={() => handleAction(item, 'approve')}
                                        disabled={actionLoading === item.id}
                                        className="flex-1 flex items-center justify-center gap-2 px-4 py-3 bg-green-600 text-white rounded-xl font-semibold hover:bg-green-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                                    >
                                        {actionLoading === item.id ? (
                                            <Loader2 size={18} className="animate-spin" />
                                        ) : (
                                            <CheckCircle2 size={18} />
                                        )}
                                        Approve
                                    </button>
                                    <button
                                        onClick={() => handleAction(item, 'reject')}
                                        disabled={actionLoading === item.id}
                                        className="flex-1 flex items-center justify-center gap-2 px-4 py-3 bg-white border border-red-300 text-red-600 rounded-xl font-semibold hover:bg-red-50 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                                    >
                                        <XCircle size={18} />
                                        Reject
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))
                )}
            </div>

            {/* Reject Modal */}
            {rejectModal.open && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-2xl shadow-xl w-full max-w-md overflow-hidden">
                        <div className="p-6 border-b">
                            <h3 className="text-lg font-bold text-slate-900">Reject Application</h3>
                            <p className="text-sm text-slate-500 mt-1">
                                Please provide a reason for rejecting {rejectModal.item?.name}'s application.
                            </p>
                        </div>
                        <div className="p-6">
                            <textarea
                                value={rejectReason}
                                onChange={(e) => setRejectReason(e.target.value)}
                                placeholder="Enter rejection reason..."
                                className="w-full h-32 px-4 py-3 border border-slate-200 rounded-xl resize-none focus:outline-none focus:ring-2 focus:ring-red-500/20 focus:border-red-500"
                            />
                        </div>
                        <div className="p-6 border-t bg-slate-50 flex gap-3">
                            <button
                                onClick={() => {
                                    setRejectModal({ open: false, item: null });
                                    setRejectReason('');
                                }}
                                className="flex-1 px-4 py-3 border border-slate-200 rounded-xl font-semibold text-slate-600 hover:bg-white transition-all"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleReject}
                                disabled={!rejectReason.trim() || actionLoading}
                                className="flex-1 px-4 py-3 bg-red-600 text-white rounded-xl font-semibold hover:bg-red-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                            >
                                {actionLoading ? (
                                    <Loader2 size={18} className="animate-spin" />
                                ) : (
                                    <XCircle size={18} />
                                )}
                                Reject
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Verifications;
