import React, { useState, useEffect } from 'react';
import api from '../services/api';
import { exportToCSV } from '../utils/exportUtils';
import {
    Calendar,
    Clock,
    MapPin,
    User,
    Phone,
    Mail,
    Filter,
    Search,
    Eye,
    XCircle,
    CheckCircle2,
    AlertCircle,
    Loader2,
    RefreshCw,
    Heart,
    DollarSign,
    Download
} from 'lucide-react';

const Bookings = () => {
    // ... state ...
    const [bookings, setBookings] = useState([]);
    const [loading, setLoading] = useState(true);
    const [statusFilter, setStatusFilter] = useState('all');
    const [typeFilter, setTypeFilter] = useState('all');
    const [search, setSearch] = useState('');
    const [selectedBooking, setSelectedBooking] = useState(null);
    const [stats, setStats] = useState({});

    // ... useEffect & functions ...
    useEffect(() => {
        fetchBookings();
    }, [statusFilter, typeFilter]);

    const fetchBookings = async () => {
        try {
            setLoading(true);
            const response = await api.get('/api/admin/insights/all-bookings', {
                params: { status: statusFilter, type: typeFilter }
            });
            if (response.data.success) {
                setBookings(response.data.bookings);
                // Calculate stats
                const allBookings = response.data.bookings;
                setStats({
                    total: response.data.total,
                    pending: allBookings.filter(b => ['pending', 'searching'].includes(b.status)).length,
                    inProgress: allBookings.filter(b => ['assigned', 'in-progress', 'confirmed'].includes(b.status)).length,
                    completed: allBookings.filter(b => b.status === 'completed').length,
                    cancelled: allBookings.filter(b => b.status === 'cancelled').length
                });
            }
        } catch (error) {
            console.error('Error fetching bookings:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleExport = () => {
        const exportData = bookings.map(b => ({
            id: b._id,
            Service: b.serviceName,
            Patient: b.patientName,
            Nurse: b.nurseName || 'Unassigned',
            Status: b.status,
            Price: b.servicePrice,
            Date: new Date(b.createdAt).toLocaleDateString(),
            Time: new Date(b.createdAt).toLocaleTimeString()
        }));
        exportToCSV(exportData, `bookings_${new Date().toISOString().split('T')[0]}`);
    };

    const getStatusBadge = (status) => {
        // ... implementation ...
        const styles = {
            pending: 'bg-yellow-100 text-yellow-700 border-yellow-200',
            searching: 'bg-orange-100 text-orange-700 border-orange-200',
            confirmed: 'bg-blue-100 text-blue-700 border-blue-200',
            assigned: 'bg-indigo-100 text-indigo-700 border-indigo-200',
            'in-progress': 'bg-green-100 text-green-700 border-green-200',
            completed: 'bg-emerald-100 text-emerald-700 border-emerald-200',
            cancelled: 'bg-red-100 text-red-700 border-red-200',
            'no-show': 'bg-gray-100 text-gray-700 border-gray-200'
        };
        return styles[status] || 'bg-gray-100 text-gray-700 border-gray-200';
    };

    const getStatusIcon = (status) => {
        switch (status) {
            case 'pending':
            case 'searching':
                return <Clock size={14} className="text-yellow-600" />;
            case 'assigned':
            case 'in-progress':
                return <AlertCircle size={14} className="text-green-600" />;
            case 'completed':
                return <CheckCircle2 size={14} className="text-emerald-600" />;
            case 'cancelled':
                return <XCircle size={14} className="text-red-600" />;
            default:
                return <Clock size={14} className="text-gray-600" />;
        }
    };

    const filteredBookings = bookings.filter(b => {
        if (!search) return true;
        const searchLower = search.toLowerCase();
        return (
            b.patientName?.toLowerCase().includes(searchLower) ||
            b.customerName?.toLowerCase().includes(searchLower) ||
            b.serviceName?.toLowerCase().includes(searchLower) ||
            b.nurseName?.toLowerCase().includes(searchLower)
        );
    });


    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-slate-900 tracking-tight">Booking Management</h1>
                    <p className="text-slate-500 text-sm mt-1 font-medium">Monitor and manage all service bookings</p>
                </div>
                <div className="flex gap-2">
                    <button
                        onClick={handleExport}
                        className="p-3 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 hover:text-primary-600 transition-all shadow-sm hover:shadow-md active:scale-95 flex items-center gap-2 text-slate-600 font-medium"
                    >
                        <Download size={20} />
                        <span className="hidden md:inline">Export</span>
                    </button>
                    <button
                        onClick={fetchBookings}
                        className="p-3 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 hover:border-primary-300 transition-all shadow-sm hover:shadow-md active:scale-95 group"
                    >
                        <RefreshCw size={20} className="text-slate-600 group-hover:text-primary-600 transition-colors" />
                    </button>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
                {[
                    { label: 'Total', value: stats.total || 0, color: 'slate', icon: '📊' },
                    { label: 'Pending', value: stats.pending || 0, color: 'yellow', icon: '⏳' },
                    { label: 'Active', value: stats.inProgress || 0, color: 'green', icon: '🚀' },
                    { label: 'Completed', value: stats.completed || 0, color: 'emerald', icon: '✅' },
                    { label: 'Cancelled', value: stats.cancelled || 0, color: 'red', icon: '❌' }
                ].map((stat, i) => (
                    <div key={i} className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-all">
                        <div className="flex items-center justify-between mb-2">
                            <span className="text-2xl">{stat.icon}</span>
                        </div>
                        <p className={`text-2xl font-bold text-${stat.color}-600`}>{stat.value}</p>
                        <p className="text-xs text-slate-500 font-medium">{stat.label}</p>
                    </div>
                ))}
            </div>

            {/* Filters */}
            <div className="bg-white p-4 rounded-2xl border shadow-sm flex flex-wrap gap-4 items-center justify-between">
                <div className="flex gap-2 flex-wrap">
                    <div className="flex gap-1">
                        {['all', 'pending', 'assigned', 'in-progress', 'completed', 'cancelled'].map((status) => (
                            <button
                                key={status}
                                onClick={() => setStatusFilter(status)}
                                className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-all ${
                                    statusFilter === status
                                        ? 'bg-primary-600 text-white'
                                        : 'bg-slate-50 text-slate-600 hover:bg-slate-100'
                                }`}
                            >
                                {status === 'all' ? 'All' : status.replace('-', ' ').replace(/\b\w/g, l => l.toUpperCase())}
                            </button>
                        ))}
                    </div>
                </div>
                <div className="relative min-w-[280px]">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
                    <input
                        type="text"
                        placeholder="Search patient, service, or nurse..."
                        className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 transition-all"
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                    />
                </div>
            </div>

            {/* Bookings Table */}
            <div className="bg-white rounded-2xl border shadow-sm overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full text-left">
                        <thead>
                            <tr className="bg-slate-50/50 border-b">
                                <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Service</th>
                                <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Patient</th>
                                <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Nurse</th>
                                <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Status</th>
                                <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Price</th>
                                <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Date</th>
                                <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y">
                            {loading ? (
                                [...Array(5)].map((_, idx) => (
                                    <tr key={idx} className="animate-pulse">
                                        <td className="px-6 py-5"><div className="h-4 bg-slate-100 rounded w-32"></div></td>
                                        <td className="px-6 py-5"><div className="h-4 bg-slate-100 rounded w-24"></div></td>
                                        <td className="px-6 py-5"><div className="h-4 bg-slate-100 rounded w-24"></div></td>
                                        <td className="px-6 py-5"><div className="h-4 bg-slate-100 rounded w-20"></div></td>
                                        <td className="px-6 py-5"><div className="h-4 bg-slate-100 rounded w-16"></div></td>
                                        <td className="px-6 py-5"><div className="h-4 bg-slate-100 rounded w-20"></div></td>
                                        <td className="px-6 py-5"><div className="h-4 bg-slate-100 rounded w-8 ml-auto"></div></td>
                                    </tr>
                                ))
                            ) : filteredBookings.length === 0 ? (
                                <tr>
                                    <td colSpan="7" className="px-6 py-12 text-center">
                                        <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-4">
                                            <Calendar size={32} className="text-slate-300" />
                                        </div>
                                        <p className="text-slate-500 font-medium">No bookings found</p>
                                    </td>
                                </tr>
                            ) : (
                                filteredBookings.map((booking) => (
                                    <tr key={booking.id} className="hover:bg-slate-50/50 transition-colors">
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-3">
                                                <div className="w-10 h-10 rounded-xl bg-primary-50 flex items-center justify-center shrink-0">
                                                    <Heart className="text-primary-500" size={18} />
                                                </div>
                                                <div>
                                                    <p className="font-semibold text-slate-900 text-sm">{booking.serviceName}</p>
                                                    <p className="text-xs text-slate-400 capitalize">{booking.type?.replace('_', ' ') || 'Nursing'}</p>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <p className="font-medium text-slate-900 text-sm">{booking.patientName}</p>
                                            <p className="text-xs text-slate-400">{booking.customerName}</p>
                                        </td>
                                        <td className="px-6 py-4">
                                            <p className="font-medium text-slate-900 text-sm">{booking.nurseName || '-'}</p>
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold border ${getStatusBadge(booking.status)}`}>
                                                {getStatusIcon(booking.status)}
                                                {booking.status?.replace('-', ' ').replace(/\b\w/g, l => l.toUpperCase())}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4">
                                            <p className="font-bold text-primary-600 text-sm">{booking.servicePrice} EGP</p>
                                        </td>
                                        <td className="px-6 py-4">
                                            <p className="text-sm text-slate-600">{new Date(booking.createdAt).toLocaleDateString()}</p>
                                            <p className="text-xs text-slate-400">{new Date(booking.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</p>
                                        </td>
                                        <td className="px-6 py-4 text-right">
                                            <button 
                                                onClick={() => setSelectedBooking(booking)}
                                                className="p-2 hover:bg-white rounded-lg border border-transparent hover:border-slate-200 transition-all"
                                            >
                                                <Eye size={18} className="text-slate-400 hover:text-primary-600" />
                                            </button>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Booking Details Modal */}
            {selectedBooking && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-2xl shadow-xl w-full max-w-lg overflow-hidden max-h-[90vh] overflow-y-auto">
                        <div className="p-6 border-b flex items-center justify-between">
                            <div>
                                <h3 className="text-lg font-bold text-slate-900">Booking Details</h3>
                                <p className="text-sm text-slate-500">{selectedBooking.serviceName}</p>
                            </div>
                            <button
                                onClick={() => setSelectedBooking(null)}
                                className="p-2 hover:bg-slate-100 rounded-lg transition-all"
                            >
                                <XCircle size={20} className="text-slate-400" />
                            </button>
                        </div>
                        <div className="p-6 space-y-4">
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <span className="text-xs text-slate-400 uppercase tracking-wider">Status</span>
                                    <p className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold border mt-1 ${getStatusBadge(selectedBooking.status)}`}>
                                        {getStatusIcon(selectedBooking.status)}
                                        {selectedBooking.status}
                                    </p>
                                </div>
                                <div>
                                    <span className="text-xs text-slate-400 uppercase tracking-wider">Price</span>
                                    <p className="font-bold text-primary-600 text-lg">{selectedBooking.servicePrice} EGP</p>
                                </div>
                            </div>
                            
                            <div className="border-t pt-4">
                                <h4 className="font-semibold text-slate-900 mb-3 flex items-center gap-2">
                                    <User size={16} /> Patient Info
                                </h4>
                                <div className="space-y-2 text-sm">
                                    <p><span className="text-slate-400">Name:</span> {selectedBooking.patientName}</p>
                                    <p><span className="text-slate-400">Customer:</span> {selectedBooking.customerName}</p>
                                    <p className="flex items-center gap-1"><Mail size={14} className="text-slate-400" /> {selectedBooking.customerEmail}</p>
                                    <p className="flex items-center gap-1"><Phone size={14} className="text-slate-400" /> {selectedBooking.customerMobile}</p>
                                </div>
                            </div>

                            {selectedBooking.nurseName && (
                                <div className="border-t pt-4">
                                    <h4 className="font-semibold text-slate-900 mb-3 flex items-center gap-2">
                                        <Heart size={16} /> Assigned Nurse
                                    </h4>
                                    <p className="text-sm">{selectedBooking.nurseName}</p>
                                </div>
                            )}

                            {selectedBooking.address && (
                                <div className="border-t pt-4">
                                    <h4 className="font-semibold text-slate-900 mb-3 flex items-center gap-2">
                                        <MapPin size={16} /> Address
                                    </h4>
                                    <p className="text-sm text-slate-600">
                                        {[selectedBooking.address.street, selectedBooking.address.area, selectedBooking.address.city].filter(Boolean).join(', ')}
                                    </p>
                                </div>
                            )}

                            {selectedBooking.visitPin && (
                                <div className="border-t pt-4">
                                    <h4 className="font-semibold text-slate-900 mb-3">Visit PIN</h4>
                                    <p className="text-2xl font-mono font-bold text-primary-600 tracking-widest">{selectedBooking.visitPin}</p>
                                </div>
                            )}

                            <div className="border-t pt-4">
                                <h4 className="font-semibold text-slate-900 mb-3 flex items-center gap-2">
                                    <Clock size={16} /> Timeline
                                </h4>
                                <div className="space-y-2 text-sm">
                                    <p><span className="text-slate-400">Created:</span> {new Date(selectedBooking.createdAt).toLocaleString()}</p>
                                    {selectedBooking.visitStartedAt && (
                                        <p><span className="text-slate-400">Started:</span> {new Date(selectedBooking.visitStartedAt).toLocaleString()}</p>
                                    )}
                                    {selectedBooking.visitEndedAt && (
                                        <p><span className="text-slate-400">Ended:</span> {new Date(selectedBooking.visitEndedAt).toLocaleString()}</p>
                                    )}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Bookings;
