const jwt = require('jsonwebtoken');

const authenticateUser = (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.split(' ')[1];
    console.log(token);

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || "mysecretkey123456"); // JWT_SECRET should match the one used when issuing the token
        req.user = decoded; // Now req.user will be accessible in your controller
        next();
    } catch (err) {
        console.error('JWT verification error:', err);
        return res.status(403).json({ error: 'Invalid or expired token' });
    }
};

module.exports = authenticateUser;
