const express = require("express");
const { listLabs } = require("../controllers/labController");

const router = express.Router();

router.get("/", listLabs);

module.exports = router;
