import React, { useState } from 'react';
import {
    Settings as SettingsIcon,
    Bell,
    Shield,
    Palette,
    Globe,
    Mail,
    Smartphone,
    Save,
    RefreshCw,
    CheckCircle2
} from 'lucide-react';

const Settings = () => {
    const [saved, setSaved] = useState(false);
    const [settings, setSettings] = useState({
        notifications: {
            emailAlerts: true,
            pushNotifications: true,
            newUserAlerts: true,
            bookingAlerts: true,
            paymentAlerts: true
        },
        security: {
            twoFactorAuth: false,
            sessionTimeout: 30,
            ipWhitelist: false
        },
        appearance: {
            theme: 'light',
            compactMode: false,
            showAnimations: true
        },
        system: {
            maintenanceMode: false,
            debugMode: false,
            autoBackup: true
        }
    });

    const handleToggle = (category, key) => {
        setSettings(prev => ({
            ...prev,
            [category]: {
                ...prev[category],
                [key]: !prev[category][key]
            }
        }));
    };

    const handleSave = () => {
        // Save to backend
        setSaved(true);
        setTimeout(() => setSaved(false), 3000);
    };

    const ToggleSwitch = ({ enabled, onClick }) => (
        <button
            onClick={onClick}
            className={`relative w-12 h-6 rounded-full transition-all ${
                enabled ? 'bg-primary-600' : 'bg-slate-200'
            }`}
        >
            <span className={`absolute top-1 w-4 h-4 bg-white rounded-full transition-all shadow-sm ${
                enabled ? 'left-7' : 'left-1'
            }`}></span>
        </button>
    );

    const SettingItem = ({ icon: Icon, label, description, enabled, onClick, iconColor = 'text-slate-400' }) => (
        <div className="flex items-center justify-between py-4 border-b border-slate-100 last:border-0">
            <div className="flex items-center gap-4">
                <div className="p-2 rounded-lg bg-slate-50">
                    <Icon size={20} className={iconColor} />
                </div>
                <div>
                    <p className="font-semibold text-slate-900">{label}</p>
                    <p className="text-sm text-slate-500">{description}</p>
                </div>
            </div>
            <ToggleSwitch enabled={enabled} onClick={onClick} />
        </div>
    );

    return (
        <div className="space-y-6 max-w-4xl">
            {/* Header */}
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-slate-900 tracking-tight">Settings</h1>
                    <p className="text-slate-500 text-sm mt-1 font-medium">Manage your system preferences and configurations</p>
                </div>
                <button
                    onClick={handleSave}
                    className={`px-5 py-3 rounded-xl text-sm font-semibold transition-all flex items-center gap-2 ${
                        saved 
                            ? 'bg-green-600 text-white'
                            : 'bg-primary-600 text-white hover:bg-primary-700'
                    }`}
                >
                    {saved ? <CheckCircle2 size={18} /> : <Save size={18} />}
                    {saved ? 'Saved!' : 'Save Changes'}
                </button>
            </div>

            {/* Notification Settings */}
            <div className="bg-white rounded-2xl border shadow-sm overflow-hidden">
                <div className="p-6 border-b bg-slate-50/50">
                    <div className="flex items-center gap-3">
                        <div className="p-2 rounded-xl bg-blue-100">
                            <Bell size={20} className="text-blue-600" />
                        </div>
                        <div>
                            <h2 className="font-bold text-slate-900">Notifications</h2>
                            <p className="text-sm text-slate-500">Configure how you receive alerts</p>
                        </div>
                    </div>
                </div>
                <div className="p-6">
                    <SettingItem 
                        icon={Mail} 
                        label="Email Alerts" 
                        description="Receive important alerts via email"
                        enabled={settings.notifications.emailAlerts}
                        onClick={() => handleToggle('notifications', 'emailAlerts')}
                        iconColor="text-blue-500"
                    />
                    <SettingItem 
                        icon={Smartphone} 
                        label="Push Notifications" 
                        description="Get real-time push notifications"
                        enabled={settings.notifications.pushNotifications}
                        onClick={() => handleToggle('notifications', 'pushNotifications')}
                        iconColor="text-green-500"
                    />
                    <SettingItem 
                        icon={Bell} 
                        label="New User Alerts" 
                        description="Notify when new users register"
                        enabled={settings.notifications.newUserAlerts}
                        onClick={() => handleToggle('notifications', 'newUserAlerts')}
                        iconColor="text-purple-500"
                    />
                    <SettingItem 
                        icon={Bell} 
                        label="Booking Alerts" 
                        description="Notify on new bookings"
                        enabled={settings.notifications.bookingAlerts}
                        onClick={() => handleToggle('notifications', 'bookingAlerts')}
                        iconColor="text-orange-500"
                    />
                </div>
            </div>

            {/* Security Settings */}
            <div className="bg-white rounded-2xl border shadow-sm overflow-hidden">
                <div className="p-6 border-b bg-slate-50/50">
                    <div className="flex items-center gap-3">
                        <div className="p-2 rounded-xl bg-red-100">
                            <Shield size={20} className="text-red-600" />
                        </div>
                        <div>
                            <h2 className="font-bold text-slate-900">Security</h2>
                            <p className="text-sm text-slate-500">Manage security settings</p>
                        </div>
                    </div>
                </div>
                <div className="p-6">
                    <SettingItem 
                        icon={Shield} 
                        label="Two-Factor Authentication" 
                        description="Add an extra layer of security"
                        enabled={settings.security.twoFactorAuth}
                        onClick={() => handleToggle('security', 'twoFactorAuth')}
                        iconColor="text-red-500"
                    />
                    <SettingItem 
                        icon={Globe} 
                        label="IP Whitelist" 
                        description="Restrict access to specific IPs"
                        enabled={settings.security.ipWhitelist}
                        onClick={() => handleToggle('security', 'ipWhitelist')}
                        iconColor="text-slate-500"
                    />
                </div>
            </div>

            {/* System Settings */}
            <div className="bg-white rounded-2xl border shadow-sm overflow-hidden">
                <div className="p-6 border-b bg-slate-50/50">
                    <div className="flex items-center gap-3">
                        <div className="p-2 rounded-xl bg-purple-100">
                            <SettingsIcon size={20} className="text-purple-600" />
                        </div>
                        <div>
                            <h2 className="font-bold text-slate-900">System</h2>
                            <p className="text-sm text-slate-500">System-wide configurations</p>
                        </div>
                    </div>
                </div>
                <div className="p-6">
                    <SettingItem 
                        icon={Palette} 
                        label="Show Animations" 
                        description="Enable smooth transitions and animations"
                        enabled={settings.appearance.showAnimations}
                        onClick={() => handleToggle('appearance', 'showAnimations')}
                        iconColor="text-pink-500"
                    />
                    <SettingItem 
                        icon={RefreshCw} 
                        label="Auto Backup" 
                        description="Automatically backup data daily"
                        enabled={settings.system.autoBackup}
                        onClick={() => handleToggle('system', 'autoBackup')}
                        iconColor="text-green-500"
                    />
                    <SettingItem 
                        icon={Shield} 
                        label="Maintenance Mode" 
                        description="Put the system in maintenance mode"
                        enabled={settings.system.maintenanceMode}
                        onClick={() => handleToggle('system', 'maintenanceMode')}
                        iconColor="text-yellow-500"
                    />
                </div>
            </div>
        </div>
    );
};

export default Settings;
