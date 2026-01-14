const express = require('express');
const router = express.Router();
const axios = require('axios');
const OpenAI = require('openai');

// Initialize OpenAI client
const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY
});

// AI Triage Service URL (Python FastAPI service - optional backup)
const AI_TRIAGE_URL = process.env.AI_TRIAGE_URL || 'http://localhost:8000';

// Service definitions with navigation info
const SERVICES = {
    "Wound Care": {
        route: "wound_care",
        title: "Wound Care",
        price: "150 EGP",
        duration: "30-45 min",
        icon: "healing",
        color: "0xFFEF4444",
        description: "Professional wound care and dressing services provided by certified nurses."
    },
    "Injections": {
        route: "injections",
        title: "Injections",
        price: "50 EGP",
        duration: "15-20 min",
        icon: "medication_liquid",
        color: "0xFF3B82F6",
        description: "Safe and painless injection services at your home."
    },
    "Elderly Care": {
        route: "elderly_care",
        title: "Elderly Care",
        price: "200 EGP/hr",
        duration: "1-4 hours",
        icon: "elderly",
        color: "0xFF8B5CF6",
        description: "Comprehensive care for elderly patients."
    },
    "Post-Op Care": {
        route: "post_op_care",
        title: "Post-Op Care",
        price: "300 EGP",
        duration: "45-60 min",
        icon: "monitor_heart",
        color: "0xFF10B981",
        description: "Post-operative care services to ensure smooth recovery."
    },
    "Baby Care": {
        route: "baby_care",
        title: "Baby Care",
        price: "250 EGP",
        duration: "1-2 hours",
        icon: "child_care",
        color: "0xFFEC4899",
        description: "Professional newborn and infant care services."
    },
    "IV Therapy": {
        route: "iv_therapy",
        title: "IV Therapy",
        price: "200 EGP",
        duration: "30-60 min",
        icon: "water_drop",
        color: "0xFF06B6D4",
        description: "Intravenous fluid and medication therapy."
    }
};

// Keyword-based fallback classification (when Python service unavailable)
const classifyMessage = (message) => {
    const msgLower = message.toLowerCase();
    
    // Emergency keywords
    const emergencyKeywords = [
        'cant breathe', 'cannot breathe', 'chest pain', 'heart attack',
        'unconscious', 'severe bleeding', 'stroke', 'seizure', 'poisoning'
    ];
    
    // Service keyword mappings
    const serviceKeywords = {
        "Wound Care": ['wound', 'cut', 'جرح', 'ضمادة', 'bleeding', 'laceration', 'injury', 'stitches'],
        "Injections": ['injection', 'حقنة', 'ابرة', 'vaccine', 'shot', 'insulin'],
        "Elderly Care": ['elderly', 'كبير', 'old', 'والدي', 'والدتي', 'grandmother', 'grandfather', 'senior'],
        "Post-Op Care": ['surgery', 'عملية', 'operation', 'post-op', 'جراحة', 'recovery'],
        "Baby Care": ['baby', 'طفل', 'infant', 'newborn', 'رضيع', 'child'],
        "IV Therapy": ['iv', 'fluids', 'dehydration', 'محاليل', 'drip', 'سوائل']
    };
    
    // Check for emergency
    for (const keyword of emergencyKeywords) {
        if (msgLower.includes(keyword)) {
            return {
                urgency: 'Emergency',
                services: [],
                response: '🚨 **حالة طوارئ!**\n\nاتصل بالإسعاف فوراً!\nرقم الطوارئ: 123\n\nلا تنتظر - هذه حالة تحتاج رعاية طبية فورية.',
                showSos: true
            };
        }
    }
    
    // Check for service keywords
    const matchedServices = [];
    let urgency = 'Medium';
    
    for (const [service, keywords] of Object.entries(serviceKeywords)) {
        for (const keyword of keywords) {
            if (msgLower.includes(keyword)) {
                if (!matchedServices.includes(service)) {
                    matchedServices.push(service);
                }
            }
        }
    }
    
    // Determine urgency based on additional keywords
    if (msgLower.includes('severe') || msgLower.includes('شديد') || msgLower.includes('high fever') || msgLower.includes('39')) {
        urgency = 'High';
    } else if (msgLower.includes('minor') || msgLower.includes('بسيط') || msgLower.includes('small')) {
        urgency = 'Low';
    }
    
    // Build response based on matched services
    let response = '';
    if (matchedServices.length > 0) {
        const servicesList = matchedServices.map(s => `• ${SERVICES[s].title}: ${SERVICES[s].price}`).join('\n');
        
        if (urgency === 'High') {
            response = `⚠️ **حالة تحتاج اهتمام**\n\nبناءً على وصفك، ننصحك بحجز موعد في أقرب وقت.\n\n**الخدمات المناسبة:**\n${servicesList}\n\n👇 اضغط على الخدمة للحجز`;
        } else {
            response = `✅ **تم تحليل حالتك**\n\nالخدمات المناسبة ليك:\n${servicesList}\n\n👇 اضغط على أي خدمة للحجز`;
        }
    } else {
        response = `شكراً على رسالتك! 😊\n\nممكن تحكيلي أكتر عن اللي بتحس بيه عشان أقدر أساعدك أحسن.\n\nمثلاً:\n• عندك جرح محتاج ضمادة؟\n• محتاج حقنة في البيت؟\n• محتاج رعاية لكبير في السن؟`;
        urgency = null;
    }
    
    return {
        urgency,
        services: matchedServices,
        response,
        showSos: false
    };
};

