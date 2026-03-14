// Test script to check nurse controller loading
try {
    console.log('Testing nurse controller...');
    const nurseController = require('./src/controllers/nurseController');
    console.log('✅ Nurse controller loaded successfully');
    console.log('Exported functions:', Object.keys(nurseController));
} catch (error) {
    console.error('❌ Error loading nurse controller:');
    console.error(error);
}
