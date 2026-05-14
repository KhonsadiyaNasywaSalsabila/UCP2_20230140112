const db = require('../config/database');

// 1. READ: Mengambil semua data kategori
exports.getAllKategori = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM kategori');
        res.status(200).json({
            message: "Berhasil mengambil data kategori",
            data: rows
        });
    } catch (error) {
        console.error("Error Get Kategori:", error);
        res.status(500).json({ message: "Terjadi kesalahan pada server" });
    }
};

// 2. CREATE: Menambah kategori baru
exports.createKategori = async (req, res) => {
    try {
        const { nama_kategori, deskripsi } = req.body;

        const query = 'INSERT INTO kategori (nama_kategori, deskripsi) VALUES (?, ?)';
        const [result] = await db.execute(query, [nama_kategori, deskripsi]);

        res.status(201).json({
            message: "Kategori berhasil ditambahkan",
            id_kategori: result.insertId
        });
    } catch (error) {
        console.error("Error Create Kategori:", error);
        res.status(500).json({ message: "Gagal menambah kategori. Pastikan nama kategori unik." });
    }
};

// 3. UPDATE: Mengubah data kategori
exports.updateKategori = async (req, res) => {
    try {
        const { id } = req.params;
        const { nama_kategori, deskripsi } = req.body;

        const query = 'UPDATE kategori SET nama_kategori = ?, deskripsi = ? WHERE id_kategori = ?';
        const [result] = await db.execute(query, [nama_kategori, deskripsi, id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: "Kategori tidak ditemukan" });
        }

        res.status(200).json({ message: "Kategori berhasil diperbarui" });
    } catch (error) {
        console.error("Error Update Kategori:", error);
        res.status(500).json({ message: "Terjadi kesalahan saat memperbarui kategori" });
    }
};

// 4. DELETE: Menghapus kategori
exports.deleteKategori = async (req, res) => {
    try {
        const { id } = req.params;
        const [result] = await db.execute('DELETE FROM kategori WHERE id_kategori = ?', [id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: "Kategori tidak ditemukan" });
        }

        res.status(200).json({ message: "Kategori berhasil dihapus" });
    } catch (error) {
        console.error("Error Delete Kategori:", error);
        
        // Menangani error jika kategori masih dipakai oleh tabel katalog (Efek ON DELETE RESTRICT)
        if (error.code === 'ER_ROW_IS_REFERENCED_2') {
            return res.status(400).json({ 
                message: "Kategori tidak bisa dihapus karena masih digunakan oleh data mobil di katalog." 
            });
        }
        
        res.status(500).json({ message: "Terjadi kesalahan saat menghapus kategori" });
    }
};