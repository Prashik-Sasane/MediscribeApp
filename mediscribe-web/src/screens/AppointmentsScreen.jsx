import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  Calendar,
  Clock,
  MapPin,
  Video,
  Stethoscope,
  Star,
  XCircle,
  CheckCircle,
  AlertCircle,
  ChevronRight,
  Plus,
  User,
} from 'lucide-react';
import Card from '../components/common/Card';
import Badge from '../components/common/Badge';
import Button from '../components/common/Button';
import Loader from '../components/common/Loader';
import useAppStore from '../store/useAppStore';
import { appointmentService } from '../services/appointmentService';

const tabs = [
  { id: 'upcoming', label: 'Upcoming', status: 'upcoming' },
  { id: 'completed', label: 'Completed', status: 'completed' },
  { id: 'cancelled', label: 'Cancelled', status: 'cancelled' },
  { id: 'all', label: 'All', status: null },
];

const AppointmentsScreen = () => {
  const {
    appointments,
    doctorAppointments,
    isDoctor,
    loadAppointments,
    loadDoctorAppointments,
    cancelAppointment,
    currentUser,
  } = useAppStore();
  const [activeTab, setActiveTab] = useState('upcoming');
  const [loading, setLoading] = useState(true);
  const [cancellingId, setCancellingId] = useState(null);
  const [ratingAppt, setRatingAppt] = useState(null);
  const [rating, setRating] = useState(0);
  const [review, setReview] = useState('');

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      try {
        if (isDoctor) {
          await loadDoctorAppointments();
        } else {
          await loadAppointments();
        }
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, [isDoctor, loadAppointments, loadDoctorAppointments]);

  const allAppointments = isDoctor ? doctorAppointments : appointments;

  const filteredAppointments = React.useMemo(() => {
    const tab = tabs.find((t) => t.id === activeTab);
    if (!tab?.status) return allAppointments;
    return allAppointments.filter((a) => a.status === tab.status);
  }, [allAppointments, activeTab]);

  const handleCancel = async (id) => {
    setCancellingId(id);
    await cancelAppointment(id);
    setCancellingId(null);
  };

  const handleRate = async () => {
    if (ratingAppt && rating > 0) {
      try {
        await appointmentService.updateStatus(ratingAppt.id, 'completed');
        if (isDoctor) {
          await loadDoctorAppointments();
        } else {
          await loadAppointments();
        }
      } catch (e) {
        console.error('Rating failed:', e);
      }
      setRatingAppt(null);
      setRating(0);
      setReview('');
    }
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case 'upcoming':
        return (
          <Badge variant="info">
            <Calendar className="w-3 h-3 mr-1" />
            Upcoming
          </Badge>
        );
      case 'completed':
        return (
          <Badge variant="success">
            <CheckCircle className="w-3 h-3 mr-1" />
            Completed
          </Badge>
        );
      case 'cancelled':
        return (
          <Badge variant="danger">
            <XCircle className="w-3 h-3 mr-1" />
            Cancelled
          </Badge>
        );
      default:
        return <Badge variant="gray">{status}</Badge>;
    }
  };

  const getTypeBadge = (type) => {
    switch (type) {
      case 'video':
        return (
          <Badge variant="primary" className="flex items-center gap-1">
            <Video className="w-3 h-3" />
            Video
          </Badge>
        );
      case 'home':
        return (
          <Badge variant="warning" className="flex items-center gap-1">
            <User className="w-3 h-3" />
            Home
          </Badge>
        );
      default:
        return (
          <Badge variant="gray" className="flex items-center gap-1">
            <MapPin className="w-3 h-3" />
            Clinic
          </Badge>
        );
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader label="Loading appointments..." />
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 lg:py-8">
      <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-8 gap-4">
        <div>
          <h1 className="text-2xl md:text-3xl font-bold text-text-primary dark:text-text-dark-primary mb-2">
            {isDoctor ? 'My Appointments' : 'My Appointments'}
          </h1>
          <p className="text-text-secondary dark:text-text-dark-secondary">
            {isDoctor
              ? `Manage appointments with your patients`
              : `You have ${allAppointments.filter((a) => a.status === 'upcoming').length} upcoming appointments`}
          </p>
        </div>
        {!isDoctor && (
          <Link to="/doctors">
            <Button>
              <Plus className="w-5 h-5 mr-2" />
              Book Appointment
            </Button>
          </Link>
        )}
      </div>

      {/* Tabs */}
      <div className="mb-6 overflow-x-auto scrollbar-thin -mx-2 px-2">
        <div className="flex gap-2 p-1 bg-gray-100 dark:bg-surface-dark/50 rounded-2xl w-max min-w-full sm:min-w-0">
          {tabs.map((tab) => {
            const count = tab.status
              ? allAppointments.filter((a) => a.status === tab.status).length
              : allAppointments.length;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center gap-2 px-5 py-2.5 rounded-xl font-semibold text-sm transition-all duration-200 whitespace-nowrap ${
                  activeTab === tab.id
                    ? 'bg-white dark:bg-background-dark text-primary-light shadow-md'
                    : 'text-text-secondary dark:text-text-dark-secondary hover:text-text-primary dark:hover:text-text-dark-primary'
                }`}
              >
                {tab.label}
                <span className={`px-2 py-0.5 rounded-full text-xs ${
                  activeTab === tab.id
                    ? 'bg-primary-light/10 text-primary-light'
                    : 'bg-gray-200 dark:bg-gray-700 text-text-secondary dark:text-text-dark-secondary'
                }`}>
                  {count}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Appointments List */}
      {filteredAppointments.length === 0 ? (
        <Card className="p-16 text-center">
          <Calendar className="w-20 h-20 mx-auto text-text-secondary/20 dark:text-text-dark-secondary/20 mb-6" />
          <h3 className="text-xl font-semibold text-text-primary dark:text-text-dark-primary mb-3">
            No {activeTab !== 'all' ? activeTab : ''} appointments
          </h3>
          <p className="text-text-secondary dark:text-text-dark-secondary max-w-md mx-auto mb-8">
            {activeTab === 'upcoming' && !isDoctor
              ? "You don't have any upcoming appointments. Book a consultation with one of our verified doctors."
              : activeTab === 'completed'
              ? 'Your completed appointments will appear here.'
              : activeTab === 'cancelled'
              ? 'Cancelled appointments will appear here.'
              : 'Start by booking your first appointment.'}
          </p>
          {!isDoctor && (
            <Link to="/doctors">
              <Button size="lg">
                Find a Doctor
                <ChevronRight className="w-5 h-5 ml-1" />
              </Button>
            </Link>
          )}
        </Card>
      ) : (
        <div className="space-y-5">
          {filteredAppointments.map((appt) => (
            <Card key={appt.id} className="p-5 md:p-6">
              <div className="flex flex-col lg:flex-row lg:items-start gap-6">
                {/* Doctor/Patient Info */}
                <div className="flex items-start gap-4 lg:w-72 flex-shrink-0">
                  <div className="w-16 h-16 rounded-2xl overflow-hidden bg-gradient-to-br from-primary/10 to-primary-light/20 flex items-center justify-center flex-shrink-0">
                    {isDoctor ? (
                      <div className="flex items-center justify-center w-full h-full">
                        <User className="w-8 h-8 text-primary dark:text-primary-light" />
                      </div>
                    ) : (
                      <Stethoscope className="w-8 h-8 text-primary dark:text-primary-light" />
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2 mb-1">
                      <h3 className="font-bold text-lg text-text-primary dark:text-text-dark-primary truncate">
                        {isDoctor ? appt.patientName || 'Patient' : `Dr. ${appt.doctorName}`}
                      </h3>
                    </div>
                    <p className="text-text-secondary dark:text-text-dark-secondary mb-2">
                      {appt.specialty}
                    </p>
                    <div className="flex items-center gap-2">
                      {getStatusBadge(appt.status)}
                      {getTypeBadge(appt.type)}
                    </div>
                  </div>
                </div>

                {/* Details */}
                <div className="flex-1 grid grid-cols-1 sm:grid-cols-2 gap-4 lg:gap-6 py-4 lg:py-0 lg:px-6 lg:border-x border-border dark:border-border-dark">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-blue-50 dark:bg-blue-900/20 flex items-center justify-center flex-shrink-0">
                      <Calendar className="w-5 h-5 text-primary-light" />
                    </div>
                    <div>
                      <p className="text-xs text-text-secondary dark:text-text-dark-secondary mb-0.5">Date</p>
                      <p className="font-semibold text-text-primary dark:text-text-dark-primary">
                        {appt.dateLabel}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-green-50 dark:bg-green-900/20 flex items-center justify-center flex-shrink-0">
                      <Clock className="w-5 h-5 text-green-600 dark:text-green-400" />
                    </div>
                    <div>
                      <p className="text-xs text-text-secondary dark:text-text-dark-secondary mb-0.5">Time</p>
                      <p className="font-semibold text-text-primary dark:text-text-dark-primary">
                        {appt.timeLabel}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-3 sm:col-span-2">
                    <div className="w-10 h-10 rounded-xl bg-orange-50 dark:bg-orange-900/20 flex items-center justify-center flex-shrink-0">
                      <MapPin className="w-5 h-5 text-orange-600 dark:text-orange-400" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-xs text-text-secondary dark:text-text-dark-secondary mb-0.5">
                        {appt.type === 'video' ? 'Platform' : 'Location'}
                      </p>
                      <p className="font-semibold text-text-primary dark:text-text-dark-primary truncate">
                        {appt.location}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Actions */}
                <div className="flex flex-col gap-3 lg:w-64 flex-shrink-0 lg:border-l lg:pl-6 border-border dark:border-border-dark">
                  {appt.status === 'upcoming' && (
                    <>
                      {appt.type === 'video' && (
                        <Button className="w-full">
                          <Video className="w-5 h-5 mr-2" />
                          Join Video Call
                        </Button>
                      )}

                      {!isDoctor ? (
                        <Button
                          variant="danger"
                          onClick={() => handleCancel(appt.id)}
                          loading={cancellingId === appt.id}
                          disabled={cancellingId !== null}
                          className="w-full"
                        >
                          <XCircle className="w-5 h-5 mr-2" />
                          Cancel
                        </Button>
                      ) : (
                        <Button
                          variant="secondary"
                          onClick={() => setRatingAppt(appt)}
                          className="w-full"
                        >
                          <CheckCircle className="w-5 h-5 mr-2" />
                          Mark Complete
                        </Button>
                      )}

                      <Link to={`/chat/${isDoctor ? appt.patientId : appt.doctorId}`} className="w-full">
                        <Button variant="secondary" className="w-full">
                          <AlertCircle className="w-5 h-5 mr-2" />
                          {isDoctor ? 'Message Patient' : 'Message Doctor'}
                        </Button>
                      </Link>
                    </>
                  )}

                  {appt.status === 'completed' && !appt.rating && !isDoctor && (
                    <Button variant="secondary" onClick={() => setRatingAppt(appt)} className="w-full">
                      <Star className="w-5 h-5 mr-2" />
                      Rate Appointment
                    </Button>
                  )}

                  {appt.rating && (
                    <div className="p-3 rounded-xl bg-gray-50 dark:bg-surface-dark/50">
                      <div className="flex items-center gap-1 mb-2">
                        {[1, 2, 3, 4, 5].map((s) => (
                          <Star
                            key={s}
                            className={`w-4 h-4 ${
                              s <= appt.rating
                                ? 'text-yellow-500 fill-yellow-500'
                                : 'text-gray-300 dark:text-gray-600'
                            }`}
                          />
                        ))}
                      </div>
                      {appt.review && (
                        <p className="text-xs text-text-secondary dark:text-text-dark-secondary italic">
                          "{appt.review}"
                        </p>
                      )}
                    </div>
                  )}

                  {appt.prescriptionText && (
                    <div className="p-4 rounded-xl bg-primary-light/5 border border-primary-light/20">
                      <p className="text-xs font-semibold text-primary-light mb-2 flex items-center gap-1">
                        <Stethoscope className="w-3.5 h-3.5" />
                        Prescription
                      </p>
                      <p className="text-sm text-text-secondary dark:text-text-dark-secondary line-clamp-3">
                        {appt.prescriptionText}
                      </p>
                    </div>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Rating Modal */}
      {ratingAppt && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4 animate-fade-in">
          <Card className="max-w-md w-full p-8 animate-slide-up">
            <h3 className="text-2xl font-bold text-text-primary dark:text-text-dark-primary mb-2">
              {isDoctor ? 'Mark Complete' : 'Rate Your Appointment'}
            </h3>
            <p className="text-text-secondary dark:text-text-dark-secondary mb-6">
              {isDoctor
                ? 'Confirm this appointment has been completed.'
                : `How was your experience with Dr. ${ratingAppt.doctorName}?`}
            </p>

            {!isDoctor && (
              <>
                <div className="mb-6">
                  <label className="label">Rating</label>
                  <div className="flex items-center gap-2">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <button
                        key={star}
                        onClick={() => setRating(star)}
                        className="p-1 transition-transform hover:scale-110"
                      >
                        <Star
                          className={`w-10 h-10 transition-colors ${
                            star <= rating
                              ? 'text-yellow-500 fill-yellow-500'
                              : 'text-gray-300 dark:text-gray-600 hover:text-yellow-400'
                          }`}
                        />
                      </button>
                    ))}
                    {rating > 0 && (
                      <span className="ml-3 text-lg font-bold text-text-primary dark:text-text-dark-primary">
                        {rating}/5
                      </span>
                    )}
                  </div>
                </div>

                <div className="mb-8">
                  <label className="label">Write a review (optional)</label>
                  <textarea
                    value={review}
                    onChange={(e) => setReview(e.target.value)}
                    placeholder="Share your experience..."
                    rows={4}
                    className="input-field resize-none"
                  />
                </div>
              </>
            )}

            <div className="flex gap-3">
              <Button
                variant="secondary"
                onClick={() => {
                  setRatingAppt(null);
                  setRating(0);
                  setReview('');
                }}
                className="flex-1"
              >
                Cancel
              </Button>
              <Button
                onClick={handleRate}
                disabled={!isDoctor && rating === 0}
                className="flex-1"
              >
                {isDoctor ? 'Confirm' : 'Submit Rating'}
              </Button>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
};

export default AppointmentsScreen;
