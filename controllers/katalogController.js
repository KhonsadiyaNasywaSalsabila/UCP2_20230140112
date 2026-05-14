const db = require('../config/database');

// 1. READ & SEARCH: Mendapatkan semua katalog (bisa dicari berdasarkan nama/merek)
exports.getAllKatalog = async (req, res) => {
    try {
        const { search } = req.query; // Mengambil parameter pencarian dari URL (?search=...)
        
        let query = `
            SELECT k.*, kat.nama_kategori 
            FROM katalog k
            JOIN kategori kat ON k.id_kategori = kat.id_kategori
        `;
        let queryParams = [];

        // Jika ada query pencarian (Search feature)
        if (search) {
            query += ` WHERE k.nama_mobil LIKE ? OR k.merek LIKE ?`;
            queryParams.push(`%${search}%`, `%${search}%`);
        }

        const [rows] = await db.execute(query, queryParams);
        res.status(200).json({ message: "Berhasil mengambil data", data: rows });
    } catch (error) {
        console.error("Error Get Katalog:", error);
        res.status(500).json({ message: "Terjadi kesalahan pada server" });
    }
};

// 2. CREATE: Menambah armada baru
exports.createKatalog = async (req, res) => {
    try {
        // 1. TAMBAHKAN 'gambar' di bagian akhir penangkapan data
        const { id_kategori, nama_mobil, merek, tahun, warna, plat_nomor, harga_sewa, stok, deskripsi, status, gambar } = req.body;

        // 2. TAMBAHKAN kolom 'gambar' dan satu tanda tanya '?' di VALUES
        const query = `
            INSERT INTO katalog 
            (id_kategori, nama_mobil, merek, tahun, warna, plat_nomor, harga_sewa, stok, deskripsi, status, gambar) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;
        
        // 3. TAMBAHKAN variabel 'gambar' di bagian paling akhir array
        const [result] = await db.execute(query, [
            id_kategori, nama_mobil, merek, tahun, warna, plat_nomor, harga_sewa, stok, deskripsi, status || 'tersedia', gambar
        ]);

        res.status(201).json({ 
            message: "Data mobil berhasil ditambahkan", 
            id_katalog: result.insertId 
        });
    } catch (error) {
        console.error("Error Create Katalog:", error);
        res.status(500).json({ message: "Gagal menambah data, pastikan plat nomor unik atau id_kategori valid" });
    }
};

// 3. UPDATE: Mengubah data armada
exports.updateKatalog = async (req, res) => {
    try {
        const { id } = req.params;
        // Tambahkan 'gambar' ke dalam daftar data yang diterima
        const { id_kategori, nama_mobil, merek, tahun, warna, plat_nomor, harga_sewa, stok, deskripsi, status, gambar } = req.body;

        // Tambahkan kolom 'gambar=?' ke dalam query UPDATE
        const query = `
            UPDATE katalog 
            SET id_kategori=?, nama_mobil=?, merek=?, tahun=?, warna=?, plat_nomor=?, harga_sewa=?, stok=?, deskripsi=?, status=?, gambar=?
            WHERE id_katalog=?
        `;
        
        // Pastikan urutannya sesuai dengan tanda tanya di atas
        const [result] = await db.execute(query, [
            id_kategori, nama_mobil, merek, tahun, warna, plat_nomor, harga_sewa, stok, deskripsi, status, gambar, id
        ]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: "Data mobil tidak ditemukan" });
        }

        res.status(200).json({ message: "Data mobil berhasil diupdate" });
    } catch (error) {
        console.error("Error Update Katalog:", error);
        res.status(500).json({ message: "Gagal mengupdate data" });
    }
};

// 4. DELETE: Menghapus data mobil
exports.deleteKatalog = async (req, res) => {
    try {
        const { id } = req.params;
        const [result] = await db.execute('DELETE FROM katalog WHERE id_katalog = ?', [id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: "Data mobil tidak ditemukan" });
        }

        res.status(200).json({ message: "Data mobil berhasil dihapus" });
    } catch (error) {
        console.error("Error Delete Katalog:", error);
        res.status(500).json({ message: "Terjadi kesalahan saat menghapus data" });
    }
};