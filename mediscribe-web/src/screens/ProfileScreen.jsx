import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import {
  User,
  Mail,
  Phone,
  MapPin,
  Droplets,
  Calendar,
  Edit3,
  LogOut,
  Camera,
  Wallet,
  Award,
  ChevronRight,
  Stethoscope,
  FileText,
  Settings,
  HelpCircle,
  Shield,
  Briefcase,
  DollarSign,
  Star,
  Clock,
} from 'lucide-react';
import Card from '../components/common/Card';
import Badge from '../components/common/Badge';
import Button from '../components/common/Button';
import Input from '../components/common/Input';
import useAppStore from '../store/useAppStore';

const ProfileScreen = () => {
  const { currentUser, logout, updateUserProfile, appointments, isDoctor, doctorAppointments } = useAppStore();
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    name: currentUser?.name || '',
    phone: currentUser?.phone || '',
    bloodGroup: currentUser?.bloodGroup || '',
    upiId: currentUser?.upiId || '',
    city: currentUser?.city || '',
    specialty: currentUser?.specialty || '',
    bio: currentUser?.bio || '',
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSave = () => {
    updateUserProfile(formData);
    setIsEditing(false);
  };

  const totalAppointments = isDoctor ? doctorAppointments.length : appointments.length;
  const completedAppointments = (isDoctor ? doctorAppointments : appointments).filter(
    (a) => a.status === 'completed'
  ).length;

  const stats = [
    { label: 'Total Appointments', value: totalAppointments, icon: Calendar, color: 'from-blue-500 to-blue-600' },
    { label: 'Completed Visits', value: completedAppointments, icon: Stethoscope, color: 'from-green-500 to-green-600' },
    { label: isDoctor ? 'Total Earnings' : 'Health Coins', value: isDoctor ? `₹${completedAppointments * 500}` : currentUser?.coins || 0, icon: Wallet, color: 'from-amber-500 to-amber-600' },
  ];

  const menuItems = isDoctor
    ? [
        { icon: FileText, label: 'Prescription Templates', path: '#' },
        { icon: Briefcase, label: 'Practice Details', path: '#' },
        { icon: DollarSign, label: 'Payment & Payouts', path: '#' },
      ]
    : [
        { icon: FileText, label: 'My Reports', path: '#' },
        { icon: Droplets, label: 'Health Records', path: '#' },
        { icon: Shield, label: 'Insurance Details', path: '#' },
      ];

  const moreMenuItems = [
    { icon: Settings, label: 'Settings', path: '#' },
    { icon: HelpCircle, label: 'Help & Support', path: '#' },
    { icon: Shield, label: 'Privacy Policy', path: '#' },
  ];

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-6 lg:py-8">
      {/* Profile Header Card */}
      <Card className="p-0 mb-8 overflow-hidden">
        {/* Cover */}
        <div className="h-40 md:h-48 bg-gradient-to-r from-primary via-primary-light to-accent-saffron relative">
          <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1557682250-33bd709cbe85?w=1200&h=300&fit=crop')] bg-cover bg-center opacity-30" />
        </div>

        <div className="px-6 md:px-8 pb-8 relative">
          {/* Avatar & Actions */}
          <div className="flex flex-col md:flex-row md:items-end md:justify-between -mt-16 md:-mt-20 mb-6 gap-4">
            <div className="flex flex-col md:flex-row md:items-end gap-4 md:gap-6">
              <div className="relative mx-auto md:mx-0">
                <div className="w-32 h-32 md:w-40 md:h-40 rounded-3xl border-4 border-white dark:border-background-dark bg-gradient-to-br from-primary/10 to-primary-light/20 flex items-center justify-center shadow-xl overflow-hidden">
                  {currentUser?.avatarUrl ? (
                    <img src={currentUser.avatarUrl} alt="" className="w-full h-full object-cover" />
                  ) : (
                    <User className="w-16 h-16 md:w-20 md:h-20 text-primary dark:text-primary-light" />
                  )}
                </div>
                <button className="absolute bottom-2 right-2 w-10 h-10 rounded-xl bg-primary-light text-white shadow-lg hover:bg-primary transition-colors flex items-center justify-center">
                  <Camera className="w-5 h-5" />
                </button>
              </div>

              <div className="text-center md:text-left pb-2">
                <div className="flex flex-wrap items-center justify-center md:justify-start gap-2 mb-2">
                  <h1 className="text-2xl md:text-3xl font-bold text-text-primary dark:text-text-dark-primary">
                    {isDoctor ? 'Dr. ' : ''}{currentUser?.name}
                  </h1>
                  {isDoctor && currentUser?.isVerified && (
                    <Badge variant="success">
                      <Award className="w-3 h-3 mr-1" />
                      Verified
                    </Badge>
                  )}
                </div>
                <p className="text-lg text-primary dark:text-primary-light font-medium mb-2">
                  {isDoctor ? currentUser?.specialty : 'Patient'}
                </p>
                <div className="flex flex-wrap items-center justify-center md:justify-start gap-3 text-sm text-text-secondary dark:text-text-dark-secondary">
                  {currentUser?.email && (
                    <span className="flex items-center gap-1">
                      <Mail className="w-4 h-4" />
                      {currentUser.email}
                    </span>
                  )}
                  {currentUser?.city && (
                    <span className="flex items-center gap-1">
                      <MapPin className="w-4 h-4" />
                      {currentUser.city}
                    </span>
                  )}
                  {isDoctor && (
                    <span className="flex items-center gap-1">
                      <DollarSign className="w-4 h-4 text-primary-light" />
                      ₹{currentUser?.fee || 500}/visit
                    </span>
                  )}
                </div>
              </div>
            </div>

            <div className="flex gap-3 justify-center md:justify-start">
              {!isEditing ? (
                <Button onClick={() => setIsEditing(true)}>
                  <Edit3 className="w-5 h-5 mr-2" />
                  Edit Profile
                </Button>
              ) : (
                <>
                  <Button variant="secondary" onClick={() => setIsEditing(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleSave}>
                    Save Changes
                  </Button>
                </>
              )}
            </div>
          </div>

          {/* Bio */}
          {isDoctor && currentUser?.bio && !isEditing && (
            <div className="p-5 rounded-2xl bg-gray-50 dark:bg-surface-dark/50 mb-6">
              <h3 className="font-semibold text-text-primary dark:text-text-dark-primary mb-2 flex items-center gap-2">
                <FileText className="w-4 h-4" />
                About
              </h3>
              <p className="text-text-secondary dark:text-text-dark-secondary leading-relaxed">
                {currentUser.bio}
              </p>
            </div>
          )}

          {/* Edit Form */}
          {isEditing && (
            <div className="p-6 rounded-2xl bg-gray-50 dark:bg-surface-dark/50 mb-6 animate-fade-in">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                <Input
                  label="Full Name"
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  icon={User}
                />
                <Input
                  label="Phone Number"
                  name="phone"
                  value={formData.phone}
                  onChange={handleChange}
                  icon={Phone}
                  placeholder="+91 98765 43210"
                />
                <Input
                  label="City"
                  name="city"
                  value={formData.city}
                  onChange={handleChange}
                  icon={MapPin}
                />
                {!isDoctor && (
                  <Input
                    label="Blood Group"
                    name="bloodGroup"
                    value={formData.bloodGroup}
                    onChange={handleChange}
                    icon={Droplets}
                    placeholder="O+, A-, AB+"
                  />
                )}
                {isDoctor && (
                  <>
                    <Input
                      label="Specialty"
                      name="specialty"
                      value={formData.specialty}
                      onChange={handleChange}
                      icon={Stethoscope}
                    />
                    <Input
                      label="UPI ID (for payouts)"
                      name="upiId"
                      value={formData.upiId}
                      onChange={handleChange}
                      icon={Wallet}
                      placeholder="yourname@upi"
                    />
                  </>
                )}
              </div>
              {isDoctor && (
                <div className="mt-5">
                  <label className="label">Professional Bio</label>
                  <textarea
                    name="bio"
                    value={formData.bio}
                    onChange={handleChange}
                    rows={4}
                    className="input-field resize-none"
                    placeholder="Tell patients about your experience, expertise, and approach..."
                  />
                </div>
              )}
            </div>
          )}

          {/* Quick Info Grid (non-edit) */}
          {!isEditing && (
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {[
                { icon: Mail, label: 'Email', value: currentUser?.email || 'Not set' },
                { icon: Phone, label: 'Phone', value: currentUser?.phone || 'Not set' },
                !isDoctor
                  ? { icon: Droplets, label: 'Blood Group', value: currentUser?.bloodGroup || 'Not set' }
                  : { icon: Award, label: 'Experience', value: `${currentUser?.experience || 5}+ years` },
                { icon: MapPin, label: 'Location', value: currentUser?.city || 'Not set' },
              ].map((item, idx) => (
                <div key={idx} className="p-4 rounded-xl bg-gray-50 dark:bg-surface-dark/50">
                  <item.icon className="w-5 h-5 text-primary-light mb-2" />
                  <p className="text-xs text-text-secondary dark:text-text-dark-secondary mb-1">{item.label}</p>
                  <p className="font-semibold text-sm text-text-primary dark:text-text-dark-primary truncate">
                    {item.value}
                  </p>
                </div>
              ))}
            </div>
          )}
        </div>
      </Card>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-5 mb-8">
        {stats.map((stat, idx) => (
          <Card key={idx} className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-text-secondary dark:text-text-dark-secondary mb-1">{stat.label}</p>
                <p className="text-2xl md:text-3xl font-bold text-text-primary dark:text-text-dark-primary">
                  {stat.value}
                </p>
              </div>
              <div className={`w-14 h-14 rounded-2xl bg-gradient-to-br ${stat.color} flex items-center justify-center shadow-lg`}>
                <stat.icon className="w-7 h-7 text-white" />
              </div>
            </div>
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        {/* My Menu */}
        <Card className="p-6">
          <h3 className="font-bold text-lg text-text-primary dark:text-text-dark-primary mb-4">
            {isDoctor ? 'Practice Management' : 'My Health'}
          </h3>
          <div className="space-y-1">
            {menuItems.map((item, idx) => (
              <Link
                key={idx}
                to={item.path}
                className="flex items-center justify-between p-4 rounded-xl hover:bg-gray-50 dark:hover:bg-surface-dark/50 transition-colors group"
              >
                <div className="flex items-center gap-4">
                  <div className="w-11 h-11 rounded-xl bg-primary-light/10 flex items-center justify-center group-hover:bg-primary-light/20 transition-colors">
                    <item.icon className="w-5 h-5 text-primary-light" />
                  </div>
                  <span className="font-medium text-text-primary dark:text-text-dark-primary">
                    {item.label}
                  </span>
                </div>
                <ChevronRight className="w-5 h-5 text-text-secondary dark:text-text-dark-secondary group-hover:translate-x-1 transition-transform" />
              </Link>
            ))}
          </div>
        </Card>

        {/* Doctor Ratings */}
        {isDoctor && (
          <Card className="p-6">
            <h3 className="font-bold text-lg text-text-primary dark:text-text-dark-primary mb-4 flex items-center gap-2">
              <Star className="w-5 h-5 text-yellow-500 fill-yellow-500" />
              Ratings & Reviews
            </h3>
            <div className="text-center py-6">
              <div className="text-5xl font-extrabold text-text-primary dark:text-text-dark-primary mb-2">
                4.8
              </div>
              <div className="flex items-center justify-center gap-1 mb-3">
                {[1, 2, 3, 4, 5].map((s) => (
                  <Star
                    key={s}
                    className={`w-6 h-6 ${
                      s <= 4 || (s === 5 && Math.random() > 0.5) ? 'text-yellow-500 fill-yellow-500' : 'text-gray-300'
                    }`}
                  />
                ))}
              </div>
              <p className="text-text-secondary dark:text-text-dark-secondary mb-6">
                Based on 247 patient reviews
              </p>
              <div className="space-y-2 text-left">
                {[
                  { stars: 5, percent: 78 },
                  { stars: 4, percent: 15 },
                  { stars: 3, percent: 4 },
                  { stars: 2, percent: 2 },
                  { stars: 1, percent: 1 },
                ].map((row) => (
                  <div key={row.stars} className="flex items-center gap-3">
                    <div className="flex items-center gap-1 w-12">
                      <Star className="w-3.5 h-3.5 text-yellow-500 fill-yellow-500" />
                      <span className="text-xs font-medium text-text-primary dark:text-text-dark-primary">
                        {row.stars}
                      </span>
                    </div>
                    <div className="flex-1 h-2 bg-gray-100 dark:bg-gray-800 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-yellow-500 rounded-full"
                        style={{ width: `${row.percent}%` }}
                      />
                    </div>
                    <span className="text-xs w-10 text-right text-text-secondary dark:text-text-dark-secondary">
                      {row.percent}%
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </Card>
        )}

        {!isDoctor && (
          <Card className="p-6">
            <h3 className="font-bold text-lg text-text-primary dark:text-text-dark-primary mb-4">
              Upcoming Reminders
            </h3>
            <div className="space-y-3">
              {[
                { title: 'Follow-up with Dr. Sharma', time: 'Tomorrow, 10:00 AM', type: 'appointment' },
                { title: 'Vitamin D supplements', time: 'Daily, after breakfast', type: 'medicine' },
                { title: 'Blood pressure check', time: 'Every Sunday, 9:00 AM', type: 'test' },
              ].map((rem, idx) => (
                <div key={idx} className="flex items-center gap-4 p-3 rounded-xl hover:bg-gray-50 dark:hover:bg-surface-dark/50 transition-colors">
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 ${
                    rem.type === 'appointment' ? 'bg-blue-100 dark:bg-blue-900/20 text-blue-600' :
                    rem.type === 'medicine' ? 'bg-green-100 dark:bg-green-900/20 text-green-600' :
                    'bg-purple-100 dark:bg-purple-900/20 text-purple-600'
                  }`}>
                    {rem.type === 'appointment' ? <Calendar className="w-5 h-5" /> :
                     rem.type === 'medicine' ? <Stethoscope className="w-5 h-5" /> :
                     <Clock className="w-5 h-5" />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-medium text-sm text-text-primary dark:text-text-dark-primary truncate">{rem.title}</p>
                    <p className="text-xs text-text-secondary dark:text-text-dark-secondary">{rem.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </Card>
        )}
      </div>

      {/* More Options */}
      <Card className="p-6 mb-8">
        <h3 className="font-bold text-lg text-text-primary dark:text-text-dark-primary mb-4">
          More Options
        </h3>
        <div className="space-y-1">
          {moreMenuItems.map((item, idx) => (
            <Link
              key={idx}
              to={item.path}
              className="flex items-center justify-between p-4 rounded-xl hover:bg-gray-50 dark:hover:bg-surface-dark/50 transition-colors group"
            >
              <div className="flex items-center gap-4">
                <div className="w-11 h-11 rounded-xl bg-gray-100 dark:bg-surface-dark flex items-center justify-center group-hover:bg-primary-light/10 transition-colors">
                  <item.icon className="w-5 h-5 text-text-secondary dark:text-text-dark-secondary group-hover:text-primary-light transition-colors" />
                </div>
                <span className="font-medium text-text-primary dark:text-text-dark-primary">
                  {item.label}
                </span>
              </div>
              <ChevronRight className="w-5 h-5 text-text-secondary dark:text-text-dark-secondary group-hover:translate-x-1 transition-transform" />
            </Link>
          ))}
        </div>
      </Card>

      {/* Logout */}
      <Card className="p-6 border-2 border-red-100 dark:border-red-900/30">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="flex items-start sm:items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-red-100 dark:bg-red-900/20 flex items-center justify-center flex-shrink-0">
              <LogOut className="w-6 h-6 text-red-600 dark:text-red-400" />
            </div>
            <div>
              <h3 className="font-bold text-text-primary dark:text-text-dark-primary">
                Logout of Mediscribe
              </h3>
              <p className="text-sm text-text-secondary dark:text-text-dark-secondary">
                You will need to sign in again to access your account.
              </p>
            </div>
          </div>
          <Button variant="danger" size="lg" onClick={logout}>
            Logout
          </Button>
        </div>
      </Card>
    </div>
  );
};

export default ProfileScreen;
