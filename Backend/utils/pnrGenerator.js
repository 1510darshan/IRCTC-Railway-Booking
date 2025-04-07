const crypto = require('crypto');

/**
 * Generates a unique 10-digit PNR number.
 * Format: purely numeric, zero-padded if needed.
 */
function generatePNR() {
    // Create a random buffer, convert to a hex number, and take a 10-digit number
    const raw = crypto.randomBytes(5); // 40 bits ~ 10 digits in decimal
    const num = parseInt(raw.toString('hex'), 16) % 10000000000;
    const pnr = num.toString().padStart(10, '0');
    return pnr;
}

module.exports = generatePNR;