/**
 * @swagger
 * /api/triage/chat:
 *   post:
 *     summary: Send a message to the AI triage chatbot
 *     tags: [Triage]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - message
 *             properties:
 *               message:
 *                 type: string
 *                 description: User's message/symptoms
 *               sessionId:
 *                 type: string
 *                 description: Session ID for conversation context
 *     responses:
 *       200:
 *         description: Triage response with recommendations
 */
router.post('/chat', async (req, res) => {
    try {
        const { message, sessionId = 'default' } = req.body;
        
        if (!message || message.trim().length === 0) {
            return res.status(400).json({ error: 'Message is required' });
        }
        
        let result;
        
        // Use OpenAI directly
        if (process.env.OPENAI_API_KEY) {
            try {
                const servicesList = Object.keys(SERVICES).join(', ');
                
                const systemPrompt = `أنت مساعد طبي ذكي باللغة العربية المصرية (عامية مصرية) لتطبيق Housepital للرعاية الصحية المنزلية.

مهمتك:
1. فهم أعراض المريض
2. تحديد مدى الاستعجال (Emergency/High/Medium/Low)
3. اقتراح الخدمات المناسبة من: ${servicesList}

قواعد مهمة:
- رد دائماً بالعامية المصرية
- لو حالة طوارئ (صعوبة تنفس، ألم صدر شديد، نزيف حاد): قول "اتصل بالإسعاف 123 فوراً"
- اقترح خدمة واحدة أو اتنين بس الأنسب
- كن ودود ومطمئن

رد بالـ JSON format ده بالظبط:
{
    "response": "ردك بالعامية هنا",
    "urgency": "Emergency" أو "High" أو "Medium" أو "Low",
    "services": ["اسم الخدمة 1", "اسم الخدمة 2"],
    "showSos": true أو false
}`;

                const completion = await openai.chat.completions.create({
                    model: 'gpt-4o-mini',
                    messages: [
                        { role: 'system', content: systemPrompt },
                        { role: 'user', content: message }
                    ],
                    temperature: 0.7,
                    max_tokens: 500
                });

                const aiText = completion.choices[0].message.content;
                
                // Parse JSON response
                let parsed;
                try {
                    // Extract JSON from response (handle markdown code blocks)
                    const jsonMatch = aiText.match(/\{[\s\S]*\}/);
                    if (jsonMatch) {
                        parsed = JSON.parse(jsonMatch[0]);
                    } else {
                        throw new Error('No JSON found in response');
                    }
                } catch (parseError) {
                    console.log('Failed to parse AI response, using text:', aiText);
                    parsed = {
                        response: aiText,
                        urgency: 'Medium',
                        services: [],
                        showSos: false
                    };
                }

                // Map services to routes
                const serviceRoutes = (parsed.services || [])
                    .map(s => SERVICES[s])
                    .filter(Boolean);

                result = {
                    response: parsed.response,
                    urgency: parsed.urgency,
                    showSos: parsed.showSos || false,
                    services: parsed.services || [],
                    serviceRoutes,
                    source: 'openai'
                };
                
                console.log('OpenAI response:', result.response.substring(0, 100) + '...');
                
            } catch (openaiError) {
                console.log('OpenAI error, using fallback:', openaiError.message);
                const fallback = classifyMessage(message);
                const serviceRoutes = fallback.services.map(s => SERVICES[s]).filter(Boolean);
                
                result = {
                    response: fallback.response,
                    urgency: fallback.urgency,
                    showSos: fallback.showSos,
                    services: fallback.services,
                    serviceRoutes,
                    source: 'fallback'
                };
            }
        } else {
            // No OpenAI key, use fallback
            console.log('No OpenAI API key, using fallback classification');
            const fallback = classifyMessage(message);
            const serviceRoutes = fallback.services.map(s => SERVICES[s]).filter(Boolean);
            
            result = {
                response: fallback.response,
                urgency: fallback.urgency,
                showSos: fallback.showSos,
                services: fallback.services,
                serviceRoutes,
                source: 'fallback'
            };
        }
        
        res.json(result);
        
    } catch (error) {
        console.error('Triage chat error:', error);
        res.status(500).json({ error: 'Failed to process message' });
    }
});

/**
 * @swagger
 * /api/triage/services:
 *   get:
 *     summary: Get list of available services
 *     tags: [Triage]
 *     responses:
 *       200:
 *         description: List of services with navigation info
 */
router.get('/services', (req, res) => {
    const services = Object.entries(SERVICES).map(([name, info]) => ({
        name,
        ...info
    }));
    res.json(services);
});

/**
 * @swagger
 * /api/triage/reset:
 *   post:
 *     summary: Reset chat session
 *     tags: [Triage]
 */
router.post('/reset', async (req, res) => {
    const { sessionId = 'default' } = req.body;
    
    try {
        await axios.post(`${AI_TRIAGE_URL}/reset/${sessionId}`);
    } catch (error) {
        // Ignore if AI service is unavailable
    }
    
    res.json({ message: 'Session reset', sessionId });
});

module.exports = router;
