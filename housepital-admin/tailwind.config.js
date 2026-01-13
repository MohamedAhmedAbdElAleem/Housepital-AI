/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            fontFamily: {
                sans: ['Inter', 'sans-serif'],
            },
            colors: {
                // Housepital Green Primary Colors (matching mobile app)
                primary: {
                    50: '#EAFAF1',
                    100: '#BEEFD3',
                    200: '#9FE8BE',
                    300: '#73DDA0',
                    400: '#58D68D',
                    500: '#2ECC71',
                    600: '#2ABA67',
                    700: '#219150',
                    800: '#19703E',
                    900: '#13562F',
                    DEFAULT: '#2ECC71',
                },
            },
        },
    },
    plugins: [],
}
