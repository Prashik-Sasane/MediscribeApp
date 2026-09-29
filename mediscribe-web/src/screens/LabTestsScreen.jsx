import React, { useState, useEffect } from 'react';
import {
  FlaskConical,
  Search,
  Plus,
  Shield,
  Truck,
  Clock,
  Award,
  ChevronRight,
  FileText,
  Heart,
  X,
  CheckCircle,
  Sparkles,
  User,
  MapPin,
  Phone,
  Calendar,
} from 'lucide-react';
import Card from '../components/common/Card';
import Badge from '../components/common/Badge';
import Button from '../components/common/Button';
import Loader from '../components/common/Loader';
import Input from '../components/common/Input';
import { labService } from '../services/labService';
import useAppStore from '../store/useAppStore';
import { useNavigate } from 'react-router-dom';

const categories = [
  { id: 'all', label: 'All Tests' },
  { id: 'Health Checkup', label: 'Health Checkups' },
  { id: 'Blood Test', label: 'Blood Tests' },
  { id: 'Imaging', label: 'Imaging & Scans' },
  { id: 'Cardiac', label: 'Cardiac' },
  { id: 'Diabetes', label: 'Diabetes' },
  { id: 'Thyroid', label: 'Thyroid' },
  { id: 'Vitamins', label: 'Vitamins & Minerals' },
];

const mockLabTests = [
  {
    id: '1',
    name: 'Complete Health Checkup',
    description: 'Comprehensive full body checkup including 85+ parameters for complete health assessment',
    price: 1499,
    originalPrice: 2999,
    discount: 50,
    category: 'Health Checkup',
    image: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=400&h=400&fit=crop',
    parameters: 85,
    fastingRequired: true,
    reportTime: '24-48 hours',
    homeCollection: true,
    rating: 4.9,
    reviews: 2341,
    popular: true,
    includes: ['Blood Glucose Fasting', 'Lipid Profile', 'Liver Function', 'Kidney Function', 'Thyroid Profile', 'Complete Hemogram', 'Vitamin D', 'Vitamin B12'],
  },
  {
    id: '2',
    name: 'Complete Blood Count (CBC)',
    description: 'Basic blood test that evaluates your overall health and detects a wide range of disorders',
    price: 299,
    originalPrice: 500,
    discount: 40,
    category: 'Blood Test',
    image: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=400&fit=crop',
    parameters: 28,
    fastingRequired: false,
    reportTime: '6-8 hours',
    homeCollection: true,
    rating: 4.8,
    reviews: 5672,
    includes: ['Hemoglobin', 'RBC Count', 'WBC Count', 'Platelet Count', 'Differential Count', 'Hematocrit'],
  },
  {
    id: '3',
    name: 'Thyroid Profile (T3, T4, TSH)',
    description: 'Thyroid function test to evaluate hormone levels and detect thyroid disorders',
    price: 499,
    originalPrice: 900,
    discount: 45,
    category: 'Thyroid',
    image: 'https://images.unsplash.com/photo-1530497610245-94d3c16cda28?w=400&h=400&fit=crop',
    parameters: 3,
    fastingRequired: false,
    reportTime: '12-24 hours',
    homeCollection: true,
    rating: 4.9,
    reviews: 3891,
    trending: true,
    includes: ['TSH (Thyroid Stimulating Hormone)', 'T3 (Triiodothyronine)', 'T4 (Thyroxine)'],
  },
  {
    id: '4',
    name: 'Vitamin D (25-OH) Test',
    description: 'Measures Vitamin D levels in blood to detect deficiency and monitor bone health',
    price: 799,
    originalPrice: 1500,
    discount: 47,
    category: 'Vitamins',
    image: 'https://images.unsplash.com/photo-1584308972272-9e4e7685e80f?w=400&h=400&fit=crop',
    parameters: 1,
    fastingRequired: false,
    reportTime: '24-48 hours',
    homeCollection: true,
    rating: 4.8,
    reviews: 4123,
    includes: ['25-Hydroxy Vitamin D Total'],
  },
  {
    id: '5',
    name: 'Lipid Profile',
    description: 'Cholesterol test measuring good (HDL), bad (LDL) cholesterol and triglycerides',
    price: 699,
    originalPrice: 1200,
    discount: 42,
    category: 'Cardiac',
    image: 'https://images.unsplash.com/photo-1559757175-5700dde675bc?w=400&h=400&fit=crop',
    parameters: 8,
    fastingRequired: true,
    reportTime: '12-18 hours',
    homeCollection: true,
    rating: 4.7,
    reviews: 2891,
    includes: ['Total Cholesterol', 'HDL Cholesterol', 'LDL Cholesterol', 'Triglycerides', 'VLDL', 'Cholesterol/HDL Ratio', 'LDL/HDL Ratio', 'Non-HDL Cholesterol'],
  },
  {
    id: '6',
    name: 'Blood Sugar Fasting (FBS)',
    description: 'Fasting blood sugar test to screen for diabetes and monitor glucose levels',
    price: 149,
    originalPrice: 300,
    discount: 50,
    category: 'Diabetes',
    image: 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=400&h=400&fit=crop',
    parameters: 1,
    fastingRequired: true,
    reportTime: '4-6 hours',
    homeCollection: true,
    rating: 4.9,
    reviews: 6234,
    bestseller: true,
    includes: ['Fasting Blood Glucose'],
  },
  {
    id: '7',
    name: 'MRI Brain Scan',
    description: 'Magnetic Resonance Imaging of the brain to detect tumors, strokes, and abnormalities',
    price: 4500,
    originalPrice: 7000,
    discount: 36,
    category: 'Imaging',
    image: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop',
    parameters: 1,
    fastingRequired: false,
    reportTime: '24-48 hours',
    homeCollection: false,
    rating: 4.8,
    reviews: 892,
    includes: ['MRI Brain Plain', 'Radiologist Report', 'Digital Images on CD/Email'],
  },
  {
    id: '8',
    name: 'HbA1c (Glycosylated Hemoglobin)',
    description: '3-month average blood sugar test for diabetes diagnosis and long-term monitoring',
    price: 599,
    originalPrice: 1100,
    discount: 46,
    category: 'Diabetes',
    image: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400&h=400&fit=crop',
    parameters: 1,
    fastingRequired: false,
    reportTime: '12-24 hours',
    homeCollection: true,
    rating: 4.9,
    reviews: 3456,
    includes: ['HbA1c (Glycated Hemoglobin)', 'Estimated Average Glucose (eAG)'],
  },
];

