import React from 'react';

const Footer = () => {
  return (
    <footer className="bg-surface-dark text-text-dark-primary border-t border-border-dark mt-auto">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div className="col-span-1 md:col-span-2">
            <h3 className="text-xl font-bold text-primary-light mb-4">Mediscribe</h3>
            <p className="text-text-dark-secondary mb-4 max-w-md">
              AI-powered healthcare platform connecting patients with doctors,
              enabling prescription digitization, online consultations, and pharmacy services.
            </p>
          </div>

          <div>
            <h4 className="font-semibold mb-4">Services</h4>
            <ul className="space-y-2 text-text-dark-secondary">
              <li>Find Doctors</li>
              <li>Book Appointments</li>
              <li>Pharmacy</li>
              <li>Lab Tests</li>
              <li>Prescription Scan</li>
            </ul>
          </div>

          <div>
            <h4 className="font-semibold mb-4">Support</h4>
            <ul className="space-y-2 text-text-dark-secondary">
              <li>Help Center</li>
              <li>Contact Us</li>
              <li>Privacy Policy</li>
              <li>Terms of Service</li>
            </ul>
          </div>
        </div>

        <div className="border-t border-border-dark mt-8 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
          <p className="text-text-dark-secondary text-sm">
            &copy; {new Date().getFullYear()} Mediscribe. All rights reserved.
          </p>
          <p className="text-text-dark-secondary text-sm">
            Made with care for better healthcare
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
