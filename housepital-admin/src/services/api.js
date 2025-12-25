import axios from 'axios';

/**
 * Centralized API configuration for the Housepital Admin Dashboard.
 * This ensures all requests go through the same base configuration
 * and handles JWT injection automatically via the AuthContext.
 */

const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL || '', // Empty for local proxy, or full URL for prod
    headers: {
        'Content-Type': 'application/json',
    },
});

// Response interceptor to handle unauthorized errors globally
api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            localStorage.removeItem('admin_token');
            // Only reload if we're not already on the login page
            if (!window.location.pathname.includes('/login')) {
                window.location.href = '/login';
            }
        }
        return Promise.reject(error);
    }
);

export default api;
