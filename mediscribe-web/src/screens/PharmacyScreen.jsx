import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  Pill,
  Search,
  Plus,
  Minus,
  ShoppingCart,
  Star,
  Package,
  ChevronRight,
  Filter,
  Heart,
  X,
} from 'lucide-react';
import Card from '../components/common/Card';
import Badge from '../components/common/Badge';
import Button from '../components/common/Button';
import Loader from '../components/common/Loader';
import { productService } from '../services/productService';
import useAppStore from '../store/useAppStore';

const categories = [
  { id: 'all', label: 'All Products', icon: Package },
  { id: 'pain relief', label: 'Pain Relief' },
  { id: 'vitamins', label: 'Vitamins' },
  { id: 'cold & flu', label: 'Cold & Flu' },
  { id: 'skincare', label: 'Skin Care' },
  { id: 'digestive', label: 'Digestive' },
  { id: 'cardiac', label: 'Cardiac' },
  { id: 'diabetes', label: 'Diabetes' },
];

const mockProducts = [
  {
    id: '1',
    name: 'Paracetamol 500mg',
    description: 'For fever and mild to moderate pain relief',
    price: 45,
    originalPrice: 60,
    image: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&h=400&fit=crop',
    category: 'pain relief',
    rating: 4.7,
    reviews: 1243,
    inStock: true,
    discount: 25,
    tag: 'bestseller',
    packSize: '15 tablets',
  },
  {
    id: '2',
    name: 'Vitamin C Complex',
    description: 'Boosts immunity and antioxidant support',
    price: 299,
    originalPrice: 399,
    image: 'https://images.unsplash.com/photo-1559757175-5700dde675bc?w=400&h=400&fit=crop',
    category: 'vitamins',
    rating: 4.9,
    reviews: 892,
    inStock: true,
    discount: 25,
    tag: 'trending',
    packSize: '60 capsules',
  },
  {
    id: '3',
    name: 'Cold Relief Syrup',
    description: 'Relieves cold, cough and congestion',
    price: 125,
    originalPrice: 160,
    image: 'https://images.unsplash.com/photo-1587854692152-cbe31b98c51f?w=400&h=400&fit=crop',
    category: 'cold & flu',
    rating: 4.5,
    reviews: 567,
    inStock: true,
    discount: 22,
    tag: 'new',
    packSize: '100ml',
  },
  {
    id: '4',
    name: 'Moisturizing Cream',
    description: 'Hydrating cream for dry and sensitive skin',
    price: 449,
    originalPrice: 599,
    image: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&h=400&fit=crop',
    category: 'skincare',
    rating: 4.8,
    reviews: 2103,
    inStock: true,
    discount: 25,
    tag: 'bestseller',
    packSize: '200g',
  },
  {
    id: '5',
    name: 'Digestion Enzymes',
    description: 'Supports healthy digestion and nutrient absorption',
    price: 385,
    originalPrice: 450,
    image: 'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=400&h=400&fit=crop',
    category: 'digestive',
    rating: 4.6,
    reviews: 421,
    inStock: true,
    discount: 14,
    packSize: '30 capsules',
  },
  {
    id: '6',
    name: 'Omega-3 Fish Oil',
    description: 'Heart health and brain function support',
    price: 799,
    originalPrice: 999,
    image: 'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=400&h=400&fit=crop',
    category: 'cardiac',
    rating: 4.9,
    reviews: 1567,
    inStock: true,
    discount: 20,
    tag: 'top rated',
    packSize: '120 softgels',
  },
  {
    id: '7',
    name: 'Blood Sugar Support',
    description: 'Maintains healthy blood glucose levels',
    price: 549,
    originalPrice: 699,
    image: 'https://images.unsplash.com/photo-1587854692760-1474db66e3de?w=400&h=400&fit=crop',
    category: 'diabetes',
    rating: 4.7,
    reviews: 734,
    inStock: true,
    discount: 21,
    packSize: '90 tablets',
  },
  {
    id: '8',
    name: 'Ibuprofen 400mg',
    description: 'Anti-inflammatory pain reliever',
    price: 85,
    originalPrice: 110,
    image: 'https://images.unsplash.com/photo-1550572017-edd951b55104?w=400&h=400&fit=crop',
    category: 'pain relief',
    rating: 4.6,
    reviews: 2891,
    inStock: true,
    discount: 23,
    packSize: '20 tablets',
  },
];

