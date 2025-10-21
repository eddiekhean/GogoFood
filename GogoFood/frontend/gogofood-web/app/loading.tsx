'use client';
// components/Loading.jsx
// app/loading.tsx
export default function Loading() {
    return (
        <div className="flex flex-col items-center justify-center h-screen bg-gradient-to-r from-[#E13454] to-[#DF7734]">
            <div className="relative w-20 h-20">
                <div className="absolute inset-0 rounded-full border-4 border-transparent border-t-[#fff] border-b-[#fff] animate-spin"></div>
                <div className="absolute inset-2 rounded-full border-4 border-[#E13454] opacity-30 animate-ping"></div>
                <div className="absolute inset-4 rounded-full bg-[#ecc5aa] opacity-50 animate-pulse"></div>
            </div>
            <p className="mt-6 text-xl font-medium text-white tracking-wide animate-pulse drop-shadow-md font-fredoka" aria-live="polite">
                Gogo Food đang nạp năng lượng 🔥...
            </p>
        </div>
    );
}