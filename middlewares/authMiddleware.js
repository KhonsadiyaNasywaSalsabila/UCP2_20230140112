const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    // Ambil header authorization (Format: Bearer <token>)
    const authHeader = req.headers['authorization'];
    
    if (!authHeader) {
        return res.status(403).json({ message: 'Akses ditolak, token tidak disediakan!' });
    }

    const token = authHeader.split(' ')[1]; // Memisahkan kata "Bearer" dan mengambil tokennya saja

    if (!token) {
        return res.status(403).json({ message: 'Format token salah!' });
    }

    try {
        // Verifikasi token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded; // Simpan data user ke request object agar bisa dipakai di controller
        next(); // Lanjut ke controller (katalog)
    } catch (err) {
        return res.status(401).json({ message: 'Token tidak valid atau sudah expired!' });
    }
};

module.exports = { verifyToken };