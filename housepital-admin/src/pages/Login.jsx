import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';
import { ShieldCheck, Mail, Lock, AlertCircle, ArrowRight, Heart, Stethoscope, Activity, Zap } from 'lucide-react';

const Login = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const { login } = useAuth();
    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        setLoading(true);
        try {
            await login(email, password);
            navigate('/');
        } catch (err) {
            setError(err.message || 'Invalid credentials or access denied.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex" style={{ perspective: '2000px' }}>
            {/* Left Side - Ultra Cool Branding Panel */}
            <div className="hidden lg:flex lg:w-1/2 relative overflow-hidden bg-slate-900">
                {/* Animated Gradient Mesh Background */}
                <div className="absolute inset-0">
                    <div className="absolute inset-0 bg-gradient-to-br from-emerald-600 via-teal-500 to-cyan-400 opacity-90"></div>
                    <div className="absolute inset-0 bg-gradient-to-tl from-green-400/50 via-transparent to-emerald-700/50 animate-pulse" style={{ animationDuration: '4s' }}></div>
                </div>

                {/* Animated Glowing Orbs */}
                <div className="absolute inset-0">
                    <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-cyan-400/30 rounded-full blur-3xl animate-pulse" style={{ animationDuration: '3s' }}></div>
                    <div className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-emerald-300/40 rounded-full blur-3xl animate-pulse" style={{ animationDuration: '5s', animationDelay: '1s' }}></div>
                    <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-white/10 rounded-full blur-2xl animate-ping" style={{ animationDuration: '4s' }}></div>
                </div>

                {/* Animated Wave Lines */}
                <svg className="absolute bottom-0 left-0 right-0 opacity-20" viewBox="0 0 1200 120" preserveAspectRatio="none" style={{ height: '200px' }}>
                    <path d="M0,60 C300,100 600,20 900,60 C1200,100 1200,60 1200,60 L1200,120 L0,120 Z" fill="white" className="animate-pulse" style={{ animationDuration: '3s' }}></path>
                    <path d="M0,80 C200,120 500,40 800,80 C1100,120 1200,80 1200,80 L1200,120 L0,120 Z" fill="white" opacity="0.5" className="animate-pulse" style={{ animationDuration: '4s', animationDelay: '0.5s' }}></path>
                </svg>

                {/* Floating Particles */}
                <div className="absolute inset-0 overflow-hidden">
                    {[...Array(20)].map((_, i) => (
                        <div
                            key={i}
                            className="absolute w-2 h-2 bg-white/30 rounded-full"
                            style={{
                                left: `${Math.random() * 100}%`,
                                top: `${Math.random() * 100}%`,
                                animation: `floatParticle ${3 + Math.random() * 4}s ease-in-out infinite`,
                                animationDelay: `${Math.random() * 2}s`
                            }}
                        ></div>
                    ))}
                </div>

                {/* 3D Rotating Hexagon Grid */}
                <div className="absolute inset-0 opacity-10" style={{ transformStyle: 'preserve-3d' }}>
                    <div
                        className="absolute inset-0"
                        style={{
                            backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Cpolygon points='50,5 95,27.5 95,72.5 50,95 5,72.5 5,27.5' fill='none' stroke='white' stroke-width='1'/%3E%3C/svg%3E")`,
                            backgroundSize: '60px 60px',
                            animation: 'rotateGrid 30s linear infinite',
                            transform: 'rotateX(60deg) translateZ(-50px)'
                        }}
                    ></div>
                </div>

                {/* Floating 3D Medical Icons */}
                <div className="absolute inset-0" style={{ transformStyle: 'preserve-3d' }}>
                    <div className="absolute top-[15%] left-[15%]" style={{ animation: 'float3dIcon 6s ease-in-out infinite' }}>
                        <div className="w-16 h-16 bg-white/20 backdrop-blur-sm rounded-2xl flex items-center justify-center border border-white/30" style={{ boxShadow: '0 20px 40px rgba(0,0,0,0.3)' }}>
                            <Heart className="w-8 h-8 text-white" />
                        </div>
                    </div>
                    <div className="absolute top-[20%] right-[20%]" style={{ animation: 'float3dIcon 7s ease-in-out infinite 1s' }}>
                        <div className="w-14 h-14 bg-white/15 backdrop-blur-sm rounded-xl flex items-center justify-center border border-white/20" style={{ boxShadow: '0 15px 35px rgba(0,0,0,0.25)' }}>
                            <Activity className="w-7 h-7 text-white" />
                        </div>
                    </div>
                    <div className="absolute bottom-[25%] left-[25%]" style={{ animation: 'float3dIcon 5s ease-in-out infinite 0.5s' }}>
                        <div className="w-12 h-12 bg-white/25 backdrop-blur-sm rounded-lg flex items-center justify-center border border-white/30" style={{ boxShadow: '0 12px 30px rgba(0,0,0,0.2)' }}>
                            <Zap className="w-6 h-6 text-white" />
                        </div>
                    </div>
                    <div className="absolute bottom-[30%] right-[15%]" style={{ animation: 'float3dIcon 8s ease-in-out infinite 1.5s' }}>
                        <div className="w-14 h-14 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center border border-white/25" style={{ boxShadow: '0 18px 38px rgba(0,0,0,0.28)' }}>
                            <Stethoscope className="w-7 h-7 text-white" />
                        </div>
                    </div>
                </div>

                {/* Main Content with Glassmorphism */}
                <div className="relative z-10 flex flex-col justify-center items-center w-full p-12 text-white" style={{ transformStyle: 'preserve-3d' }}>
                    {/* Glowing 3D Logo */}
                    <div className="mb-10" style={{ animation: 'float3dIcon 4s ease-in-out infinite' }}>
                        <div
                            className="relative w-36 h-36 bg-white/20 backdrop-blur-xl rounded-[2rem] flex items-center justify-center border border-white/40"
                            style={{
                                boxShadow: '0 0 60px rgba(255,255,255,0.3), 0 30px 60px rgba(0,0,0,0.3), inset 0 2px 4px rgba(255,255,255,0.3)',
                                transform: 'rotateY(-5deg) rotateX(5deg)'
                            }}
                        >
                            <div className="absolute inset-0 rounded-[2rem] bg-gradient-to-br from-white/20 to-transparent"></div>
                            <ShieldCheck className="w-20 h-20 text-white relative z-10" strokeWidth={1.5} style={{ filter: 'drop-shadow(0 4px 12px rgba(0,0,0,0.3))' }} />

                            {/* Glow Ring */}
                            <div className="absolute inset-0 rounded-[2rem] animate-ping opacity-20 border-2 border-white" style={{ animationDuration: '3s' }}></div>
                        </div>
                    </div>

                    {/* Neon Text */}
                    <h1
                        className="text-6xl font-black mb-3 tracking-tight"
                        style={{
                            textShadow: '0 0 20px rgba(255,255,255,0.5), 0 0 40px rgba(16,185,129,0.5), 0 0 80px rgba(16,185,129,0.3), 0 4px 8px rgba(0,0,0,0.3)',
                        }}
                    >
                        Housepital
                    </h1>
                    <p
                        className="text-xl text-white/90 font-medium mb-2"
                        style={{ textShadow: '0 2px 10px rgba(0,0,0,0.3)' }}
                    >
                        AI-Powered Healthcare Platform
                    </p>
                    <div className="flex items-center gap-2 text-white/70 text-sm mb-10">
                        <span className="w-2 h-2 bg-green-400 rounded-full animate-pulse shadow-lg shadow-green-400/50"></span>
                        <span>System Online • Real-time Analytics</span>
                    </div>

                    {/* 3D Glass Stats Cards */}
                    <div className="grid grid-cols-3 gap-5" style={{ transformStyle: 'preserve-3d' }}>
                        {[
                            { label: 'Active Users', value: '10K+', icon: '👥' },
                            { label: 'Uptime', value: '99.9%', icon: '⚡' },
                            { label: 'Response', value: '<1s', icon: '🚀' },
                        ].map((stat, i) => (
                            <div
                                key={stat.label}
                                className="group bg-white/10 hover:bg-white/20 backdrop-blur-md rounded-2xl p-5 border border-white/20 hover:border-white/40 transition-all duration-500 cursor-default"
                                style={{
                                    boxShadow: '0 20px 40px -10px rgba(0,0,0,0.3), inset 0 1px 2px rgba(255,255,255,0.2)',
                                    transform: `translateZ(${30 + i * 10}px)`,
                                    animation: `float3dIcon ${4 + i * 0.5}s ease-in-out infinite ${i * 0.2}s`
                                }}
                            >
                                <div className="text-2xl mb-2 group-hover:scale-125 transition-transform">{stat.icon}</div>
                                <p className="text-3xl font-bold" style={{ textShadow: '0 2px 8px rgba(0,0,0,0.2)' }}>{stat.value}</p>
                                <p className="text-xs text-white/70 mt-1 font-medium">{stat.label}</p>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Corner Decorations */}
                <div className="absolute top-6 left-6 w-20 h-20 border-l-2 border-t-2 border-white/30 rounded-tl-3xl"></div>
                <div className="absolute bottom-6 right-6 w-20 h-20 border-r-2 border-b-2 border-white/30 rounded-br-3xl"></div>
            </div>

            {/* Right Side - Clean Login Form */}
            <div className="w-full lg:w-1/2 flex items-center justify-center p-8 bg-gradient-to-br from-slate-50 to-slate-100">
                <div className="w-full max-w-md" style={{ animation: 'slideIn3d 0.8s ease-out' }}>
                    {/* Mobile Logo */}
                    <div className="lg:hidden text-center mb-8">
                        <div
                            className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-emerald-500 to-teal-500 rounded-2xl mb-4"
                            style={{ boxShadow: '0 20px 40px -10px rgba(16, 185, 129, 0.5)' }}
                        >
                            <ShieldCheck className="w-12 h-12 text-white" strokeWidth={2} />
                        </div>
                        <h1 className="text-2xl font-bold text-slate-900">Housepital</h1>
                    </div>

                    {/* Form Card */}
                    <div
                        className="bg-white rounded-3xl p-8 border border-slate-200/50"
                        style={{ boxShadow: '0 25px 50px -12px rgba(0,0,0,0.08), 0 0 0 1px rgba(0,0,0,0.02)' }}
                    >
                        <div className="mb-8">
                            <h2 className="text-3xl font-bold text-slate-900 mb-2">Welcome back</h2>
                            <p className="text-slate-500">Enter your credentials to continue</p>
                        </div>

                        {error && (
                            <div className="bg-red-50 border border-red-200 text-red-700 p-4 rounded-xl mb-6 flex items-center gap-3 text-sm font-medium">
                                <AlertCircle size={20} className="flex-shrink-0" />
                                <span>{error}</span>
                            </div>
                        )}

                        <form onSubmit={handleSubmit} className="space-y-5">
                            <div>
                                <label className="block text-sm font-semibold text-slate-700 mb-2">Email Address</label>
                                <div className="relative">
                                    <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                                    <input
                                        type="email"
                                        required
                                        placeholder="you@example.com"
                                        className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-200 rounded-xl text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 focus:bg-white transition-all"
                                        value={email}
                                        onChange={(e) => setEmail(e.target.value)}
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-semibold text-slate-700 mb-2">Password</label>
                                <div className="relative">
                                    <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
                                    <input
                                        type="password"
                                        required
                                        placeholder="••••••••"
                                        className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-200 rounded-xl text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 focus:bg-white transition-all"
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                    />
                                </div>
                            </div>

                            <div className="flex items-center justify-between text-sm">
                                <label className="flex items-center gap-2 cursor-pointer">
                                    <input type="checkbox" className="w-4 h-4 text-emerald-500 border-slate-300 rounded focus:ring-emerald-500" />
                                    <span className="text-slate-600">Remember me</span>
                                </label>
                                <a href="#" className="text-emerald-600 hover:text-emerald-700 font-medium">Forgot password?</a>
                            </div>

                            <button
                                type="submit"
                                disabled={loading}
                                className="w-full bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-600 hover:to-teal-600 text-white py-4 rounded-xl font-semibold text-base transition-all active:scale-[0.99] flex items-center justify-center gap-2 disabled:opacity-70"
                                style={{ boxShadow: '0 10px 30px -5px rgba(16, 185, 129, 0.4)' }}
                            >
                                {loading ? (
                                    <div className="flex items-center gap-2">
                                        <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                                        <span>Signing in...</span>
                                    </div>
                                ) : (
                                    <>
                                        <span>Sign In</span>
                                        <ArrowRight size={18} />
                                    </>
                                )}
                            </button>
                        </form>
                    </div>

                    <div className="mt-8 text-center">
                        <div className="flex items-center justify-center gap-2 text-sm text-slate-500">
                            <ShieldCheck size={16} className="text-emerald-500" />
                            <span>Protected by 256-bit SSL encryption</span>
                        </div>
                        <p className="mt-4 text-xs text-slate-400">© 2026 Housepital. All rights reserved.</p>
                    </div>
                </div>
            </div>

            {/* Animation Keyframes */}
            <style>{`
                @keyframes floatParticle {
                    0%, 100% { transform: translateY(0) translateX(0); opacity: 0.3; }
                    25% { transform: translateY(-30px) translateX(10px); opacity: 0.6; }
                    50% { transform: translateY(-20px) translateX(-10px); opacity: 0.4; }
                    75% { transform: translateY(-40px) translateX(5px); opacity: 0.7; }
                }
                @keyframes float3dIcon {
                    0%, 100% { transform: translateY(0) translateZ(0) rotateY(0deg); }
                    50% { transform: translateY(-20px) translateZ(20px) rotateY(5deg); }
                }
                @keyframes rotateGrid {
                    0% { transform: rotateX(60deg) translateZ(-50px) rotateZ(0deg); }
                    100% { transform: rotateX(60deg) translateZ(-50px) rotateZ(360deg); }
                }
                @keyframes slideIn3d {
                    0% { opacity: 0; transform: translateY(30px); }
                    100% { opacity: 1; transform: translateY(0); }
                }
            `}</style>
        </div>
    );
};

export default Login;
