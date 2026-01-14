const express = require('express');
const router = express.Router();
const axios = require('axios');
const OpenAI = require('openai');

// Initialize OpenAI client (only if key is provided)
const openai = process.env.OPENAI_API_KEY ? new OpenAI({
    apiKey: process.env.OPENAI_API_KEY
}) : null;

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
        if (openai) {
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

// CV Pipeline URL
const CV_PIPELINE_URL = process.env.CV_PIPELINE_URL || 'http://localhost:8000';

// Wound type to service mapping
const WOUND_TYPE_SERVICES = {
    'abrasion': { service: 'Wound Care', urgency: 'Low', arabic: 'سحجة/خدش' },
    'bruise': { service: 'Wound Care', urgency: 'Low', arabic: 'كدمة' },
    'burn': { service: 'Wound Care', urgency: 'High', arabic: 'حرق' },
    'cut': { service: 'Wound Care', urgency: 'Medium', arabic: 'قطع/جرح' },
    'diabetic_foot': { service: 'Wound Care', urgency: 'High', arabic: 'قدم سكري' },
    'laceration': { service: 'Wound Care', urgency: 'Medium', arabic: 'تمزق' },
    'surgical': { service: 'Post-Op Care', urgency: 'Medium', arabic: 'جرح جراحي' }
};

// DFU Grade severity mapping
const DFU_GRADE_URGENCY = {
    'grade_1': { urgency: 'Medium', description: 'قرحة سطحية' },
    'grade_2': { urgency: 'High', description: 'قرحة عميقة' },
    'grade_3': { urgency: 'High', description: 'قرحة عميقة مع خراج أو عظم' },
    'grade_4': { urgency: 'Emergency', description: 'غرغرينا موضعية - حالة طوارئ' }
};

/**
 * @swagger
 * /api/triage/analyze-image:
 *   post:
 *     summary: Process CV pipeline result and generate chatbot response
 *     tags: [Triage]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - cvResult
 *             properties:
 *               cvResult:
 *                 type: object
 *                 description: Result from CV pipeline
 *     responses:
 *       200:
 *         description: Triage response based on image analysis
 */
router.post('/analyze-image', async (req, res) => {
    try {
        const { cvResult } = req.body;

        if (!cvResult || !cvResult.final_verdict) {
            return res.status(400).json({ error: 'CV result with final_verdict is required' });
        }

        const finalVerdict = cvResult.final_verdict;
        let result;

        // Handle irrelevant/background images
        if (finalVerdict.toLowerCase().includes('irrelevant') ||
            finalVerdict.toLowerCase().includes('background')) {
            result = {
                response: '🤔 مش قادر أتعرف على الصورة دي كويس.\n\nممكن تحاول تاني مع صورة أوضح للجرح أو المنطقة المصابة؟\n\nتأكد إن:\n• الإضاءة كويسة\n• الجرح باين واضح في الصورة\n• الصورة مش مهزوزة',
                urgency: null,
                showSos: false,
                services: [],
                serviceRoutes: [],
                needsClarification: true,
                source: 'cv_pipeline'
            };
            return res.json(result);
        }

        // Handle healthy skin
        if (finalVerdict.toLowerCase().includes('healthy')) {
            result = {
                response: '✅ الحمد لله! الصورة بتوضح إن الجلد سليم.\n\nلو عندك أي أعراض تانية أو حاسس بحاجة مش طبيعية، قولي وأنا هساعدك.',
                urgency: 'Low',
                showSos: false,
                services: [],
                serviceRoutes: [],
                needsClarification: false,
                source: 'cv_pipeline'
            };
            return res.json(result);
        }

        // Handle wound detected
        if (finalVerdict.toLowerCase().includes('wound detected')) {
            // Extract wound type from verdict
            let woundType = 'unknown';
            let dfuGrade = null;

            // Check for specific wound types
            for (const [type, info] of Object.entries(WOUND_TYPE_SERVICES)) {
                if (finalVerdict.toLowerCase().includes(type.replace('_', ' '))) {
                    woundType = type;
                    break;
                }
            }

            // Check for DFU grade
            for (const grade of Object.keys(DFU_GRADE_URGENCY)) {
                if (finalVerdict.toLowerCase().includes(grade.replace('_', ' '))) {
                    dfuGrade = grade;
                    break;
                }
            }

            // Build response based on wound type
            let urgency = 'Medium';
            let response = '';
            let services = [];
            let showSos = false;

            if (woundType !== 'unknown') {
                const woundInfo = WOUND_TYPE_SERVICES[woundType];
                urgency = woundInfo.urgency;
                services = [woundInfo.service];

                if (dfuGrade) {
                    const gradeInfo = DFU_GRADE_URGENCY[dfuGrade];
                    urgency = gradeInfo.urgency;

                    if (urgency === 'Emergency') {
                        showSos = true;
                        response = `🚨 **حالة طوارئ - قدم سكري ${gradeInfo.description}**\n\n` +
                            `تم اكتشاف ${woundInfo.arabic} بدرجة خطورة عالية.\n\n` +
                            `⚠️ لازم تروح المستشفى فوراً!\n` +
                            `📞 اتصل بالإسعاف: 123\n\n` +
                            `لحين وصول المساعدة، حافظ على القدم مرفوعة ونظيفة.`;
                    } else {
                        response = `⚠️ **تم اكتشاف ${woundInfo.arabic}**\n\n` +
                            `الدرجة: ${gradeInfo.description}\n` +
                            `مستوى الخطورة: ${urgency === 'High' ? 'عالي ⚠️' : 'متوسط'}\n\n` +
                            `🏥 ننصح بزيارة متخصص في أقرب وقت.\n\n` +
                            `👇 الخدمة المناسبة ليك:`;
                    }
                } else {
                    const urgencyText = {
                        'High': 'عالي ⚠️',
                        'Medium': 'متوسط',
                        'Low': 'بسيط'
                    };

                    response = `🩹 **تم تحليل الصورة**\n\n` +
                        `نوع الإصابة: ${woundInfo.arabic}\n` +
                        `مستوى الخطورة: ${urgencyText[urgency] || 'متوسط'}\n\n`;

                    if (urgency === 'High') {
                        response += `⚠️ ننصح بالعناية الفورية.\n\n`;
                    }

                    response += `👇 الخدمة المناسبة ليك:`;
                }
            } else {
                // Generic wound response
                services = ['Wound Care'];
                response = `🩹 **تم اكتشاف جرح**\n\n` +
                    `ننصح بعرض الجرح على متخصص للعناية المناسبة.\n\n` +
                    `👇 الخدمة المناسبة ليك:`;
            }

            // Map services to routes
            const serviceRoutes = services.map(s => SERVICES[s]).filter(Boolean);

            result = {
                response,
                urgency,
                showSos,
                services,
                serviceRoutes,
                woundType,
                dfuGrade,
                needsClarification: false,
                source: 'cv_pipeline'
            };

            return res.json(result);
        }

        // Default fallback
        result = {
            response: '🤔 مش متأكد من الصورة دي.\n\nممكن توصفلي اللي بتحس بيه؟ أو تبعت صورة تانية أوضح؟',
            urgency: null,
            showSos: false,
            services: [],
            serviceRoutes: [],
            needsClarification: true,
            source: 'cv_pipeline'
        };

        res.json(result);

    } catch (error) {
        console.error('Image analysis error:', error);
        res.status(500).json({ error: 'Failed to analyze image result' });
    }
});

/**
 * @swagger
 * /api/triage/upload-image:
 *   post:
 *     summary: Upload image to CV pipeline and get triage response
 *     tags: [Triage]
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - image
 *             properties:
 *               image:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Triage response based on image analysis
 */
const multer = require('multer');
const FormData = require('form-data');

const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

router.post('/upload-image', upload.single('image'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No image file provided' });
        }

        // Send image to CV pipeline
        const formData = new FormData();
        formData.append('file', req.file.buffer, {
            filename: req.file.originalname || 'image.jpg',
            contentType: req.file.mimetype
        });

        try {
            const cvResponse = await axios.post(`${CV_PIPELINE_URL}/predict`, formData, {
                headers: formData.getHeaders(),
                timeout: 30000 // 30 second timeout for model inference
            });

            // Process CV result through our analyze-image logic
            const cvResult = cvResponse.data;

            // Forward to analyze-image endpoint logic
            const analyzeResponse = await axios.post(
                `http://localhost:${process.env.PORT || 3500}/api/triage/analyze-image`,
                { cvResult }
            );

            res.json(analyzeResponse.data);

        } catch (cvError) {
            console.log('CV Pipeline unavailable:', cvError.message);

            // Fallback response when CV pipeline is not available
            res.json({
                response: '⚠️ خدمة تحليل الصور غير متاحة حالياً.\n\nممكن توصفلي الأعراض أو الإصابة اللي عندك وأنا هساعدك.',
                urgency: null,
                showSos: false,
                services: [],
                serviceRoutes: [],
                needsClarification: true,
                source: 'fallback',
                error: 'cv_pipeline_unavailable'
            });
        }

    } catch (error) {
        console.error('Image upload error:', error);
        res.status(500).json({ error: 'Failed to process image' });
    }
});

module.exports = router;
