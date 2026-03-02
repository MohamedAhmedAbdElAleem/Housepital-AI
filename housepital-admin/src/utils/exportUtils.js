export const exportToCSV = (data, filename) => {
    if (!data || !data.length) {
        alert("No data to export");
        return;
    }

    // specific replacement to handle nested objects if needed, 
    // but for now we assume flat or we leave [object Object]
    // Better: Flatten specific fields if known, or generic flatten
    
    // Simple flattener for basic depth
    const flattenRow = (row) => {
        const flattened = {};
        Object.keys(row).forEach(key => {
            if (typeof row[key] === 'object' && row[key] !== null) {
                // simple 1-level stringify or specific field extraction
                // e.g. user.name -> user_name
                // For simplicity, we'll JSON stringify objects
                flattened[key] = JSON.stringify(row[key]); 
            } else {
                flattened[key] = row[key];
            }
        });
        return flattened;
    };

    const flatData = data.map(flattenRow);
    const headers = Object.keys(flatData[0]);
    
    const csvContent = [
        headers.join(','), // Header row
        ...flatData.map(row => headers.map(header => {
            const cell = row[header] === null || row[header] === undefined ? '' : row[header];
            return `"${String(cell).replace(/"/g, '""')}"`; // Escape quotes
        }).join(','))
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    if (link.download !== undefined) {
        const url = URL.createObjectURL(blob);
        link.setAttribute('href', url);
        link.setAttribute('download', `${filename}.csv`);
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
};
