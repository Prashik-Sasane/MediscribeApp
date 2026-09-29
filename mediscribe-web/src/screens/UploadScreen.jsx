import React, { useState, useRef } from 'react';
import {
  Upload,
  FileScan,
  Image as ImageIcon,
  Camera,
  FileText,
  Copy,
  Download,
  RefreshCw,
  CheckCircle,
  AlertCircle,
  Pill,
  Trash2,
  Sparkles,
  Eye,
} from 'lucide-react';
import Card from '../components/common/Card';
import Badge from '../components/common/Badge';
import Button from '../components/common/Button';
import Loader from '../components/common/Loader';
import { prescriptionService } from '../services/prescriptionService';
import useAppStore from '../store/useAppStore';

const UploadScreen = () => {
  const { setPrescriptionText, addToCart } = useAppStore();
  const [selectedImage, setSelectedImage] = useState(null);
  const [imagePreview, setImagePreview] = useState(null);
  const [analyzing, setAnalyzing] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);
  const [extractedText, setExtractedText] = useState('');
  const [copied, setCopied] = useState(false);
  const fileInputRef = useRef(null);
  const cameraInputRef = useRef(null);

  const handleFileSelect = (e, isCamera = false) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      setError('Please upload a valid image file');
      return;
    }

    setError(null);
    setResult(null);
    setExtractedText('');
    setSelectedImage(file);

    const reader = new FileReader();
    reader.onload = (e) => setImagePreview(e.target.result);
    reader.readAsDataURL(file);
  };

  const triggerFileInput = (camera = false) => {
    if (camera && cameraInputRef.current) {
      cameraInputRef.current.click();
    } else if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  const handleAnalyze = async () => {
    if (!selectedImage) return;

    setAnalyzing(true);
    setError(null);
    try {
      const response = await prescriptionService.analyzePrescription(selectedImage);
      setResult(response);
      const text = response.text || response.extractedText || response.prescriptionText || '';
      setExtractedText(text);
      setPrescriptionText(text);

      if (response.medicines && response.medicines.length > 0) {
      }
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to analyze prescription. Please try again.');
    } finally {
      setAnalyzing(false);
    }
  };

  const handleAnalyzeText = async () => {
    if (!extractedText.trim()) return;
    setAnalyzing(true);
    setError(null);
    try {
      const response = await prescriptionService.analyzeText(extractedText);
      setResult(response);
      setPrescriptionText(extractedText);
    } catch (err) {
      setError(err.response?.data?.message || 'Analysis failed.');
    } finally {
      setAnalyzing(false);
    }
  };

  const handleCopy = async () => {
    await navigator.clipboard.writeText(extractedText);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownload = () => {
    const blob = new Blob([extractedText], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'prescription.txt';
    a.click();
    URL.revokeObjectURL(url);
  };

  const handleReset = () => {
    setSelectedImage(null);
    setImagePreview(null);
    setResult(null);
    setExtractedText('');
    setError(null);
    if (fileInputRef.current) fileInputRef.current.value = '';
    if (cameraInputRef.current) cameraInputRef.current.value = '';
  };

  const mockMedicines = result?.medicines || [
    { name: 'Paracetamol 500mg', dosage: '1-2 tablets', frequency: 'After meals, twice daily', duration: '5 days' },
    { name: 'Amoxicillin 250mg', dosage: '1 tablet', frequency: 'Every 8 hours', duration: '7 days' },
    { name: 'Vitamin C 500mg', dosage: '1 tablet', frequency: 'Once daily, with breakfast', duration: '30 days' },
    { name: 'Pantoprazole 40mg', dosage: '1 tablet', frequency: 'Before breakfast, once daily', duration: '14 days' },
  ];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 lg:py-8">
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-2">
          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-teal-500 to-teal-600 flex items-center justify-center shadow-lg">
            <FileScan className="w-7 h-7 text-white" />
          </div>
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-text-primary dark:text-text-dark-primary">
              Prescription Scanner
            </h1>
            <p className="text-text-secondary dark:text-text-dark-secondary">
              Upload or capture your prescription for AI-powered digitization
            </p>
          </div>
        </div>
      </div>

      {/* How It Works */}
      {!selectedImage && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-5 mb-8">
          {[
            { step: 1, title: 'Upload Prescription', desc: 'Upload a clear photo or PDF of your prescription', icon: Upload },
            { step: 2, title: 'AI Analysis', desc: 'Our AI extracts medicines, dosage, and instructions', icon: Sparkles },
            { step: 3, title: 'Order Medicines', desc: 'Review and add prescribed medicines directly to cart', icon: Pill },
          ].map((item) => (
            <Card key={item.step} className="p-6 text-center">
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-teal-500/10 to-teal-600/10 flex items-center justify-center mx-auto mb-4">
                <item.icon className="w-7 h-7 text-teal-600 dark:text-teal-400" />
              </div>
              <Badge variant="primary" className="mb-3">Step {item.step}</Badge>
              <h3 className="font-bold text-lg text-text-primary dark:text-text-dark-primary mb-2">
                {item.title}
              </h3>
              <p className="text-sm text-text-secondary dark:text-text-dark-secondary">
                {item.desc}
              </p>
            </Card>
          ))}
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 lg:gap-8">
        {/* Upload Section */}
        <div className="space-y-6">
          <Card className="p-6 md:p-8">
            <h2 className="text-xl font-bold text-text-primary dark:text-text-dark-primary mb-6 flex items-center gap-2">
              <Upload className="w-5 h-5 text-teal-500" />
              {selectedImage ? 'Selected Prescription' : 'Upload Prescription'}
            </h2>

            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              onChange={handleFileSelect}
              className="hidden"
            />
            <input
              ref={cameraInputRef}
              type="file"
              accept="image/*"
              capture="environment"
              onChange={(e) => handleFileSelect(e, true)}
              className="hidden"
            />

            {!selectedImage ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <button
                  onClick={() => triggerFileInput(false)}
                  className="group p-8 rounded-2xl border-2 border-dashed border-border dark:border-border-dark hover:border-teal-500 dark:hover:border-teal-400 transition-all duration-300 bg-gray-50 dark:bg-surface-dark/50 hover:bg-teal-50 dark:hover:bg-teal-900/10"
                >
                  <div className="w-16 h-16 rounded-2xl bg-white dark:bg-background-dark shadow-card group-hover:shadow-card-hover flex items-center justify-center mx-auto mb-4 transition-all group-hover:scale-110">
                    <ImageIcon className="w-8 h-8 text-teal-500" />
                  </div>
                  <p className="font-semibold text-text-primary dark:text-text-dark-primary mb-1">
                    Upload Image
                  </p>
                  <p className="text-sm text-text-secondary dark:text-text-dark-secondary">
                    PNG, JPG up to 10MB
                  </p>
                </button>

                <button
                  onClick={() => triggerFileInput(true)}
                  className="group p-8 rounded-2xl border-2 border-dashed border-border dark:border-border-dark hover:border-teal-500 dark:hover:border-teal-400 transition-all duration-300 bg-gray-50 dark:bg-surface-dark/50 hover:bg-teal-50 dark:hover:bg-teal-900/10"
                >
                  <div className="w-16 h-16 rounded-2xl bg-white dark:bg-background-dark shadow-card group-hover:shadow-card-hover flex items-center justify-center mx-auto mb-4 transition-all group-hover:scale-110">
                    <Camera className="w-8 h-8 text-teal-500" />
                  </div>
                  <p className="font-semibold text-text-primary dark:text-text-dark-primary mb-1">
                    Take Photo
                  </p>
                  <p className="text-sm text-text-secondary dark:text-text-dark-secondary">
                    Use your camera
                  </p>
                </button>
              </div>
            ) : (
              <div className="space-y-5">
                <div className="relative rounded-2xl overflow-hidden bg-gray-100 dark:bg-surface-dark/50 border-2 border-border dark:border-border-dark">
                  <img
                    src={imagePreview}
                    alt="Prescription preview"
                    className="w-full max-h-96 object-contain mx-auto"
                  />
                </div>

                <div className="flex flex-wrap gap-3">
                  <Button onClick={handleAnalyze} loading={analyzing} size="lg">
                    <Sparkles className="w-5 h-5 mr-2" />
                    {analyzing ? 'Analyzing...' : 'Analyze Prescription'}
                  </Button>
                  <Button variant="secondary" onClick={handleReset}>
                    <Trash2 className="w-5 h-5 mr-2" />
                    Remove
                  </Button>
                </div>
              </div>
            )}
          </Card>

          {/* Text Input Option */}
          <Card className="p-6 md:p-8">
            <h2 className="text-xl font-bold text-text-primary dark:text-text-dark-primary mb-4 flex items-center gap-2">
              <FileText className="w-5 h-5 text-teal-500" />
              Or Paste Prescription Text
            </h2>
            <textarea
              value={extractedText}
              onChange={(e) => setExtractedText(e.target.value)}
              placeholder="Paste or type your prescription details here. Include medicines, dosage, frequency, and duration..."
              rows={6}
              className="input-field resize-none mb-4"
            />
            <Button
              variant="secondary"
              onClick={handleAnalyzeText}
              loading={analyzing}
              disabled={!extractedText.trim()}
            >
              <Eye className="w-5 h-5 mr-2" />
              Analyze Text
            </Button>
          </Card>
        </div>

        {/* Results Section */}
        <div className="space-y-6">
          {analyzing ? (
            <Card className="p-12">
              <Loader label="AI is analyzing your prescription..." />
              <div className="mt-8 grid grid-cols-3 gap-3">
                {[0, 1, 2].map((i) => (
                  <div key={i} className="animate-pulse">
                    <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded mb-3" />
                    <div className="h-3 bg-gray-100 dark:bg-gray-800 rounded w-3/4 mb-1.5" />
                    <div className="h-3 bg-gray-100 dark:bg-gray-800 rounded w-1/2" />
                  </div>
                ))}
              </div>
            </Card>
          ) : error ? (
            <Card className="p-8 border-2 border-red-200 dark:border-red-800">
              <div className="text-center">
                <div className="w-16 h-16 rounded-full bg-red-100 dark:bg-red-900/20 flex items-center justify-center mx-auto mb-4">
                  <AlertCircle className="w-8 h-8 text-red-600 dark:text-red-400" />
                </div>
                <h3 className="font-bold text-lg text-text-primary dark:text-text-dark-primary mb-2">
                  Analysis Failed
                </h3>
                <p className="text-text-secondary dark:text-text-dark-secondary mb-6">
                  {error}
                </p>
                <Button variant="danger" onClick={handleReset}>
                  Try Again
                </Button>
              </div>
            </Card>
          ) : extractedText ? (
            <>
              {/* Extracted Text */}
              <Card className="p-6 md:p-8">
                <div className="flex items-center justify-between mb-5">
                  <h2 className="text-xl font-bold text-text-primary dark:text-text-dark-primary flex items-center gap-2">
                    <FileText className="w-5 h-5 text-teal-500" />
                    Extracted Text
                  </h2>
                  <div className="flex gap-2">
                    <button
                      onClick={handleCopy}
                      className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-surface-dark transition-colors"
                      title="Copy text"
                    >
                      {copied ? (
                        <CheckCircle className="w-5 h-5 text-green-600" />
                      ) : (
                        <Copy className="w-5 h-5 text-text-secondary dark:text-text-dark-secondary" />
                      )}
                    </button>
                    <button
                      onClick={handleDownload}
                      className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-surface-dark transition-colors"
                      title="Download text"
                    >
                      <Download className="w-5 h-5 text-text-secondary dark:text-text-dark-secondary" />
                    </button>
                  </div>
                </div>
                <div className="bg-gray-50 dark:bg-surface-dark/50 rounded-xl p-5 max-h-64 overflow-y-auto scrollbar-thin">
                  <pre className="whitespace-pre-wrap text-sm text-text-primary dark:text-text-dark-primary font-mono leading-relaxed">
                    {extractedText || 'No text extracted yet.'}
                  </pre>
                </div>
                {result?.confidence && (
                  <div className="mt-4 flex items-center justify-between p-3 bg-green-50 dark:bg-green-900/10 rounded-xl">
                    <span className="text-sm font-medium text-green-700 dark:text-green-400">
                      Confidence Score
                    </span>
                    <Badge variant="success">{Math.round(result.confidence * 100)}%</Badge>
                  </div>
                )}
              </Card>

              {/* Detected Medicines */}
              <Card className="p-6 md:p-8">
                <div className="flex items-center justify-between mb-5">
                  <h2 className="text-xl font-bold text-text-primary dark:text-text-dark-primary flex items-center gap-2">
                    <Pill className="w-5 h-5 text-teal-500" />
                    Detected Medicines ({mockMedicines.length})
                  </h2>
                </div>
                <div className="space-y-3">
                  {mockMedicines.map((med, idx) => (
                    <div
                      key={idx}
                      className="p-4 rounded-xl border border-border dark:border-border-dark hover:border-teal-500 dark:hover:border-teal-400 transition-all group"
                    >
                      <div className="flex items-start justify-between gap-4">
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-2">
                            <Badge variant="primary" className="text-xs">
                              {idx + 1}
                            </Badge>
                            <h3 className="font-bold text-text-primary dark:text-text-dark-primary truncate">
                              {med.name}
                            </h3>
                          </div>
                          <div className="grid grid-cols-2 gap-2 text-sm">
                            <div>
                              <span className="text-text-secondary dark:text-text-dark-secondary text-xs">Dosage</span>
                              <p className="font-medium text-text-primary dark:text-text-dark-primary">{med.dosage}</p>
                            </div>
                            <div>
                              <span className="text-text-secondary dark:text-text-dark-secondary text-xs">Duration</span>
                              <p className="font-medium text-text-primary dark:text-text-dark-primary">{med.duration}</p>
                            </div>
                            <div className="col-span-2">
                              <span className="text-text-secondary dark:text-text-dark-secondary text-xs">Frequency</span>
                              <p className="font-medium text-text-primary dark:text-text-dark-primary">{med.frequency}</p>
                            </div>
                          </div>
                        </div>
                        <Button
                          size="sm"
                          onClick={() => addToCart({
                            id: `med-${idx}`,
                            name: med.name,
                            description: `${med.dosage} - ${med.frequency} - ${med.duration}`,
                            price: Math.floor(Math.random() * 400) + 100,
                            image: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200&h=200&fit=crop',
                            packSize: med.dosage,
                            inStock: true,
                            rating: 4.5,
                            reviews: 100,
                          })}
                          className="flex-shrink-0"
                        >
                          <Plus className="w-4 h-4 mr-1.5" />
                          Add
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>

                <div className="mt-6 pt-5 border-t border-border dark:border-border-dark flex flex-wrap gap-3 items-center justify-between">
                  <div className="text-sm text-text-secondary dark:text-text-dark-secondary">
                    <CheckCircle className="w-4 h-4 inline mr-1.5 text-green-600" />
                    AI-powered extraction. Please verify with your doctor.
                  </div>
                  <Button>
                    <Pill className="w-5 h-5 mr-2" />
                    Add All to Cart
                  </Button>
                </div>
              </Card>

              {/* Doctor Notes */}
              {result?.notes && (
                <Card className="p-6 md:p-8 border-2 border-primary-light/20">
                  <h2 className="text-xl font-bold text-text-primary dark:text-text-dark-primary mb-4">
                    Doctor's Notes
                  </h2>
                  <p className="text-text-secondary dark:text-text-dark-secondary leading-relaxed">
                    {result.notes}
                  </p>
                </Card>
              )}
            </>
          ) : (
            <div className="h-full flex items-center justify-center min-h-[400px]">
              <Card className="w-full p-10 md:p-16 text-center">
                <div className="w-24 h-24 rounded-full bg-teal-500/10 flex items-center justify-center mx-auto mb-6">
                  <FileScan className="w-12 h-12 text-teal-500" />
                </div>
                <h3 className="text-xl font-bold text-text-primary dark:text-text-dark-primary mb-3">
                  No Analysis Yet
                </h3>
                <p className="text-text-secondary dark:text-text-dark-secondary max-w-md mx-auto mb-6">
                  Upload a clear photo of your handwritten or printed prescription,
                  or paste the text to let our AI digitize it for you.
                </p>
                <div className="flex flex-wrap gap-3 justify-center">
                  <div className="flex items-center gap-2 text-sm text-text-secondary dark:text-text-dark-secondary">
                    <Badge variant="success">OCR Technology</Badge>
                    <Badge variant="primary">AI Powered</Badge>
                    <Badge variant="info">Gemini AI</Badge>
                  </div>
                </div>
              </Card>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default UploadScreen;
