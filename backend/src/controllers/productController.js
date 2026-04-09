const Medicine = require("../models/Medicine");

async function listProducts(req, res) {
  try {
    const { category, q, tag, minPrice, maxPrice, page = 1, limit = 20 } = req.query;

    const query = {};
    
    // Filter by category
    if (category && category !== "All") {
      query.category = category;
    }
    
    // Filter by tag
    if (tag) {
      query.tags = tag;
    }
    
    // Filter by price range
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }
    
    // Text search
    if (q && q.trim()) {
      query.$or = [
        { name: { $regex: q, $options: "i" } },
        { category: { $regex: q, $options: "i" } },
        { tags: { $regex: q, $options: "i" } }
      ];
    }

    const skip = (Number(page) - 1) * Number(limit);
    
    // Fetch products and total count in parallel
    const [products, total] = await Promise.all([
      Medicine.find(query)
        .skip(skip)
        .limit(Number(limit))
        .sort({ createdAt: -1 }),
      Medicine.countDocuments(query)
    ]);

    return res.json({
      products: products.map(productPublic),
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error("Error fetching products:", error);
    return res.status(500).json({ message: "Failed to fetch products" });
  }
}

function productPublic(m) {
  return {
    id: m._id.toString(),
    name: m.name,
    category: m.category,
    price: m.price,
    mrp: m.mrp,
    imageUrl: m.imageUrl,
    stock: m.stock,
    requiresPrescription: m.requiresPrescription,
    tags: m.tags,
    createdAt: m.createdAt,
  };
}

module.exports = { listProducts };
