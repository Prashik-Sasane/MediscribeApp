import React, { useState, useEffect } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import {
  Stethoscope,
  Search,
  Filter,
  Star,
  MapPin,
  Clock,
  Award,
  CheckCircle,
  X,
  ChevronRight,
} from 'lucide-react';
import Card from '../components/common/Card';
import Badge from '../components/common/Badge';
import Button from '../components/common/Button';
import Loader from '../components/common/Loader';
import { doctorService } from '../services/doctorService';

const specialties = [
  'All',
  'General Physician',
  'Cardiologist',
  'Dentist',
  'Dermatologist',
  'Gynecologist',
  'Neurologist',
  'Orthopedic',
  'Pediatrician',
  'Psychiatrist',
  'Ophthalmologist',
];

const DoctorListScreen = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const [doctors, setDoctors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState(searchParams.get('q') || '');
  const [selectedSpecialty, setSelectedSpecialty] = useState('');
  const [showFilters, setShowFilters] = useState(false);
  const [minExperience, setMinExperience] = useState(0);
  const [minRating, setMinRating] = useState(0);
  const [feeRange, setFeeRange] = useState(2000);

  useEffect(() => {
    const loadDoctors = async () => {
      setLoading(true);
      try {
        const data = await doctorService.getAllDoctors({
          specialty: selectedSpecialty,
          searchQuery,
        });
        setDoctors(data);
      } catch (error) {
        console.error('Failed to load doctors:', error);
      } finally {
        setLoading(false);
      }
    };

    const debounce = setTimeout(loadDoctors, 300);
    return () => clearTimeout(debounce);
  }, [searchQuery, selectedSpecialty]);

  const filteredDoctors = React.useMemo(() => {
    return doctors.filter((doc) => {
      const exp = doc.experience || 0;
      const rating = doc.rating || 0;
      const fee = doc.fee || 500;
      return exp >= minExperience && rating >= minRating && fee <= feeRange;
    });
  }, [doctors, minExperience, minRating, feeRange]);

  const clearFilters = () => {
    setSelectedSpecialty('');
    setMinExperience(0);
    setMinRating(0);
    setFeeRange(2000);
    setShowFilters(false);
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 lg:py-8">
      <div className="mb-6">
        <h1 className="text-2xl md:text-3xl font-bold text-text-primary dark:text-text-dark-primary mb-2">
          Find Doctors
        </h1>
        <p className="text-text-secondary dark:text-text-dark-secondary">
          Connect with verified medical professionals near you
        </p>
      </div>

      {/* Search & Filter Bar */}
      <div className="mb-6 flex flex-col sm:flex-row gap-3">
        <div className="flex-1 relative">
          <Card className="p-1.5">
            <div className="flex items-center gap-3 px-3">
              <Search className="w-5 h-5 text-text-secondary dark:text-text-dark-secondary flex-shrink-0" />
              <input
                type="text"
                placeholder="Search doctors by name, specialty, condition..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="flex-1 py-2.5 bg-transparent border-0 outline-none text-text-primary dark:text-text-dark-primary placeholder:text-text-secondary/60 dark:placeholder:text-text-dark-secondary/60"
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery('')}
                  className="p-1 rounded-lg hover:bg-gray-100 dark:hover:bg-surface-dark"
                >
                  <X className="w-4 h-4 text-text-secondary dark:text-text-dark-secondary" />
                </button>
              )}
            </div>
          </Card>
        </div>
        <Button
          variant={showFilters || selectedSpecialty || minExperience > 0 || minRating > 0 ? 'primary' : 'secondary'}
          onClick={() => setShowFilters(!showFilters)}
        >
          <Filter className="w-5 h-5 mr-2" />
          Filters
          {(selectedSpecialty || minExperience > 0 || minRating > 0) && (
            <span className="ml-2 w-5 h-5 bg-white text-primary rounded-full text-xs flex items-center justify-center font-bold">
              {(selectedSpecialty ? 1 : 0) + (minExperience > 0 ? 1 : 0) + (minRating > 0 ? 1 : 0)}
            </span>
          )}
        </Button>
      </div>

      {/* Specialty Chips */}
      <div className="mb-6 flex flex-wrap gap-2">
        {specialties.map((spec) => (
          <button
            key={spec}
            onClick={() => setSelectedSpecialty(spec === 'All' ? '' : spec)}
            className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 ${
              (spec === 'All' && !selectedSpecialty) || selectedSpecialty === spec
                ? 'bg-primary-light text-white shadow-md'
                : 'bg-white dark:bg-surface-dark text-text-secondary dark:text-text-dark-secondary hover:bg-gray-100 dark:hover:bg-gray-800 border border-border dark:border-border-dark'
            }`}
          >
            {spec}
          </button>
        ))}
      </div>

      {/* Filters Panel */}
      {showFilters && (
        <Card className="p-6 mb-6 animate-slide-up">
          <div className="flex items-center justify-between mb-6">
            <h3 className="font-semibold text-text-primary dark:text-text-dark-primary text-lg">
              Refine Results
            </h3>
            <Button variant="ghost" onClick={clearFilters}>
              Clear All
            </Button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="label">Minimum Experience</label>
              <select
                value={minExperience}
                onChange={(e) => setMinExperience(Number(e.target.value))}
                className="input-field"
              >
                <option value={0}>Any</option>
                <option value={3}>3+ years</option>
                <option value={5}>5+ years</option>
                <option value={10}>10+ years</option>
                <option value={15}>15+ years</option>
              </select>
            </div>

            <div>
              <label className="label">Minimum Rating</label>
              <select
                value={minRating}
                onChange={(e) => setMinRating(Number(e.target.value))}
                className="input-field"
              >
                <option value={0}>Any</option>
                <option value={3}>3+ Stars</option>
                <option value={4}>4+ Stars</option>
                <option value={4.5}>4.5+ Stars</option>
              </select>
            </div>

            <div>
              <label className="label flex justify-between">
                <span>Max Consultation Fee</span>
                <span className="text-primary-light font-semibold">₹{feeRange}</span>
              </label>
              <input
                type="range"
                min="100"
                max="3000"
                step="100"
                value={feeRange}
                onChange={(e) => setFeeRange(Number(e.target.value))}
                className="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-lg appearance-none cursor-pointer accent-primary-light"
              />
            </div>
          </div>
        </Card>
      )}

      {/* Results count */}
      <div className="mb-5 flex items-center justify-between">
        <p className="text-text-secondary dark:text-text-dark-secondary">
          Showing <span className="font-semibold text-text-primary dark:text-text-dark-primary">{filteredDoctors.length}</span> doctors
        </p>
      </div>

      {/* Doctor Grid */}
      {loading ? (
        <Loader label="Searching doctors..." />
      ) : filteredDoctors.length === 0 ? (
        <Card className="p-16 text-center">
          <Stethoscope className="w-20 h-20 mx-auto text-text-secondary/20 dark:text-text-dark-secondary/20 mb-6" />
          <h3 className="text-xl font-semibold text-text-primary dark:text-text-dark-primary mb-3">
            No doctors found
          </h3>
          <p className="text-text-secondary dark:text-text-dark-secondary max-w-md mx-auto mb-6">
            Try adjusting your search filters or search for a different specialty.
          </p>
          <Button variant="secondary" onClick={clearFilters}>
            Clear Filters
          </Button>
        </Card>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          {filteredDoctors.map((doctor) => (
            <Card key={doctor.id} className="p-6 hover:-translate-y-1 transition-transform duration-200">
              <div className="flex flex-col sm:flex-row gap-5">
                <div className="w-full sm:w-32 h-32 rounded-2xl overflow-hidden bg-gradient-to-br from-primary/10 to-primary-light/20 flex items-center justify-center flex-shrink-0">
                  {doctor.imageUrl ? (
                    <img
                      src={doctor.imageUrl}
                      alt={doctor.name}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <Stethoscope className="w-16 h-16 text-primary dark:text-primary-light" />
                  )}
                </div>

                <div className="flex-1 flex flex-col">
                  <div className="flex items-start justify-between mb-2">
                    <div>
                      <div className="flex items-center gap-2 mb-1">
                        <h3 className="text-xl font-bold text-text-primary dark:text-text-dark-primary">
                          Dr. {doctor.name}
                        </h3>
                        {doctor.isVerified && (
                          <CheckCircle className="w-5 h-5 text-primary-light fill-primary-light/20" />
                        )}
                        {doctor.isOnline && (
                          <span className="w-2.5 h-2.5 bg-green-500 rounded-full flex-shrink-0" />
                        )}
                      </div>
                      <p className="text-text-secondary dark:text-text-dark-secondary font-medium">
                        {doctor.specialty}
                      </p>
                    </div>
                  </div>

                  <div className="flex flex-wrap gap-3 mb-3">
                    <div className="flex items-center gap-1.5">
                      <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
                      <span className="text-sm font-semibold text-text-primary dark:text-text-dark-primary">
                        {doctor.rating?.toFixed(1) || '4.8'}
                      </span>
                      <span className="text-xs text-text-secondary dark:text-text-dark-secondary">
                        ({doctor.reviews || '0'} reviews)
                      </span>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <Award className="w-4 h-4 text-primary-light" />
                      <span className="text-sm text-text-secondary dark:text-text-dark-secondary">
                        {doctor.experience || '5'}+ yrs exp
                      </span>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <MapPin className="w-4 h-4 text-primary-light" />
                      <span className="text-sm text-text-secondary dark:text-text-dark-secondary">
                        {doctor.distanceKm ? `${doctor.distanceKm.toFixed(1)} km` : 'Nearby'}
                      </span>
                    </div>
                  </div>

                  {doctor.bio && (
                    <p className="text-sm text-text-secondary dark:text-text-dark-secondary line-clamp-2 mb-4">
                      {doctor.bio}
                    </p>
                  )}

                  <div className="mt-auto pt-4 border-t border-border dark:border-border-dark flex items-center justify-between">
                    <div>
                      <span className="text-xs text-text-secondary dark:text-text-dark-secondary">
                        Consultation Fee
                      </span>
                      <p className="text-2xl font-bold text-primary dark:text-primary-light">
                        ₹{doctor.fee || 500}
                      </p>
                    </div>
                    <Link to={`/doctors/${doctor.id}`}>
                      <Button>
                        View Profile
                        <ChevronRight className="w-5 h-5 ml-1" />
                      </Button>
                    </Link>
                  </div>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};

export default DoctorListScreen;
