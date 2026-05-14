const express = require('express');
const router = express.Router();
const katalogController = require('../controllers/katalogController');
const { verifyToken } = require('../middlewares/authMiddleware');

// Menyisipkan Middleware: Semua rute di bawah baris ini WAJIB bawa token valid!
router.use(verifyToken);

// Endpoint CRUDS
router.get('/', katalogController.getAllKatalog);           // Read & Search
router.post('/', katalogController.createKatalog);          // Create
router.put('/:id', katalogController.updateKatalog);        // Update
router.delete('/:id', katalogController.deleteKatalog);     // Delete

module.exports = router;