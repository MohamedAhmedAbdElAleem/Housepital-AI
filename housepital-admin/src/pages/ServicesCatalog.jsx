import React, { useEffect, useMemo, useState } from 'react';
import { Plus, RefreshCw, Search, Pencil, Archive, Power } from 'lucide-react';
import api from '../services/api';

const initialForm = {
    name: '',
    category: '',
    price: '',
    durationMinutes: '',
    providerId: '',
    description: '',
    isActive: true,
};

const slugify = (value = '') =>
    String(value)
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9]+/g, '_')
        .replace(/^_+|_+$/g, '');

const getProviderId = (service) => {
    const provider = service?.providerId;
    if (!provider) return '';
    return typeof provider === 'string' ? provider : provider._id || '';
};

const getProviderName = (service) => {
    const provider = service?.providerId;
    if (!provider || typeof provider === 'string') return 'Unknown nurse';
    return provider.user?.name || provider.specialization || 'Unknown nurse';
};

const formatError = (err, fallback) =>
    err?.response?.data?.message || err?.message || fallback;

const ServicesCatalog = () => {
    const [services, setServices] = useState([]);
    const [providers, setProviders] = useState([]);
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [error, setError] = useState('');
    const [notice, setNotice] = useState('');
    const [search, setSearch] = useState('');
    const [statusFilter, setStatusFilter] = useState('all');
    const [editingId, setEditingId] = useState(null);
    const [form, setForm] = useState(initialForm);

    const loadData = async () => {
        setLoading(true);
        setError('');
        try {
            const [servicesRes, providersRes] = await Promise.all([
                api.get('/api/services/admin/home-nursing'),
                api.get('/api/services/admin/home-nursing/providers'),
            ]);

            setServices(servicesRes.data?.data || []);
            setProviders(providersRes.data?.data || []);
        } catch (err) {
            setError(formatError(err, 'Failed to load service catalog'));
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadData();
    }, []);

    const filteredServices = useMemo(() => {
        const searchLower = search.trim().toLowerCase();

        return services.filter((service) => {
            const matchesStatus =
                statusFilter === 'all' ||
                (statusFilter === 'active' ? service.isActive : !service.isActive);

            const matchesSearch =
                !searchLower ||
                service.name?.toLowerCase().includes(searchLower) ||
                service.category?.toLowerCase().includes(searchLower) ||
                getProviderName(service).toLowerCase().includes(searchLower);

            return matchesStatus && matchesSearch;
        });
    }, [services, search, statusFilter]);

    const resetForm = () => {
        setForm(initialForm);
        setEditingId(null);
    };

    const handleChange = (field, value) => {
        setForm((prev) => ({ ...prev, [field]: value }));
    };

    const handleEdit = (service) => {
        setEditingId(service._id);
        setForm({
            name: service.name || '',
            category: service.category || '',
            price: service.price ?? '',
            durationMinutes: service.durationMinutes ?? '',
            providerId: getProviderId(service),
            description: service.description || '',
            isActive: Boolean(service.isActive),
        });
        setNotice('');
        setError('');
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        setNotice('');

        if (!form.name.trim() || !form.providerId || !form.price || !form.durationMinutes) {
            setError('Please fill name, provider, price, and duration.');
            return;
        }

        const payload = {
            name: form.name.trim(),
            category: slugify(form.category || form.name),
            price: Number(form.price),
            durationMinutes: Number(form.durationMinutes),
            providerId: form.providerId,
            description: form.description.trim() || undefined,
            isActive: form.isActive,
        };

        setSubmitting(true);
        try {
            if (editingId) {
                await api.put(`/api/services/admin/home-nursing/${editingId}`, payload);
                setNotice('Service updated successfully.');
            } else {
                await api.post('/api/services/admin/home-nursing', payload);
                setNotice('Service created successfully.');
            }

            await loadData();
            resetForm();
        } catch (err) {
            setError(formatError(err, 'Failed to save service'));
        } finally {
            setSubmitting(false);
        }
    };

    const toggleActive = async (service) => {
        setError('');
        setNotice('');
        try {
            await api.put(`/api/services/admin/home-nursing/${service._id}`, {
                isActive: !service.isActive,
            });
            setNotice(`Service ${service.isActive ? 'deactivated' : 'activated'} successfully.`);
            await loadData();
        } catch (err) {
            setError(formatError(err, 'Failed to update service status'));
        }
    };

    const archiveService = async (service) => {
        if (!window.confirm(`Archive ${service.name}?`)) return;

        setError('');
        setNotice('');
        try {
            await api.delete(`/api/services/admin/home-nursing/${service._id}`);
            setNotice('Service archived successfully.');
            await loadData();
        } catch (err) {
            setError(formatError(err, 'Failed to archive service'));
        }
    };

    return (
        <div className="space-y-6">
            <section className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
                <div className="flex flex-wrap items-center justify-between gap-4">
                    <div>
                        <h2 className="text-2xl font-bold text-slate-900">Home Nursing Services Catalog</h2>
                        <p className="text-sm text-slate-500 mt-1">
                            Create and manage service definitions used by the customer matching flow.
                        </p>
                    </div>
                    <button
                        onClick={loadData}
                        className="inline-flex items-center gap-2 px-4 py-2 rounded-xl border border-slate-300 text-slate-700 hover:bg-slate-50"
                    >
                        <RefreshCw size={16} /> Refresh
                    </button>
                </div>

                {(error || notice) && (
                    <div className="mt-4 space-y-2">
                        {error && (
                            <div className="px-4 py-2 rounded-xl bg-red-50 border border-red-200 text-red-700 text-sm">
                                {error}
                            </div>
                        )}
                        {notice && (
                            <div className="px-4 py-2 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-sm">
                                {notice}
                            </div>
                        )}
                    </div>
                )}
            </section>

            <section className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
                <div className="flex items-center gap-2 mb-4">
                    <Plus size={18} className="text-emerald-600" />
                    <h3 className="text-lg font-bold text-slate-900">
                        {editingId ? 'Edit Service' : 'Create Service'}
                    </h3>
                </div>

                <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <input
                        value={form.name}
                        onChange={(e) => handleChange('name', e.target.value)}
                        placeholder="Service Name"
                        className="px-3 py-2 rounded-xl border border-slate-300"
                    />
                    <input
                        value={form.category}
                        onChange={(e) => handleChange('category', e.target.value)}
                        placeholder="Category (optional, auto from name)"
                        className="px-3 py-2 rounded-xl border border-slate-300"
                    />
                    <input
                        value={form.price}
                        onChange={(e) => handleChange('price', e.target.value)}
                        placeholder="Price"
                        type="number"
                        min="0"
                        className="px-3 py-2 rounded-xl border border-slate-300"
                    />
                    <input
                        value={form.durationMinutes}
                        onChange={(e) => handleChange('durationMinutes', e.target.value)}
                        placeholder="Duration Minutes"
                        type="number"
                        min="5"
                        className="px-3 py-2 rounded-xl border border-slate-300"
                    />
                    <select
                        value={form.providerId}
                        onChange={(e) => handleChange('providerId', e.target.value)}
                        className="px-3 py-2 rounded-xl border border-slate-300"
                    >
                        <option value="">Select Nurse Provider</option>
                        {providers.map((provider) => (
                            <option key={provider.id} value={provider.id}>
                                {provider.name} {provider.specialization ? `- ${provider.specialization}` : ''}
                            </option>
                        ))}
                    </select>
                    <label className="flex items-center gap-2 px-3 py-2 rounded-xl border border-slate-300 text-sm text-slate-700">
                        <input
                            type="checkbox"
                            checked={form.isActive}
                            onChange={(e) => handleChange('isActive', e.target.checked)}
                        />
                        Active
                    </label>
                    <textarea
                        value={form.description}
                        onChange={(e) => handleChange('description', e.target.value)}
                        placeholder="Description (optional)"
                        className="md:col-span-2 px-3 py-2 rounded-xl border border-slate-300 min-h-24"
                    />

                    <div className="md:col-span-2 flex gap-3">
                        <button
                            type="submit"
                            disabled={submitting}
                            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-emerald-600 text-white hover:bg-emerald-700 disabled:opacity-60"
                        >
                            <Plus size={16} /> {submitting ? 'Saving...' : editingId ? 'Save Changes' : 'Create Service'}
                        </button>
                        {editingId && (
                            <button
                                type="button"
                                onClick={resetForm}
                                className="px-4 py-2 rounded-xl border border-slate-300 text-slate-700 hover:bg-slate-50"
                            >
                                Cancel Edit
                            </button>
                        )}
                    </div>
                </form>
            </section>

            <section className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
                <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
                    <h3 className="text-lg font-bold text-slate-900">Current Services</h3>
                    <div className="flex gap-2">
                        <div className="flex items-center gap-2 px-3 py-2 rounded-xl border border-slate-300 bg-white">
                            <Search size={15} className="text-slate-400" />
                            <input
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                placeholder="Search"
                                className="outline-none text-sm"
                            />
                        </div>
                        <select
                            value={statusFilter}
                            onChange={(e) => setStatusFilter(e.target.value)}
                            className="px-3 py-2 rounded-xl border border-slate-300 text-sm"
                        >
                            <option value="all">All</option>
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                        </select>
                    </div>
                </div>

                {loading ? (
                    <div className="py-10 text-center text-slate-500">Loading services...</div>
                ) : filteredServices.length === 0 ? (
                    <div className="py-10 text-center text-slate-500">No services found.</div>
                ) : (
                    <div className="overflow-auto">
                        <table className="min-w-full text-sm">
                            <thead>
                                <tr className="text-left text-slate-500 border-b border-slate-200">
                                    <th className="py-3 pr-4">Name</th>
                                    <th className="py-3 pr-4">Category</th>
                                    <th className="py-3 pr-4">Price</th>
                                    <th className="py-3 pr-4">Duration</th>
                                    <th className="py-3 pr-4">Provider</th>
                                    <th className="py-3 pr-4">Status</th>
                                    <th className="py-3">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {filteredServices.map((service) => (
                                    <tr key={service._id} className="border-b border-slate-100">
                                        <td className="py-3 pr-4 font-semibold text-slate-800">{service.name}</td>
                                        <td className="py-3 pr-4 text-slate-600">{service.category}</td>
                                        <td className="py-3 pr-4 text-slate-600">{service.price} EGP</td>
                                        <td className="py-3 pr-4 text-slate-600">{service.durationMinutes} min</td>
                                        <td className="py-3 pr-4 text-slate-600">{getProviderName(service)}</td>
                                        <td className="py-3 pr-4">
                                            <span className={`px-2 py-1 rounded-full text-xs font-semibold ${service.isActive ? 'bg-emerald-50 text-emerald-700' : 'bg-slate-100 text-slate-600'}`}>
                                                {service.isActive ? 'Active' : 'Inactive'}
                                            </span>
                                        </td>
                                        <td className="py-3">
                                            <div className="flex items-center gap-2">
                                                <button
                                                    onClick={() => handleEdit(service)}
                                                    className="inline-flex items-center gap-1 px-2.5 py-1.5 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-50"
                                                >
                                                    <Pencil size={14} /> Edit
                                                </button>
                                                <button
                                                    onClick={() => toggleActive(service)}
                                                    className="inline-flex items-center gap-1 px-2.5 py-1.5 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-50"
                                                >
                                                    <Power size={14} /> {service.isActive ? 'Disable' : 'Enable'}
                                                </button>
                                                <button
                                                    onClick={() => archiveService(service)}
                                                    className="inline-flex items-center gap-1 px-2.5 py-1.5 rounded-lg border border-red-200 text-red-600 hover:bg-red-50"
                                                >
                                                    <Archive size={14} /> Archive
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </section>
        </div>
    );
};

export default ServicesCatalog;
