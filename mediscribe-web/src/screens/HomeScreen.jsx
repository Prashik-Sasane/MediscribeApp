import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  Stethoscope,
  Calendar,
  Pill,
  FlaskConical,
  FileScan,
  Video,
  MapPin,
  ChevronRight,
  Star,
  Clock,
  Search,
  Bell,
  Plus,
} from 'lucide-react';
import Card from '../components/common/Card';
import Badge from '../components/common/Badge';
import Button from '../components/common/Button';
import Loader from '../components/common/Loader';
import useAppStore from '../store/useAppStore';
import { doctorService } from '../services/doctorService';

const HomeScreen = () => {
  const navigate = useNavigate();
  const { currentUser, appointments, isDoctor, loadAppointments, loadDoctorAppointments, doctorAppointments } = useAppStore();
  const [nearbyDoctors, setNearbyDoctors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [userLocation, setUserLocation] = useState('Pune, Maharashtra');

  const upcomingAppointments = React.useMemo(() => {
    const list = isDoctor ? doctorAppointments : appointments;
    return list.filter((a) => a.status === 'upcoming').slice(0, 3);
  }, [appointments, doctorAppointments, isDoctor]);

  useEffect(() => {
    const initData = async () => {
      setLoading(true);
      try {
        if (isDoctor) {
          await loadDoctorAppointments();
        } else {
          await loadAppointments();
          if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
              async (position) => {
                const { latitude, longitude } = position.coords;
                const doctors = await doctorService.getNearbyDoctors(latitude, longitude);
                setNearbyDoctors(doctors);
              },
              async () => {
                const doctors = await doctorService.getAllDoctors();
                setNearbyDoctors(doctors.slice(0, 6));
              }
            );
          } else {
            const doctors = await doctorService.getAllDoctors();
            setNearbyDoctors(doctors.slice(0, 6));
          }
        }
      } catch (error) {
        console.error('Failed to load home data:', error);
      } finally {
        setLoading(false);
      }
    };
    initData();
  }, [isDoctor, loadAppointments, loadDoctorAppointments]);

  const quickServices = [
    {
      label: 'Consult Doctors',
      icon: Stethoscope,
      color: 'from-blue-500 to-blue-600',
      path: '/doctors',
      patientOnly: true,
    },
    {
      label: 'Appointments',
      icon: Calendar,
      color: 'from-purple-500 to-purple-600',
      path: '/appointments',
    },
    {
      label: 'Video Call',
      icon: Video,
      color: 'from-green-500 to-green-600',
      path: '/appointments',
    },
    {
      label: 'Pharmacy',
      icon: Pill,
      color: 'from-pink-500 to-pink-600',
      path: '/pharmacy',
      patientOnly: true,
    },
    {
      label: 'Lab Tests',
      icon: FlaskConical,
      color: 'from-orange-500 to-orange-600',
      path: '/lab-tests',
      patientOnly: true,
    },
    {
      label: 'Scan Prescription',
      icon: FileScan,
      color: 'from-teal-500 to-teal-600',
      path: '/upload',
    },
  ];

  const filteredServices = quickServices.filter(
    (s) => !s.patientOnly || (s.patientOnly && !isDoctor)
  );

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader label="Loading dashboard..." />
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 lg:py-8">
      {/* Welcome Section */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-8 gap-4">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <MapPin className="w-4 h-4 text-primary-light" />
            <span className="text-sm text-text-secondary dark:text-text-dark-secondary">
              {userLocation}
            </span>
          </div>
          <h1 className="text-2xl md:text-3xl font-bold text-text-primary dark:text-text-dark-primary">
            {isDoctor ? 'Welcome back, Dr. ' : 'Hello, '}
            <span className="text-primary dark:text-primary-light">{currentUser?.name}</span>!
          </h1>
          <p className="text-text-secondary dark:text-text-dark-secondary mt-1">
            {isDoctor
              ? `You have ${doctorAppointments.length} appointments today`
              : 'How can we help you with your health today?'}
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button className="relative p-2.5 rounded-xl bg-white dark:bg-surface-dark shadow-card hover:shadow-card-hover transition-all">
            <Bell className="w-5 h-5 text-text-secondary dark:text-text-dark-secondary" />
            <span className="absolute top-1 right-1 w-2.5 h-2.5 bg-red-500 rounded-full" />
          </button>
          {!isDoctor && (
            <Button onClick={() => navigate('/doctors')}>
              <Plus className="w-5 h-5 mr-2" />
              Book Consultation
            </Button>
          )}
        </div>
      </div>

      {/* Search Bar */}
      {!isDoctor && (
        <div className="mb-8">
          <Card className="p-2 shadow-lg">
            <div className="flex items-center gap-3 px-4">
              <Search className="w-5 h-5 text-text-secondary dark:text-text-dark-secondary flex-shrink-0" />
              <input
                type="text"
                placeholder="Search doctors, medicines, lab tests..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && searchQuery.trim()) {
                    navigate(`/doctors?q=${encodeURIComponent(searchQuery.trim())}`);
                  }
                }}
                className="flex-1 py-3 bg-transparent border-0 outline-none text-text-primary dark:text-text-dark-primary placeholder:text-text-secondary/60 dark:placeholder:text-text-dark-secondary/60"
              />
              <Button size="sm" onClick={() => searchQuery.trim() && navigate(`/doctors?q=${encodeURIComponent(searchQuery.trim())}`)}>
                Search
              </Button>
            </div>
          </Card>
        </div>
      )}

      {/* Quick Services Grid */}
      <section className="mb-8">
        <h2 className="text-lg font-semibold text-text-primary dark:text-text-dark-primary mb-4">
          {isDoctor ? 'Quick Actions' : 'Quick Services'}
        </h2>
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-4">
          {filteredServices.map((service) => (
            <Link
              key={service.label}
              to={service.path}
              className="group"
            >
              <Card className="p-5 h-full flex flex-col items-center text-center hover:-translate-y-1 transition-transform duration-200">
                <div className={`w-12 h-12 rounded-2xl bg-gradient-to-br ${service.color} flex items-center justify-center mb-3 group-hover:scale-110 transition-transform shadow-lg`}>
                  <service.icon className="w-6 h-6 text-white" />
                </div>
                <span className="text-sm font-medium text-text-primary dark:text-text-dark-primary">
                  {service.label}
                </span>
              </Card>
            </Link>
          ))}
        </div>
      </section>

      {/* Upcoming Appointments */}
      <section className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-text-primary dark:text-text-dark-primary">
            Upcoming Appointments
          </h2>
          <Link
            to="/appointments"
            className="flex items-center text-sm font-medium text-primary-light hover:text-primary transition-colors"
          >
            View All
            <ChevronRight className="w-4 h-4" />
          </Link>
        </div>

        {upcomingAppointments.length === 0 ? (
          <Card className="p-10 text-center">
            <Calendar className="w-16 h-16 mx-auto text-text-secondary/30 dark:text-text-dark-secondary/30 mb-4" />
            <h3 className="text-lg font-medium text-text-primary dark:text-text-dark-primary mb-2">
              No upcoming appointments
            </h3>
            <p className="text-text-secondary dark:text-text-dark-secondary mb-6 max-w-md mx-auto">
              {isDoctor
                ? "You don't have any scheduled appointments yet."
                : 'Book your first consultation with our verified doctors.'}
            </p>
            {!isDoctor && (
              <Button onClick={() => navigate('/doctors')}>
                Find a Doctor
              </Button>
            )}
          </Card>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            {upcomingAppointments.map((appt) => (
              <Card key={appt.id} className="p-5 hover:-translate-y-1 transition-transform">
                <div className="flex items-start gap-4 mb-4">
                  <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-primary/10 to-primary-light/20 flex items-center justify-center flex-shrink-0">
                    <Stethoscope className="w-7 h-7 text-primary dark:text-primary-light" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-text-primary dark:text-text-dark-primary truncate">
                      {isDoctor ? appt.patientName || 'Patient' : `Dr. ${appt.doctorName}`}
                    </h3>
                    <p className="text-sm text-text-secondary dark:text-text-dark-secondary">
                      {appt.specialty}
                    </p>
                  </div>
                  <Badge variant={appt.status === 'upcoming' ? 'success' : 'info'}>
                    {appt.status}
                  </Badge>
                </div>
                <div className="space-y-2 pt-4 border-t border-border dark:border-border-dark">
                  <div className="flex items-center gap-2 text-sm">
                    <Calendar className="w-4 h-4 text-primary-light" />
                    <span className="text-text-secondary dark:text-text-dark-secondary">
                      {appt.dateLabel}
                    </span>
                  </div>
                  <div className="flex items-center gap-2 text-sm">
                    <Clock className="w-4 h-4 text-primary-light" />
                    <span className="text-text-secondary dark:text-text-dark-secondary">
                      {appt.timeLabel}
                    </span>
                  </div>
                  <div className="flex items-center gap-2 text-sm">
                    <MapPin className="w-4 h-4 text-primary-light" />
                    <span className="text-text-secondary dark:text-text-dark-secondary truncate">
                      {appt.location}
                    </span>
                  </div>
                </div>
                <div className="mt-5 grid grid-cols-2 gap-3">
                  {appt.type === 'video' && (
                    <Button size="sm" variant="primary" onClick={() => navigate('/appointments')}>
                      <Video className="w-4 h-4 mr-1.5" />
                      Join Call
                    </Button>
                  )}
                  <Button
                    size="sm"
                    variant={appt.type === 'video' ? 'secondary' : 'primary'}
                    className={appt.type === 'video' ? '' : 'col-span-2'}
                    onClick={() => navigate('/appointments')}
                  >
                    View Details
                  </Button>
                </div>
              </Card>
            ))}
          </div>
        )}
      </section>

      {/* Nearby Doctors (Patient only) */}
      {!isDoctor && (
        <section>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-text-primary dark:text-text-dark-primary">
              Top Nearby Doctors
            </h2>
            <Link
              to="/doctors"
              className="flex items-center text-sm font-medium text-primary-light hover:text-primary transition-colors"
            >
              See All
              <ChevronRight className="w-4 h-4" />
            </Link>
          </div>

          {nearbyDoctors.length === 0 ? (
            <Card className="p-10 text-center">
              <Stethoscope className="w-16 h-16 mx-auto text-text-secondary/30 dark:text-text-dark-secondary/30 mb-4" />
              <p className="text-text-secondary dark:text-text-dark-secondary">
                Loading doctors...
              </p>
            </Card>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
              {nearbyDoctors.slice(0, 6).map((doctor) => (
                <Link key={doctor.id} to={`/doctors/${doctor.id}`}>
                  <Card className="p-5 h-full hover:-translate-y-1 transition-transform">
                    <div className="flex items-start gap-4">
                      <div className="w-16 h-16 rounded-2xl overflow-hidden bg-gradient-to-br from-primary/10 to-primary-light/20 flex items-center justify-center flex-shrink-0">
                        {doctor.imageUrl ? (
                          <img
                            src={doctor.imageUrl}
                            alt={doctor.name}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <Stethoscope className="w-8 h-8 text-primary dark:text-primary-light" />
                        )}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between mb-1">
                          <h3 className="font-semibold text-text-primary dark:text-text-dark-primary truncate">
                            Dr. {doctor.name}
                          </h3>
                          {doctor.isOnline && (
                            <span className="flex-shrink-0 w-2.5 h-2.5 bg-green-500 rounded-full mt-1.5 ml-2" />
                          )}
                        </div>
                        <p className="text-sm text-text-secondary dark:text-text-dark-secondary mb-2">
                          {doctor.specialty}
                        </p>
                        <div className="flex items-center gap-3 text-sm">
                          <div className="flex items-center gap-1">
                            <Star className="w-3.5 h-3.5 text-yellow-500 fill-yellow-500" />
                            <span className="font-medium text-text-primary dark:text-text-dark-primary">
                              {doctor.rating?.toFixed(1) || '4.8'}
                            </span>
                          </div>
                          <span className="text-text-secondary dark:text-text-dark-secondary">
                            {doctor.experience || 5}+ yrs
                          </span>
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center justify-between mt-4 pt-4 border-t border-border dark:border-border-dark">
                      <div>
                        <span className="text-xs text-text-secondary dark:text-text-dark-secondary">
                          Consultation Fee
                        </span>
                        <p className="font-bold text-primary dark:text-primary-light text-lg">
                          ₹{doctor.fee || 500}
                        </p>
                      </div>
                      <Button size="sm">
                        Book Now
                      </Button>
                    </div>
                  </Card>
                </Link>
              ))}
            </div>
          )}
        </section>
      )}
    </div>
  );
};

export default HomeScreen;
