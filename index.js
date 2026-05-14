const express = require('express');
const cors = require('cors');
require('dotenv').config();
const multer = require('multer');
const path = require('path');

const app = express();

// Middleware dasar
app.use(cors());
app.use(express.json()); // Agar Express bisa membaca request body berformat JSON
app.use(express.urlencoded({ extended: true }));

// 1. Agar gambar di dalam folder 'uploads' bisa diakses publik (seperti URL web biasa)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 2. Konfigurasi penyimpanan Multer
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/'); // Simpan ke folder uploads/
    },
    filename: function (req, file, cb) {
        // Buat nama file unik dengan menambahkan timestamp (Waktu saat ini)
        cb(null, Date.now() + path.extname(file.originalname)); 
    }
});

const upload = multer({ storage: storage });

// 3. Buat Endpoint khusus untuk Upload
app.post('/api/upload', upload.single('gambar'), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'Tidak ada gambar yang diupload' });
        }
        
        // Kembalikan path gambar (misal: /uploads/16843920392.jpg)
        const imageUrl = `/uploads/${req.file.filename}`;
        
        res.status(200).json({ 
            message: 'Gambar berhasil diupload',
            url: imageUrl 
        });
    } catch (error) {
        console.error("Error Upload:", error);
        res.status(500).json({ message: 'Terjadi kesalahan saat upload gambar' });
    }
});

// Test Route
app.get('/', (req, res) => {
    res.send('API DriveEase Berjalan Lancar!');
});

const bcrypt = require('bcrypt');
const db = require('./config/database');



const authRoutes = require('./routes/authRoutes');
const katalogRoutes = require('./routes/katalogRoutes');
const kategoriRoutes = require('./routes/kategoriRoutes');

// Daftarkan route
app.use('/api/auth', authRoutes);
app.use('/api/katalog', katalogRoutes);
app.use('/api/kategori', kategoriRoutes);

// Nanti Route Auth & Katalog dimasukkan ke sini

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server berjalan di http://localhost:${PORT}`);
});