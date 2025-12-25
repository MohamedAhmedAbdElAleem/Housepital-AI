const axios = require('axios');

/**
 * Controller to handle Power BI Embedding Logic
 */

const getEmbedToken = async (req, res) => {
    try {
        const { reportId } = req.params;

        // In a real production environment, these should be in your .env file
        const tenantId = process.env.AZURE_TENANT_ID;
        const clientId = process.env.AZURE_CLIENT_ID;
        const clientSecret = process.env.AZURE_CLIENT_SECRET;
        const workspaceId = process.env.PBI_WORKSPACE_ID;

        if (!tenantId || !clientId || !clientSecret || !workspaceId) {
            // Mock response for demonstration if credentials are not yet set
            return res.status(200).json({
                success: true,
                reportId: reportId,
                embedUrl: "https://app.powerbi.com/reportEmbed?reportId=" + reportId + "&workspaceId=" + workspaceId,
                embedToken: "MOCK_TOKEN_SET_ENV_VARS_TO_GET_REAL_ONE",
                message: "Demo mode: Please configure Azure/PowerBI environment variables for production tokens."
            });
        }

        // 1. Get Access Token from Azure AD
        const tokenResponse = await axios.post(
            `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`,
            new URLSearchParams({
                grant_type: 'client_credentials',
                client_id: clientId,
                client_secret: clientSecret,
                scope: 'https://analysis.windows.net/powerbi/api/.default'
            })
        );

        const accessToken = tokenResponse.data.access_token;

        // 2. Get Report Metadata (Embed URL)
        const reportMetadata = await axios.get(
            `https://api.powerbi.com/v1.0/myorg/groups/${workspaceId}/reports/${reportId}`,
            { headers: { Authorization: `Bearer ${accessToken}` } }
        );

        const embedUrl = reportMetadata.data.embedUrl;

        // 3. Generate Embed Token
        const embedTokenResponse = await axios.post(
            `https://api.powerbi.com/v1.0/myorg/groups/${workspaceId}/reports/${reportId}/GenerateToken`,
            { accessLevel: "View" },
            { headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' } }
        );

        return res.status(200).json({
            success: true,
            reportId: reportId,
            embedUrl: embedUrl,
            embedToken: embedTokenResponse.data.token
        });

    } catch (error) {
        console.error('Power BI Token Error:', error.response?.data || error.message);
        res.status(500).json({
            success: false,
            message: 'Error generating Power BI embed token',
            error: error.response?.data || error.message
        });
    }
};

module.exports = {
    getEmbedToken
};