const LabTestsScreen = () => {
  const navigate = useNavigate();
  const { bookLabTest, bookedLabTests, currentUser } = useAppStore();
  const [tests, setTests] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [sortBy, setSortBy] = useState('popular');
  const [selectedTest, setSelectedTest] = useState(null);
  const [bookingTest, setBookingTest] = useState(null);
  const [wishlist, setWishlist] = useState(new Set());
  const [showBookingModal, setShowBookingModal] = useState(false);
  const [bookingForm, setBookingForm] = useState({
    fullName: currentUser?.name || '',
    phone: currentUser?.phone || '',
    address: '',
    city: '',
    pincode: '',
    preferredDate: new Date(Date.now() + 86400000).toISOString().split('T')[0],
    timeSlot: '08:00 AM - 10:00 AM',
  });
  const [maxPrice, setMaxPrice] = useState(6000);
  const [bookingSuccess, setBookingSuccess] = useState(null);

  useEffect(() => {
    const loadTests = async () => {
      setLoading(true);
      try {
        const apiTests = await labService.fetchLabTests();
        if (apiTests && apiTests.length > 0) {
          setTests(apiTests);
        } else {
          setTests(mockLabTests);
        }
      } catch (error) {
        console.error('Failed to load lab tests, using mock data:', error);
        setTests(mockLabTests);
      } finally {
        setLoading(false);
      }
    };
    loadTests();
  }, []);

  const filteredTests = React.useMemo(() => {
    let result = [...tests];

    if (selectedCategory !== 'all') {
      result = result.filter((t) => t.category === selectedCategory);
    }

    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      result = result.filter(
        (t) =>
          t.name?.toLowerCase().includes(q) ||
          t.description?.toLowerCase().includes(q) ||
          t.includes?.some((i) => i.toLowerCase().includes(q))
      );
    }

    result = result.filter((t) => (t.price || 0) <= maxPrice);

    switch (sortBy) {
      case 'price-low':
        result.sort((a, b) => a.price - b.price);
        break;
      case 'price-high':
        result.sort((a, b) => b.price - a.price);
        break;
      case 'discount':
        result.sort((a, b) => (b.discount || 0) - (a.discount || 0));
        break;
      case 'rating':
        result.sort((a, b) => (b.rating || 0) - (a.rating || 0));
        break;
      default:
        result.sort((a, b) => (b.reviews || 0) - (a.reviews || 0));
    }

    return result;
  }, [tests, selectedCategory, searchQuery, sortBy, maxPrice]);

  const toggleWishlist = (id) => {
    const newSet = new Set(wishlist);
    if (newSet.has(id)) newSet.delete(id);
    else newSet.add(id);
    setWishlist(newSet);
  };

  const handleBooking = async (test) => {
    setBookingTest(test);
    setShowBookingModal(true);
    setBookingSuccess(null);
  };

  const submitBooking = async () => {
    setBookingTest({ ...bookingTest, loading: true });
    try {
      const result = await labService.createBooking({
        labTestId: bookingTest.id,
        address: {
          fullAddress: `${bookingForm.address}, ${bookingForm.city} - ${bookingForm.pincode}`,
          phone: bookingForm.phone,
        },
        preferredDate: new Date(bookingForm.preferredDate),
        timeSlot: bookingForm.timeSlot,
        amount: bookingTest.price,
      });
      if (result) {
        bookLabTest(bookingTest);
        setBookingSuccess({
          bookingId: result,
          test: bookingTest,
        });
      }
    } catch (error) {
      bookLabTest(bookingTest);
      setBookingSuccess({
        bookingId: 'BK' + Date.now().toString().slice(-8),
        test: bookingTest,
      });
    } finally {
      setBookingTest(null);
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 lg:py-8">
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-2">
          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center shadow-lg">
            <FlaskConical className="w-7 h-7 text-white" />
          </div>
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-text-primary dark:text-text-dark-primary">
              Lab Tests & Diagnostics
            </h1>
            <p className="text-text-secondary dark:text-text-dark-secondary">
              Book certified lab tests with home sample collection
            </p>
          </div>
        </div>
      </div>

      {/* Features Banner */}
      <Card className="p-6 mb-8 bg-gradient-to-r from-orange-500/5 via-blue-500/5 to-green-500/5 border-none">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 md:gap-6">
          {[
            { icon: Truck, title: 'Free Home Collection', desc: 'On orders above ₹499' },
            { icon: Shield, title: 'NABL Certified Labs', desc: '100% accurate reports' },
            { icon: Clock, title: 'Fast Reports', desc: 'Most within 24 hours' },
            { icon: Award, title: 'Best Prices', desc: 'Up to 60% off on all tests' },
          ].map((f, i) => (
            <div key={i} className="flex items-start gap-3">
              <div className="w-10 h-10 rounded-xl bg-white dark:bg-surface-dark shadow-card flex items-center justify-center flex-shrink-0">
                <f.icon className="w-5 h-5 text-orange-500" />
              </div>
              <div>
                <p className="font-semibold text-sm text-text-primary dark:text-text-dark-primary">
                  {f.title}
                </p>
                <p className="text-xs text-text-secondary dark:text-text-dark-secondary mt-0.5">
                  {f.desc}
                </p>
              </div>
            </div>
          ))}
        </div>
      </Card>

      {/* Popular Packages */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-5">
          <div>
            <h2 className="text-xl font-bold text-text-primary dark:text-text-dark-primary flex items-center gap-2">
              <Sparkles className="w-5 h-5 text-yellow-500" />
              Popular Health Packages
            </h2>
            <p className="text-sm text-text-secondary dark:text-text-dark-secondary mt-1">
              Our most booked comprehensive checkups
            </p>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          {tests.filter((t) => t.popular || t.bestseller || t.trending).slice(0, 3).map((test) => (
            <Card
              key={test.id}
              className={`p-6 cursor-pointer relative overflow-hidden group hover:-translate-y-1 transition-all duration-300 ${
                test.popular ? 'ring-2 ring-orange-500/20' : ''
              }`}
              onClick={() => setSelectedTest(test)}
            >
              {test.popular && (
                <div className="absolute top-0 right-0 bg-gradient-to-r from-orange-500 to-orange-600 text-white text-xs font-bold px-4 py-1.5 rounded-bl-2xl flex items-center gap-1">
                  <Sparkles className="w-3 h-3" />
                  MOST POPULAR
                </div>
              )}
              {test.bestseller && (
                <div className="absolute top-0 right-0 bg-gradient-to-r from-green-500 to-green-600 text-white text-xs font-bold px-4 py-1.5 rounded-bl-2xl flex items-center gap-1">
                  BESTSELLER
                </div>
              )}

              <div className="pt-4">
                <h3 className="font-bold text-lg text-text-primary dark:text-text-dark-primary mb-2 line-clamp-1">
                  {test.name}
                </h3>
                <div className="flex items-center gap-3 mb-3 text-xs">
                  <Badge variant="primary">{test.parameters} Parameters</Badge>
                  <Badge variant={test.fastingRequired ? 'warning' : 'success'}>
                    {test.fastingRequired ? 'Fasting Required' : 'No Fasting'}
                  </Badge>
                </div>
                <p className="text-sm text-text-secondary dark:text-text-dark-secondary line-clamp-2 mb-4">
                  {test.description}
                </p>

                <ul className="space-y-1.5 mb-5">
                  {test.includes?.slice(0, 4).map((inc, i) => (
                    <li key={i} className="flex items-start gap-2 text-xs text-text-secondary dark:text-text-dark-secondary">
                      <CheckCircle className="w-3.5 h-3.5 text-green-600 dark:text-green-400 flex-shrink-0 mt-0.5" />
                      {inc}
                    </li>
                  ))}
                  {test.includes?.length > 4 && (
                    <li className="text-xs text-primary-light font-medium">
                      +{test.includes.length - 4} more tests
                    </li>
                  )}
                </ul>

                <div className="flex items-end justify-between pt-4 border-t border-border dark:border-border-dark">
                  <div>
                    <div className="flex items-baseline gap-2 mb-1">
                      <span className="text-2xl font-bold text-text-primary dark:text-text-dark-primary">
                        ₹{test.price}
                      </span>
                      {test.originalPrice && (
                        <span className="text-sm text-text-secondary dark:text-text-dark-secondary line-through">
                          ₹{test.originalPrice}
                        </span>
                      )}
                    </div>
                    <Badge variant="danger">{test.discount}% OFF</Badge>
                  </div>
                  <Button size="sm" onClick={(e) => { e.stopPropagation(); handleBooking(test); }}>
                    Book Now
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      </div>

      {/* Search & Filters */}
      <div className="flex flex-col lg:flex-row gap-4 mb-6">
        <div className="flex-1 relative">
          <Card className="p-1.5">
            <div className="flex items-center gap-3 px-4">
              <Search className="w-5 h-5 text-text-secondary dark:text-text-dark-secondary flex-shrink-0" />
              <input
                type="text"
                placeholder="Search for tests, checkups, health conditions..."
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
        <select
          value={sortBy}
          onChange={(e) => setSortBy(e.target.value)}
          className="input-field w-auto lg:w-48"
        >
          <option value="popular">Most Popular</option>
          <option value="discount">Biggest Discount</option>
          <option value="rating">Top Rated</option>
          <option value="price-low">Price: Low to High</option>
          <option value="price-high">Price: High to Low</option>
        </select>
      </div>

      {/* Categories */}
      <div className="mb-6 flex gap-2 overflow-x-auto scrollbar-thin -mx-2 px-2 pb-2">
        {categories.map((cat) => (
          <button
            key={cat.id}
            onClick={() => setSelectedCategory(cat.id)}
            className={`px-4 py-2.5 rounded-xl font-medium text-sm whitespace-nowrap transition-all duration-200 ${
              selectedCategory === cat.id
                ? 'bg-gradient-to-r from-orange-500 to-orange-600 text-white shadow-md'
                : 'bg-white dark:bg-surface-dark text-text-secondary dark:text-text-dark-secondary hover:text-text-primary dark:hover:text-text-dark-primary border border-border dark:border-border-dark'
            }`}
          >
            {cat.label}
          </button>
        ))}
      </div>

      {/* Price filter */}
      <Card className="p-5 mb-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex-1">
            <div className="flex justify-between mb-2">
              <span className="label mb-0">Maximum Price</span>
              <span className="text-primary-light font-bold">₹{maxPrice}</span>
            </div>
            <input
              type="range"
              min="200"
              max="6000"
              step="100"
              value={maxPrice}
              onChange={(e) => setMaxPrice(Number(e.target.value))}
              className="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-lg accent-orange-500"
            />
          </div>
          <p className="text-sm text-text-secondary dark:text-text-dark-secondary">
            Showing <span className="font-bold text-text-primary dark:text-text-dark-primary">{filteredTests.length}</span> tests
          </p>
        </div>
      </Card>

      {/* Tests Grid */}
      {loading ? (
        <Loader label="Loading lab tests..." />
      ) : filteredTests.length === 0 ? (
        <Card className="p-16 text-center">
          <FlaskConical className="w-20 h-20 mx-auto text-text-secondary/20 dark:text-text-dark-secondary/20 mb-6" />
          <h3 className="text-xl font-semibold text-text-primary dark:text-text-dark-primary mb-3">
            No tests found
          </h3>
          <p className="text-text-secondary dark:text-text-dark-secondary max-w-md mx-auto">
            Try adjusting your filters or search for a different test.
          </p>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          {filteredTests.map((test) => (
            <Card
              key={test.id}
              className="p-5 flex flex-col sm:flex-row gap-5 hover:-translate-y-0.5 transition-transform cursor-pointer"
              onClick={() => setSelectedTest(test)}
            >
              <div className="w-full sm:w-36 h-36 rounded-xl overflow-hidden bg-gradient-to-br from-orange-500/10 to-blue-500/10 flex-shrink-0">
                <img
                  src={test.image || 'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=300&h=300&fit=crop'}
                  alt={test.name}
                  className="w-full h-full object-cover"
                />
              </div>

              <div className="flex-1 flex flex-col min-w-0">
                <div className="flex items-start justify-between gap-3 mb-2">
                  <h3 className="font-bold text-lg text-text-primary dark:text-text-dark-primary line-clamp-1">
                    {test.name}
                  </h3>
                  <button
                    onClick={(e) => { e.stopPropagation(); toggleWishlist(test.id); }}
                    className="flex-shrink-0 p-1.5 -m-1.5 rounded-lg hover:bg-gray-100 dark:hover:bg-surface-dark transition-colors"
                  >
                    <Heart
                      className={`w-5 h-5 ${
                        wishlist.has(test.id)
                          ? 'text-red-500 fill-red-500'
                          : 'text-gray-400 hover:text-red-500'
                      }`}
                    />
                  </button>
                </div>

                <div className="flex flex-wrap items-center gap-2 mb-3">
                  <Badge variant="primary" className="text-xs">{test.parameters} Tests</Badge>
                  {test.homeCollection && (
                    <Badge variant="success" className="text-xs flex items-center gap-1">
                      <Truck className="w-3 h-3" />
                      Home Collection
                    </Badge>
                  )}
                </div>

                <p className="text-sm text-text-secondary dark:text-text-dark-secondary line-clamp-2 mb-3 flex-1">
                  {test.description}
                </p>

                <div className="flex items-center gap-3 mb-4 text-xs">
                  <div className="flex items-center gap-1">
                    <Clock className="w-3.5 h-3.5 text-text-secondary dark:text-text-dark-secondary" />
                    <span className="text-text-secondary dark:text-text-dark-secondary">{test.reportTime}</span>
                  </div>
                  {test.rating && (
                    <div className="flex items-center gap-1">
                      <span className="font-bold text-green-700 dark:text-green-400 bg-green-50 dark:bg-green-900/20 px-2 py-0.5 rounded">
                        ★ {test.rating}
                      </span>
                      <span className="text-text-secondary dark:text-text-dark-secondary">
                        ({test.reviews?.toLocaleString()})
                      </span>
                    </div>
                  )}
                </div>

                <div className="flex items-end justify-between pt-4 border-t border-border dark:border-border-dark">
                  <div>
                    <div className="flex items-baseline gap-2 mb-1">
                      <span className="text-2xl font-bold text-text-primary dark:text-text-dark-primary">
                        ₹{test.price}
                      </span>
                      {test.originalPrice && (
                        <span className="text-sm text-text-secondary dark:text-text-dark-secondary line-through">
                          ₹{test.originalPrice}
                        </span>
                      )}
                    </div>
                    <Badge variant="danger">{test.discount}% OFF</Badge>
                  </div>
                  <Button
                    size="sm"
                    onClick={(e) => { e.stopPropagation(); handleBooking(test); }}
                    disabled={bookedLabTests.some((b) => b.id === test.id)}
                  >
                    {bookedLabTests.some((b) => b.id === test.id) ? 'Booked' : 'Book Now'}
                    <ChevronRight className="w-4 h-4 ml-1" />
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Detail Modal */}
      {selectedTest && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 animate-fade-in" onClick={() => setSelectedTest(null)}>
          <div
            className="max-w-2xl w-full max-h-[90vh] overflow-y-auto scrollbar-thin animate-slide-up"
            onClick={(e) => e.stopPropagation()}
          >
            <Card className="p-0">
              <div className="h-48 bg-gradient-to-br from-orange-500 to-orange-600 relative overflow-hidden">
                <img
                  src={selectedTest.image || 'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=800&h=400&fit=crop'}
                  alt=""
                  className="w-full h-full object-cover opacity-25 mix-blend-overlay"
                />
                <button
                  onClick={() => setSelectedTest(null)}
                  className="absolute top-4 right-4 w-10 h-10 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/30 transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
                <div className="absolute bottom-6 left-6 right-6 text-white">
                  <div className="flex flex-wrap gap-2 mb-3">
                    {selectedTest.popular && <Badge variant="primary">Most Popular</Badge>}
                    {selectedTest.bestseller && <Badge variant="success">Bestseller</Badge>}
                  </div>
                  <h2 className="text-2xl md:text-3xl font-bold mb-2">{selectedTest.name}</h2>
                  <p className="opacity-90">{selectedTest.description}</p>
                </div>
              </div>

              <div className="p-6 md:p-8">
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
                  {[
                    { label: 'Parameters', value: `${selectedTest.parameters} Tests` },
                    { label: 'Fasting', value: selectedTest.fastingRequired ? 'Yes (8-12hrs)' : 'Not Required' },
                    { label: 'Reports', value: selectedTest.reportTime },
                    { label: 'Home Visit', value: selectedTest.homeCollection ? 'Available' : 'Visit Lab' },
                  ].map((s, i) => (
                    <div key={i} className="p-4 rounded-xl bg-gray-50 dark:bg-surface-dark/50 text-center">
                      <p className="text-xs text-text-secondary dark:text-text-dark-secondary mb-1">{s.label}</p>
                      <p className="font-bold text-sm text-text-primary dark:text-text-dark-primary">{s.value}</p>
                    </div>
                  ))}
                </div>

                <h3 className="font-bold text-lg text-text-primary dark:text-text-dark-primary mb-4 flex items-center gap-2">
                  <FileText className="w-5 h-5 text-orange-500" />
                  Tests Included ({selectedTest.includes?.length || 0})
                </h3>
                <ul className="space-y-2 mb-8">
                  {selectedTest.includes?.map((inc, i) => (
                    <li key={i} className="flex items-center gap-3 p-3 rounded-xl hover:bg-gray-50 dark:hover:bg-surface-dark/50 transition-colors">
                      <CheckCircle className="w-5 h-5 text-green-600 dark:text-green-400 flex-shrink-0" />
                      <span className="font-medium text-text-primary dark:text-text-dark-primary">{inc}</span>
                    </li>
                  ))}
                </ul>

                <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 p-6 rounded-2xl bg-gradient-to-r from-orange-500/5 to-green-500/5 border border-orange-500/10">
                  <div>
                    <p className="text-sm text-text-secondary dark:text-text-dark-secondary mb-1">Total Cost</p>
                    <div className="flex items-baseline gap-3">
                      <span className="text-3xl font-bold text-text-primary dark:text-text-dark-primary">
                        ₹{selectedTest.price}
                      </span>
                      {selectedTest.originalPrice && (
                        <span className="text-lg text-text-secondary dark:text-text-dark-secondary line-through">
                          ₹{selectedTest.originalPrice}
                        </span>
                      )}
                      <Badge variant="danger" className="text-base px-3 py-1">Save ₹{selectedTest.originalPrice - selectedTest.price}</Badge>
                    </div>
                  </div>
                  <Button size="lg" onClick={() => { setSelectedTest(null); handleBooking(selectedTest); }}>
                    Book This Test
                    <ChevronRight className="w-5 h-5 ml-1" />
                  </Button>
                </div>
              </div>
            </Card>
          </div>
        </div>
      )}

      {/* Booking Modal */}
      {showBookingModal && bookingTest && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 animate-fade-in" onClick={() => !bookingSuccess && setShowBookingModal(false)}>
          <div
            className="max-w-xl w-full max-h-[90vh] overflow-y-auto scrollbar-thin animate-slide-up"
            onClick={(e) => e.stopPropagation()}
          >
            {bookingSuccess ? (
              <Card className="p-10 text-center">
                <div className="w-24 h-24 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center mx-auto mb-6">
                  <CheckCircle className="w-12 h-12 text-green-600 dark:text-green-400" />
                </div>
                <h2 className="text-3xl font-bold text-text-primary dark:text-text-dark-primary mb-2">
                  Booking Confirmed!
                </h2>
                <p className="text-text-secondary dark:text-text-dark-secondary mb-6">
                  Your lab test booking has been successfully scheduled.
                </p>
                <div className="p-5 rounded-2xl bg-gray-50 dark:bg-surface-dark/50 text-left mb-6">
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <span className="text-text-secondary dark:text-text-dark-secondary">Booking ID</span>
                      <p className="font-bold text-primary-light">#{bookingSuccess.bookingId}</p>
                    </div>
                    <div>
                      <span className="text-text-secondary dark:text-text-dark-secondary">Test</span>
                      <p className="font-bold text-text-primary dark:text-text-dark-primary truncate">{bookingSuccess.test.name}</p>
                    </div>
                    <div>
                      <span className="text-text-secondary dark:text-text-dark-secondary">Date</span>
                      <p className="font-bold text-text-primary dark:text-text-dark-primary">{bookingForm.preferredDate}</p>
                    </div>
                    <div>
                      <span className="text-text-secondary dark:text-text-dark-secondary">Time</span>
                      <p className="font-bold text-text-primary dark:text-text-dark-primary">{bookingForm.timeSlot}</p>
                    </div>
                  </div>
                </div>
                <div className="flex gap-3">
                  <Button variant="secondary" onClick={() => setShowBookingModal(false)} className="flex-1">
                    Close
                  </Button>
                  <Button className="flex-1" onClick={() => { navigate('/appointments'); }}>
                    View Appointments
                  </Button>
                </div>
              </Card>
            ) : (
              <Card className="p-6 md:p-8">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <h2 className="text-2xl font-bold text-text-primary dark:text-text-dark-primary mb-1">
                      Book Lab Test
                    </h2>
                    <p className="text-text-secondary dark:text-text-dark-secondary">
                      Please fill in the details below
                    </p>
                  </div>
                  <button
                    onClick={() => setShowBookingModal(false)}
                    className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-surface-dark transition-colors"
                  >
                    <X className="w-5 h-5" />
                  </button>
                </div>

                <div className="p-4 rounded-xl bg-orange-500/5 border border-orange-500/10 mb-6 flex gap-4">
                  <div className="w-16 h-16 rounded-xl overflow-hidden bg-gradient-to-br from-orange-500/10 to-blue-500/10 flex-shrink-0">
                    <img
                      src={bookingTest.image || 'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=200&h=200&fit=crop'}
                      alt=""
                      className="w-full h-full object-cover"
                    />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-bold text-text-primary dark:text-text-dark-primary mb-1 line-clamp-1">
                      {bookingTest.name}
                    </h3>
                    <Badge variant="primary" className="text-xs mb-2">{bookingTest.parameters} Parameters</Badge>
                    <div className="flex items-baseline gap-2">
                      <span className="text-xl font-bold text-text-primary dark:text-text-dark-primary">₹{bookingTest.price}</span>
                      <span className="text-sm text-text-secondary dark:text-text-dark-secondary line-through">₹{bookingTest.originalPrice}</span>
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-5 mb-6">
                  <div className="md:col-span-2">
                    <Input
                      label="Patient Name"
                      icon={User}
                      value={bookingForm.fullName}
                      onChange={(e) => setBookingForm({ ...bookingForm, fullName: e.target.value })}
                      placeholder="Full name of the patient"
                    />
                  </div>
                  <div className="md:col-span-2">
                    <Input
                      label="Phone Number"
                      icon={Phone}
                      value={bookingForm.phone}
                      onChange={(e) => setBookingForm({ ...bookingForm, phone: e.target.value })}
                      placeholder="+91 98765 43210"
                    />
                  </div>
                  <div className="md:col-span-2">
                    <label className="label flex items-center gap-2">
                      <MapPin className="w-4 h-4" />
                      Address for Sample Collection
                    </label>
                    <textarea
                      value={bookingForm.address}
                      onChange={(e) => setBookingForm({ ...bookingForm, address: e.target.value })}
                      placeholder="House/Flat No, Building Name, Street, Area"
                      rows={2}
                      className="input-field resize-none"
                    />
                  </div>
                  <Input
                    label="City"
                    value={bookingForm.city}
                    onChange={(e) => setBookingForm({ ...bookingForm, city: e.target.value })}
                    placeholder="e.g. Pune"
                  />
                  <Input
                    label="Pincode"
                    value={bookingForm.pincode}
                    onChange={(e) => setBookingForm({ ...bookingForm, pincode: e.target.value })}
                    placeholder="e.g. 411001"
                  />
                  <Input
                    label="Preferred Date"
                    type="date"
                    icon={Calendar}
                    value={bookingForm.preferredDate}
                    onChange={(e) => setBookingForm({ ...bookingForm, preferredDate: e.target.value })}
                  />
                  <div>
                    <label className="label">Time Slot</label>
                    <select
                      value={bookingForm.timeSlot}
                      onChange={(e) => setBookingForm({ ...bookingForm, timeSlot: e.target.value })}
                      className="input-field"
                    >
                      <option>07:00 AM - 09:00 AM</option>
                      <option>08:00 AM - 10:00 AM</option>
                      <option>09:00 AM - 11:00 AM</option>
                      <option>10:00 AM - 12:00 PM</option>
                      <option>05:00 PM - 07:00 PM</option>
                      <option>06:00 PM - 08:00 PM</option>
                    </select>
                  </div>
                </div>

                <div className="flex gap-3">
                  <Button variant="secondary" onClick={() => setShowBookingModal(false)} className="flex-1">
                    Cancel
                  </Button>
                  <Button
                    className="flex-1"
                    onClick={submitBooking}
                    loading={bookingTest?.loading}
                    disabled={!bookingForm.fullName || !bookingForm.phone || !bookingForm.address}
                    size="lg"
                  >
                    Confirm & Pay ₹{bookingTest.price}
                  </Button>
                </div>
              </Card>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default LabTestsScreen;
