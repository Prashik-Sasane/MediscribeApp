import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import {
  Stethoscope,
  Star,
  Clock,
  MapPin,
  Award,
  CheckCircle,
  MessageCircle,
  Video,
  ChevronLeft,
  Calendar,
  Info,
} from 'lucide-react';
import Card from '../components/common/Card';
import Badge from '../components/common/Badge';
import Button from '../components/common/Button';
import Loader from '../components/common/Loader';
import Input from '../components/common/Input';
import { doctorService } from '../services/doctorService';
import useAppStore from '../store/useAppStore';

const timeSlots = [
  '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
  '11:00 AM', '11:30 AM', '02:00 PM', '02:30 PM',
  '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
  '05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM',
];

const DoctorDetailScreen = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { bookAppointment, currentUser } = useAppStore();
  const [doctor, setDoctor] = useState(null);
  const [loading, setLoading] = useState(true);
  const [selectedDate, setSelectedDate] = useState('');
  const [selectedTime, setSelectedTime] = useState('');
  const [appointmentType, setAppointmentType] = useState('clinic');
  const [showBooking, setShowBooking] = useState(false);
  const [bookingSuccess, setBookingSuccess] = useState(false);

  useEffect(() => {
    const loadDoctor = async () => {
      setLoading(true);
      try {
        const data = await doctorService.getDoctorById(id);
        setDoctor(data);
      } catch (error) {
        console.error('Failed to load doctor:', error);
      } finally {
        setLoading(false);
      }
    };
    loadDoctor();
  }, [id]);

  const generateNextDates = () => {
    const dates = [];
    const today = new Date();
    for (let i = 0; i < 14; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      dates.push({
        date: date.toISOString().split('T')[0],
        day: date.toLocaleDateString('en-US', { weekday: 'short' }),
        dayNum: date.getDate(),
        month: date.toLocaleDateString('en-US', { month: 'short' }),
      });
    }
    return dates;
  };

  const dates = React.useMemo(() => generateNextDates(), []);

  const handleBookAppointment = async () => {
    if (!selectedDate || !selectedTime) {
      alert('Please select date and time');
      return;
    }

    const dateObj = new Date(selectedDate);
    const dateLabel = `${dateObj.toLocaleDateString('en-US', { weekday: 'long' })}, ${dateObj.toLocaleDateString('en-US', { day: 'numeric' })} ${dateObj.toLocaleDateString('en-US', { month: 'long' })}`;

    const appointment = {
      doctorId: doctor.id,
      doctorName: doctor.name,
      specialty: doctor.specialty,
      dateLabel,
      timeLabel: selectedTime,
      type: appointmentType,
      location: appointmentType === 'clinic' ? 'Clinic Visit' : appointmentType === 'video' ? 'Video Call' : 'Home Visit',
    };

    const success = await bookAppointment(appointment);
    if (success) {
      setBookingSuccess(true);
      setTimeout(() => {
        navigate('/appointments');
      }, 2500);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader label="Loading doctor profile..." />
      </div>
    );
  }

  if (!doctor) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Card className="p-16 text-center">
          <Stethoscope className="w-20 h-20 mx-auto text-text-secondary/20 mb-6" />
          <h3 className="text-xl font-semibold text-text-primary dark:text-text-dark-primary mb-3">
            Doctor not found
          </h3>
          <Link to="/doctors">
            <Button variant="secondary">Back to Doctors</Button>
          </Link>
        </Card>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 lg:py-8">
      {/* Header with Back button */}
      <button
        onClick={() => navigate(-1)}
        className="flex items-center gap-2 text-text-secondary dark:text-text-dark-secondary hover:text-primary dark:hover:text-primary-light mb-6 font-medium transition-colors"
      >
        <ChevronLeft className="w-5 h-5" />
        Back to Doctors
      </button>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Doctor Info */}
        <div className="lg:col-span-2 space-y-6">
          {/* Main Doctor Card */}
          <Card className="p-6 md:p-8">
            <div className="flex flex-col sm:flex-row gap-6">
              <div className="w-32 h-32 md:w-40 md:h-40 rounded-3xl overflow-hidden bg-gradient-to-br from-primary/10 to-primary-light/20 flex items-center justify-center flex-shrink-0 mx-auto sm:mx-0">
                {doctor.imageUrl ? (
                  <img
                    src={doctor.imageUrl}
                    alt={doctor.name}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <Stethoscope className="w-20 h-20 text-primary dark:text-primary-light" />
                )}
              </div>

              <div className="flex-1 text-center sm:text-left">
                <div className="flex flex-wrap items-center justify-center sm:justify-start gap-2 mb-2">
                  <h1 className="text-2xl md:text-3xl font-bold text-text-primary dark:text-text-dark-primary">
                    Dr. {doctor.name}
                  </h1>
                  {doctor.isVerified && (
                    <Badge variant="success">
                      <CheckCircle className="w-3.5 h-3.5 mr-1" />
                      Verified
                    </Badge>
                  )}
                  {doctor.isOnline && (
                    <Badge variant="success">
                      <span className="w-2 h-2 bg-green-500 rounded-full mr-1.5" />
                      Online
                    </Badge>
                  )}
                </div>

                <p className="text-lg text-primary dark:text-primary-light font-medium mb-4">
                  {doctor.specialty}
                </p>

                <div className="flex flex-wrap items-center justify-center sm:justify-start gap-4 mb-4">
                  <div className="flex items-center gap-1.5">
                    <Star className="w-5 h-5 text-yellow-500 fill-yellow-500" />
                    <span className="font-bold text-text-primary dark:text-text-dark-primary">
                      {doctor.rating?.toFixed(1) || '4.8'}
                    </span>
                    <span className="text-sm text-text-secondary dark:text-text-dark-secondary">
                      ({doctor.reviews || 0} reviews)
                    </span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <Award className="w-5 h-5 text-primary-light" />
                    <span className="text-sm text-text-secondary dark:text-text-dark-secondary">
                      {doctor.experience || 5}+ years experience
                    </span>
                  </div>
                </div>

                {doctor.bio && (
                  <p className="text-text-secondary dark:text-text-dark-secondary leading-relaxed">
                    {doctor.bio}
                  </p>
                )}
              </div>
            </div>

            {/* Quick Info Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-8 pt-8 border-t border-border dark:border-border-dark">
              <div className="text-center p-4 rounded-xl bg-gray-50 dark:bg-surface-dark/50">
                <Clock className="w-6 h-6 text-primary-light mx-auto mb-2" />
                <p className="text-xs text-text-secondary dark:text-text-dark-secondary mb-1">Availability</p>
                <p className="font-semibold text-text-primary dark:text-text-dark-primary">
                  Mon - Sat, 9AM - 7PM
                </p>
              </div>
              <div className="text-center p-4 rounded-xl bg-gray-50 dark:bg-surface-dark/50">
                <MapPin className="w-6 h-6 text-primary-light mx-auto mb-2" />
                <p className="text-xs text-text-secondary dark:text-text-dark-secondary mb-1">Location</p>
                <p className="font-semibold text-text-primary dark:text-text-dark-primary">
                  {doctor.distanceKm ? `${doctor.distanceKm.toFixed(1)} km away` : 'Near you'}
                </p>
              </div>
              <div className="text-center p-4 rounded-xl bg-gray-50 dark:bg-surface-dark/50">
                <Info className="w-6 h-6 text-primary-light mx-auto mb-2" />
                <p className="text-xs text-text-secondary dark:text-text-dark-secondary mb-1">Experience</p>
                <p className="font-semibold text-text-primary dark:text-text-dark-primary">
                  {doctor.experience || 5}+ years
                </p>
              </div>
            </div>
          </Card>

          {/* Booking Section */}
          <Card className="p-6 md:p-8">
            <h2 className="text-xl font-bold text-text-primary dark:text-text-dark-primary mb-6">
              Book Appointment
            </h2>

            {bookingSuccess ? (
              <div className="text-center py-10 animate-fade-in">
                <div className="w-20 h-20 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center mx-auto mb-6">
                  <CheckCircle className="w-10 h-10 text-green-600 dark:text-green-400" />
                </div>
                <h3 className="text-2xl font-bold text-text-primary dark:text-text-dark-primary mb-3">
                  Appointment Booked!
                </h3>
                <p className="text-text-secondary dark:text-text-dark-secondary max-w-md mx-auto mb-6">
                  Your appointment with Dr. {doctor.name} has been scheduled successfully.
                  Redirecting to appointments...
                </p>
              </div>
            ) : (
              <>
                {/* Appointment Type */}
                <div className="mb-6">
                  <label className="label">Consultation Type</label>
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    {[
                      { value: 'clinic', label: 'Clinic Visit', icon: MapPin, desc: 'In-person visit' },
                      { value: 'video', label: 'Video Call', icon: Video, desc: 'Online consultation' },
                      { value: 'home', label: 'Home Visit', icon: Stethoscope, desc: 'Doctor visits you' },
                    ].map((type) => (
                      <button
                        key={type.value}
                        onClick={() => setAppointmentType(type.value)}
                        className={`p-4 rounded-xl border-2 text-left transition-all duration-200 ${
                          appointmentType === type.value
                            ? 'border-primary-light bg-primary-light/5 shadow-md'
                            : 'border-border dark:border-border-dark hover:border-gray-300 dark:hover:border-gray-600'
                        }`}
                      >
                        <type.icon className={`w-6 h-6 mb-2 ${
                          appointmentType === type.value ? 'text-primary-light' : 'text-text-secondary dark:text-text-dark-secondary'
                        }`} />
                        <p className={`font-semibold mb-0.5 ${
                          appointmentType === type.value ? 'text-text-primary dark:text-text-dark-primary' : ''
                        }`}>
                          {type.label}
                        </p>
                        <p className="text-xs text-text-secondary dark:text-text-dark-secondary">
                          {type.desc}
                        </p>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Date Selection */}
                <div className="mb-6">
                  <label className="label flex items-center gap-2">
                    <Calendar className="w-4 h-4" />
                    Select Date
                  </label>
                  <div className="flex gap-3 overflow-x-auto pb-2 scrollbar-thin -mx-2 px-2">
                    {dates.map((d) => (
                      <button
                        key={d.date}
                        onClick={() => {
                          setSelectedDate(d.date);
                          setSelectedTime('');
                        }}
                        className={`flex-shrink-0 w-20 py-3 rounded-2xl border-2 text-center transition-all duration-200 ${
                          selectedDate === d.date
                            ? 'border-primary-light bg-primary-light text-white shadow-md'
                            : 'border-border dark:border-border-dark hover:border-gray-300 dark:hover:border-gray-600'
                        }`}
                      >
                        <p className={`text-xs mb-1 ${
                          selectedDate === d.date ? 'text-white/80' : 'text-text-secondary dark:text-text-dark-secondary'
                        }`}>
                          {d.day}
                        </p>
                        <p className={`text-xl font-bold ${
                          selectedDate === d.date ? '' : 'text-text-primary dark:text-text-dark-primary'
                        }`}>
                          {d.dayNum}
                        </p>
                        <p className={`text-xs ${
                          selectedDate === d.date ? 'text-white/80' : 'text-text-secondary dark:text-text-dark-secondary'
                        }`}>
                          {d.month}
                        </p>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Time Selection */}
                <div className="mb-8">
                  <label className="label flex items-center gap-2">
                    <Clock className="w-4 h-4" />
                    Select Time
                    {selectedDate && (
                      <Badge variant="primary" className="ml-2">
                        {new Date(selectedDate).toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' })}
                      </Badge>
                    )}
                  </label>
                  <div className="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 gap-2">
                    {timeSlots.map((time) => (
                      <button
                        key={time}
                        disabled={!selectedDate}
                        onClick={() => setSelectedTime(time)}
                        className={`py-2.5 px-1 rounded-xl font-medium text-sm transition-all duration-200 disabled:opacity-40 disabled:cursor-not-allowed ${
                          selectedTime === time
                            ? 'bg-primary-light text-white shadow-md'
                            : selectedDate
                            ? 'bg-gray-50 dark:bg-surface-dark border border-border dark:border-border-dark hover:border-primary-light text-text-primary dark:text-text-dark-primary'
                            : 'bg-gray-100 dark:bg-surface-dark/50 text-text-secondary dark:text-text-dark-secondary cursor-not-allowed'
                        }`}
                      >
                        {time}
                      </button>
                    ))}
                  </div>
                </div>

                <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 p-5 rounded-2xl bg-gray-50 dark:bg-surface-dark/50">
                  <div>
                    <p className="text-sm text-text-secondary dark:text-text-dark-secondary mb-1">Consultation Fee</p>
                    <p className="text-3xl font-bold text-primary dark:text-primary-light">
                      ₹{doctor.fee || 500}
                    </p>
                  </div>
                  <div className="flex gap-3 w-full sm:w-auto">
                    <Button variant="secondary" className="flex-1 sm:flex-none">
                      <MessageCircle className="w-5 h-5 mr-2" />
                      Chat
                    </Button>
                    <Button
                      onClick={handleBookAppointment}
                      disabled={!selectedDate || !selectedTime}
                      className="flex-1 sm:flex-none"
                      size="lg"
                    >
                      Confirm Booking
                    </Button>
                  </div>
                </div>
              </>
            )}
          </Card>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          <Card className="p-6 sticky top-24">
            <h3 className="font-bold text-text-primary dark:text-text-dark-primary mb-4 text-lg">
              Appointment Summary
            </h3>

            <div className="space-y-4">
              <div className="flex items-center gap-3 pb-4 border-b border-border dark:border-border-dark">
                <div className="w-12 h-12 rounded-xl overflow-hidden bg-gradient-to-br from-primary/10 to-primary-light/20 flex items-center justify-center flex-shrink-0">
                  {doctor.imageUrl ? (
                    <img src={doctor.imageUrl} alt="" className="w-full h-full object-cover" />
                  ) : (
                    <Stethoscope className="w-6 h-6 text-primary dark:text-primary-light" />
                  )}
                </div>
                <div>
                  <p className="font-semibold text-text-primary dark:text-text-dark-primary">
                    Dr. {doctor.name}
                  </p>
                  <p className="text-sm text-text-secondary dark:text-text-dark-secondary">
                    {doctor.specialty}
                  </p>
                </div>
              </div>

              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-text-secondary dark:text-text-dark-secondary">Type</span>
                  <span className="font-medium capitalize text-text-primary dark:text-text-dark-primary">
                    {appointmentType} Visit
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-text-secondary dark:text-text-dark-secondary">Date</span>
                  <span className="font-medium text-text-primary dark:text-text-dark-primary">
                    {selectedDate
                      ? new Date(selectedDate).toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' })
                      : 'Not selected'}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-text-secondary dark:text-text-dark-secondary">Time</span>
                  <span className="font-medium text-text-primary dark:text-text-dark-primary">
                    {selectedTime || 'Not selected'}
                  </span>
                </div>
              </div>

              <div className="pt-4 border-t border-border dark:border-border-dark space-y-3">
                <div className="flex justify-between">
                  <span className="text-text-secondary dark:text-text-dark-secondary">Consultation Fee</span>
                  <span className="font-medium text-text-primary dark:text-text-dark-primary">
                    ₹{doctor.fee || 500}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-text-secondary dark:text-text-dark-secondary">Service Tax</span>
                  <span className="font-medium text-text-primary dark:text-text-dark-primary">
                    ₹{Math.round((doctor.fee || 500) * 0.05)}
                  </span>
                </div>
                <div className="flex justify-between pt-3 border-t border-border dark:border-border-dark">
                  <span className="font-bold text-text-primary dark:text-text-dark-primary">Total</span>
                  <span className="font-bold text-xl text-primary dark:text-primary-light">
                    ₹{Math.round((doctor.fee || 500) * 1.05)}
                  </span>
                </div>
              </div>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default DoctorDetailScreen;