const PharmacyScreen = () => {
  const { addToCart, cart, updateQuantity } = useAppStore();
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [wishlist, setWishlist] = useState(new Set());
  const [showFilters, setShowFilters] = useState(false);
  const [sortBy, setSortBy] = useState('popular');
  const [priceRange, setPriceRange] = useState(2000);

  useEffect(() => {
    const loadProducts = async () => {
      setLoading(true);
      try {
        const apiProducts = await productService.fetchProducts();
        if (apiProducts && apiProducts.length > 0) {
          setProducts(apiProducts);
        } else {
          setProducts(mockProducts);
        }
      } catch (error) {
        console.error('Failed to load products, using mock data:', error);
        setProducts(mockProducts);
      } finally {
        setLoading(false);
      }
    };
    loadProducts();
  }, []);

  const filteredProducts = React.useMemo(() => {
    let result = [...products];

    if (selectedCategory !== 'all') {
      result = result.filter((p) =>
        p.category?.toLowerCase().includes(selectedCategory.toLowerCase())
      );
    }

    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      result = result.filter(
        (p) =>
          p.name?.toLowerCase().includes(q) ||
          p.description?.toLowerCase().includes(q)
      );
    }

    result = result.filter((p) => (p.price || 0) <= priceRange);

    switch (sortBy) {
      case 'price-low':
        result.sort((a, b) => (a.price || 0) - (b.price || 0));
        break;
      case 'price-high':
        result.sort((a, b) => (b.price || 0) - (a.price || 0));
        break;
      case 'rating':
        result.sort((a, b) => (b.rating || 0) - (a.rating || 0));
        break;
      case 'discount':
        result.sort((a, b) => (b.discount || 0) - (a.discount || 0));
        break;
      default:
        result.sort((a, b) => (b.reviews || 0) - (a.reviews || 0));
    }

    return result;
  }, [products, selectedCategory, searchQuery, sortBy, priceRange]);

  const toggleWishlist = (id) => {
    const newSet = new Set(wishlist);
    if (newSet.has(id)) {
      newSet.delete(id);
    } else {
      newSet.add(id);
    }
    setWishlist(newSet);
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 lg:py-8">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-2">
          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-pink-500 to-pink-600 flex items-center justify-center shadow-lg">
            <Pill className="w-7 h-7 text-white" />
          </div>
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-text-primary dark:text-text-dark-primary">
              Pharmacy
            </h1>
            <p className="text-text-secondary dark:text-text-dark-secondary">
              Order medicines and healthcare products online
            </p>
          </div>
        </div>
      </div>

      {/* Promo Banner */}
      <Card className="p-6 md:p-8 mb-8 bg-gradient-to-r from-primary-light/10 via-accent-saffron/10 to-pink-500/10 border-none overflow-hidden relative">
        <div className="relative z-10 flex flex-col md:flex-row md:items-center md:justify-between gap-6">
          <div className="max-w-lg">
            <Badge variant="danger" className="mb-4">
              Limited Time Offer
            </Badge>
            <h2 className="text-2xl md:text-3xl font-bold text-text-primary dark:text-text-dark-primary mb-3">
              Get up to <span className="text-primary-light">30% OFF</span> on healthcare essentials
            </h2>
            <p className="text-text-secondary dark:text-text-dark-secondary">
              Free delivery on orders above ₹999. Use code <span className="font-bold text-primary-light">MEDI30</span>
            </p>
          </div>
          <Link to="/cart">
            <Button size="lg">
              <ShoppingCart className="w-5 h-5 mr-2" />
              Shop Now
            </Button>
          </Link>
        </div>
      </Card>

      {/* Search, Filter, Sort */}
      <div className="flex flex-col lg:flex-row gap-4 mb-6">
        <div className="flex-1 relative">
          <Card className="p-1.5">
            <div className="flex items-center gap-3 px-4">
              <Search className="w-5 h-5 text-text-secondary dark:text-text-dark-secondary flex-shrink-0" />
              <input
                type="text"
                placeholder="Search medicines, health products..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="flex-1 py-2.5 bg-transparent border-0 outline-none text-text-primary dark:text-text-dark-primary placeholder:text-text-secondary/60 dark:placeholder:text-text-dark-secondary/60"
              />
              {searchQuery && (
                <button onClick={() => setSearchQuery('')} className="p-1">
                  <X className="w-4 h-4 text-text-secondary dark:text-text-dark-secondary" />
                </button>
              )}
            </div>
          </Card>
        </div>
        <div className="flex gap-3">
          <Button variant="secondary" onClick={() => setShowFilters(!showFilters)}>
            <Filter className="w-5 h-5 mr-2" />
            Filters
          </Button>
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value)}
            className="input-field w-auto hidden sm:block"
          >
            <option value="popular">Most Popular</option>
            <option value="rating">Top Rated</option>
            <option value="discount">Biggest Discount</option>
            <option value="price-low">Price: Low to High</option>
            <option value="price-high">Price: High to Low</option>
          </select>
        </div>
      </div>

      {/* Filters Panel */}
      {showFilters && (
        <Card className="p-6 mb-6 animate-slide-up">
          <div className="flex items-center justify-between mb-6">
            <h3 className="font-semibold text-lg text-text-primary dark:text-text-dark-primary">
              Filters
            </h3>
            <Button
              variant="ghost"
              onClick={() => {
                setSelectedCategory('all');
                setPriceRange(2000);
                setShowFilters(false);
              }}
            >
              Clear All
            </Button>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="label flex justify-between">
                <span>Maximum Price</span>
                <span className="text-primary-light font-semibold">₹{priceRange}</span>
              </label>
              <input
                type="range"
                min="50"
                max="2000"
                step="50"
                value={priceRange}
                onChange={(e) => setPriceRange(Number(e.target.value))}
                className="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-lg accent-pink-500"
              />
            </div>
          </div>
        </Card>
      )}

      {/* Category Tabs */}
      <div className="mb-6 flex gap-2 overflow-x-auto scrollbar-thin -mx-2 px-2 pb-2">
        {categories.map((cat) => (
          <button
            key={cat.id}
            onClick={() => setSelectedCategory(cat.id)}
            className={`flex items-center gap-2 px-4 py-2.5 rounded-xl font-medium text-sm whitespace-nowrap transition-all duration-200 ${
              selectedCategory === cat.id
                ? 'bg-gradient-to-r from-pink-500 to-pink-600 text-white shadow-md'
                : 'bg-white dark:bg-surface-dark text-text-secondary dark:text-text-dark-secondary hover:text-text-primary dark:hover:text-text-dark-primary border border-border dark:border-border-dark'
            }`}
          >
            {cat.icon && <cat.icon className="w-4 h-4" />}
            {cat.label}
          </button>
        ))}
      </div>

      {/* Results Count */}
      <div className="mb-5 flex items-center justify-between">
        <p className="text-text-secondary dark:text-text-dark-secondary">
          Showing <span className="font-semibold text-text-primary dark:text-text-dark-primary">{filteredProducts.length}</span> products
        </p>
      </div>

      {/* Products Grid */}
      {loading ? (
        <Loader label="Loading products..." />
      ) : filteredProducts.length === 0 ? (
        <Card className="p-16 text-center">
          <Package className="w-20 h-20 mx-auto text-text-secondary/20 dark:text-text-dark-secondary/20 mb-6" />
          <h3 className="text-xl font-semibold text-text-primary dark:text-text-dark-primary mb-3">
            No products found
          </h3>
          <p className="text-text-secondary dark:text-text-dark-secondary max-w-md mx-auto mb-6">
            Try adjusting your search or filters to find what you're looking for.
          </p>
          <Button variant="secondary" onClick={() => { setSelectedCategory('all'); setSearchQuery(''); setPriceRange(2000); }}>
            Clear Filters
          </Button>
        </Card>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
          {filteredProducts.map((product) => (
            <Card key={product.id} className="overflow-hidden p-0 hover:-translate-y-1 transition-all duration-300 group flex flex-col">
              {/* Image */}
              <div className="relative h-48 bg-gray-50 dark:bg-surface-dark/50 overflow-hidden">
                <img
                  src={product.image || 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&h=400&fit=crop'}
                  alt={product.name}
                  className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                />
                {product.discount && (
                  <div className="absolute top-3 left-3">
                    <Badge variant="danger">
                      {product.discount}% OFF
                    </Badge>
                  </div>
                )}
                {product.tag && (
                  <div className="absolute top-3 right-3">
                    <Badge variant="primary" className="capitalize">
                      {product.tag}
                    </Badge>
                  </div>
                )}
                <button
                  onClick={() => toggleWishlist(product.id)}
                  className="absolute bottom-3 right-3 w-9 h-9 rounded-full bg-white/90 dark:bg-surface-dark/90 backdrop-blur flex items-center justify-center shadow-md hover:scale-110 transition-transform"
                >
                  <Heart
                    className={`w-5 h-5 ${
                      wishlist.has(product.id)
                        ? 'text-red-500 fill-red-500'
                        : 'text-gray-400 hover:text-red-500'
                    }`}
                  />
                </button>
              </div>

              {/* Details */}
              <div className="p-5 flex-1 flex flex-col">
                <div className="mb-1">
                  <span className="text-xs text-text-secondary dark:text-text-dark-secondary">
                    {product.packSize || 'Standard pack'}
                  </span>
                </div>
                <h3 className="font-bold text-text-primary dark:text-text-dark-primary mb-1 line-clamp-1">
                  {product.name}
                </h3>
                <p className="text-sm text-text-secondary dark:text-text-dark-secondary mb-3 line-clamp-2 flex-1">
                  {product.description}
                </p>

                <div className="flex items-center gap-2 mb-4">
                  <div className="flex items-center gap-1 bg-green-50 dark:bg-green-900/20 px-2 py-0.5 rounded-md">
                    <Star className="w-3.5 h-3.5 text-green-600 dark:text-green-400 fill-green-600 dark:fill-green-400" />
                    <span className="text-xs font-bold text-green-700 dark:text-green-400">
                      {product.rating?.toFixed(1) || '4.5'}
                    </span>
                  </div>
                  <span className="text-xs text-text-secondary dark:text-text-dark-secondary">
                    ({product.reviews?.toLocaleString() || '0'} reviews)
                  </span>
                </div>

                <div className="flex items-end justify-between mt-auto pt-4 border-t border-border dark:border-border-dark">
                  <div>
                    <div className="flex items-baseline gap-2">
                      <span className="text-2xl font-bold text-text-primary dark:text-text-dark-primary">
                        ₹{product.price || 0}
                      </span>
                      {product.originalPrice && product.originalPrice > product.price && (
                        <span className="text-sm text-text-secondary dark:text-text-dark-secondary line-through">
                          ₹{product.originalPrice}
                        </span>
                      )}
                    </div>
                    {product.inStock ? (
                      <span className="text-xs text-green-600 dark:text-green-400 font-medium">
                        In Stock
                      </span>
                    ) : (
                      <span className="text-xs text-red-600 dark:text-red-400 font-medium">
                        Out of Stock
                      </span>
                    )}
                  </div>
                  {cart[product.id] ? (
                    <div className="flex items-center gap-2 bg-gray-100 dark:bg-surface-dark rounded-xl p-1">
                      <button
                        onClick={() => updateQuantity(product.id, cart[product.id].quantity - 1)}
                        className="w-8 h-8 rounded-lg bg-white dark:bg-background-dark flex items-center justify-center hover:bg-gray-200 dark:hover:bg-gray-800 transition-colors"
                      >
                        <Minus className="w-4 h-4" />
                      </button>
                      <span className="w-6 text-center font-bold text-text-primary dark:text-text-dark-primary">
                        {cart[product.id].quantity}
                      </span>
                      <button
                        onClick={() => addToCart(product)}
                        className="w-8 h-8 rounded-lg bg-primary-light text-white flex items-center justify-center hover:bg-primary transition-colors"
                      >
                        <Plus className="w-4 h-4" />
                      </button>
                    </div>
                  ) : (
                    <Button
                      size="sm"
                      onClick={() => addToCart(product)}
                      disabled={!product.inStock}
                    >
                      <Plus className="w-4 h-4 mr-1.5" />
                      Add
                    </Button>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};

export default PharmacyScreen;
