import React, { useState, useEffect, useRef, useImperativeHandle, forwardRef } from 'react';
import { PowerBIEmbed } from 'powerbi-client-react';
import { models } from 'powerbi-client';
import api from '../services/api';
import MockAnalytics from './MockAnalytics';

/**
 * PowerBIReport Component
 * 
 * Fetches an embed token from our backend and renders a Power BI report safely.
 * @param {string} reportId - The UUID of the Power BI report
 */
const PowerBIReport = forwardRef(({ reportId }, ref) => {
    const [embedConfig, setEmbedConfig] = useState(null);
    const [error, setError] = useState(null);
    const [loading, setLoading] = useState(true);
    const [isDemoMode, setIsDemoMode] = useState(false);
    const reportRef = useRef(null);
    const containerRef = useRef(null);

    // Expose fullscreen method to parent
    useImperativeHandle(ref, () => ({
        handleFullscreen: () => {
            if (isDemoMode) {
                if (containerRef.current.requestFullscreen) {
                    containerRef.current.requestFullscreen();
                }
            } else if (reportRef.current) {
                reportRef.current.fullscreen();
            }
        }
    }));

    useEffect(() => {
        const fetchEmbedConfig = async () => {
            try {
                setLoading(true);
                const response = await api.get(`/api/admin/powerbi/embed-token/${reportId}`);

                if (response.data.success) {
                    setEmbedConfig({
                        type: 'report',
                        id: response.data.reportId,
                        embedUrl: response.data.embedUrl,
                        accessToken: response.data.embedToken,
                        tokenType: models.TokenType.Embed,
                        settings: {
                            panes: {
                                filters: { visible: false, expanded: false },
                                pageNavigation: { visible: true }
                            },
                            background: models.BackgroundType.Transparent,
                        }
                    });
                }
            } catch (err) {
                console.error('Error fetching Power BI embed config:', err);
                setIsDemoMode(true);
            } finally {
                setLoading(false);
            }
        };

        if (reportId && reportId !== "YOUR_POWERBI_REPORT_ID_HERE") {
            setIsDemoMode(false);
            fetchEmbedConfig();
        } else {
            setIsDemoMode(true);
            setLoading(false);
        }
    }, [reportId]);

    if (loading) {
        return (
            <div className="flex items-center justify-center h-[600px] bg-gray-50 border-2 border-dashed border-gray-200 rounded-xl">
                <div className="text-center">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto"></div>
                    <p className="mt-4 text-gray-600 font-medium">Loading AI Analytics Report...</p>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="flex items-center justify-center h-[600px] bg-red-50 border-2 border-red-200 rounded-xl p-8">
                <div className="text-center max-w-md">
                    <div className="text-red-500 text-5xl mb-4">⚠️</div>
                    <h3 className="text-lg font-bold text-red-800 mb-2">Power BI Configuration Error</h3>
                    <p className="text-red-600 text-sm">{error}</p>
                    <div className="mt-6 text-xs text-gray-500 text-left bg-white p-4 rounded border">
                        <strong>Checklist:</strong>
                        <ul className="list-disc ml-5 mt-2">
                            <li>Set Report ID in Overview.jsx</li>
                            <li>Configure Service Principal in Azure AD</li>
                            <li>Grant Workspace access to Service Principal</li>
                        </ul>
                    </div>
                </div>
            </div>
        );
    }

    if (isDemoMode) {
        return (
            <div ref={containerRef} className="relative group">
                <div className="absolute top-4 right-4 z-10">
                    <span className="flex items-center gap-1.5 px-3 py-1 bg-white/90 backdrop-blur shadow-sm border border-slate-200 rounded-full text-[10px] font-bold text-indigo-600 uppercase tracking-widest animate-pulse">
                        <span className="w-1.5 h-1.5 rounded-full bg-indigo-600"></span>
                        Live AI Preview
                    </span>
                </div>
                <MockAnalytics />
            </div>
        );
    }

    return (
        <div ref={containerRef} className="w-full h-full min-h-[600px] bg-white rounded-xl shadow-sm overflow-hidden border">
            <PowerBIEmbed
                embedConfig={embedConfig}
                cssClassName="w-full h-full min-h-[600px]"
                getEmbeddedComponent={(embeddedReport) => {
                    reportRef.current = embeddedReport;
                }}
            />
        </div>
    );
});

export default PowerBIReport;
