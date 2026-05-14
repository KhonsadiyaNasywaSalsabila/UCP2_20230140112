const express = require('express');
const router = express.Router();
const kategoriController = require('../controllers/kategoriController');
const { verifyToken } = require('../middlewares/authMiddleware');

// Semua rute kategori dilindungi oleh middleware JWT
router.use(verifyToken);

// Endpoint CRUDS Kategori
router.get('/', kategoriController.getAllKategori);       // Read
router.post('/', kategoriController.createKategori);      // Create
router.put('/:id', kategoriController.updateKategori);    // Update
router.delete('/:id', kategoriController.deleteKategori); // Delete

module.exports = router;