const db = require('../config/database');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // 1. Cari user berdasarkan email
        const [users] = await db.execute('SELECT * FROM user WHERE email = ?', [email]);
        
        if (users.length === 0) {
            return res.status(401).json({ message: 'Email atau password salah' });
        }

        const user = users[0];

        // 2. Cek kesesuaian password
        // Catatan: Karena password dummy di SQL mu ('$2b$10$example...') bukan hash valid, 
        // pastikan kamu melakukan hash dengan benar nanti.
        const isMatch = await bcrypt.compare(password, user.password);
        
        if (!isMatch) {
            return res.status(401).json({ message: 'Email atau password salah' });
        }

        // 3. Jika berhasil, buat Payload untuk Token JWT
        const payload = {
            id_user: user.id_user,
            email: user.email,
            role: user.role
        };

        // 4. Generate Token (Masa berlaku 1 hari)
        const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1d' });

        res.status(200).json({
            message: 'Login berhasil',
            token: token,
            user: {
                id_user: user.id_user,
                nama: user.nama,
                email: user.email,
                role: user.role
            }
        });

    } catch (error) {
        console.error("Error Login:", error);
        res.status(500).json({ message: 'Terjadi kesalahan pada server' });
    }
};