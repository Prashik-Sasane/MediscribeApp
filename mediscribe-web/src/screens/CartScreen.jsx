import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  ShoppingCart,
  Plus,
  Minus,
  Trash2,
  ArrowLeft,
  Package,
  Truck,
  Shield,
  Tag,
  CreditCard,
  Stethoscope,
} from 'lucide-react';
import Card from '../components/common/Card';
import Button from '../components/common/Button';
import Badge from '../components/common/Badge';
import useAppStore from '../store/useAppStore';

const CartScreen = () => {
  const navigate = useNavigate();
  const {
    cartEntries,
    cartCount,
    cartSubtotal,
    updateQuantity,
    removeFromCart,
    clearCart,
    currentUser,
  } = useAppStore();

  const deliveryFee = cartSubtotal >= 999 ? 0 : 49;
  const savings = cartEntries.reduce(
    (sum, entry) =>
      sum + ((entry.product.originalPrice || entry.product.price) - entry.product.price) * entry.quantity,
    0
  );
  const tax = Math.round(cartSubtotal * 0.05);
  const total = cartSubtotal + deliveryFee + tax;

  const promoCode = 'MEDI30';
  const discount = Math.round(cartSubtotal * 0.05);
  const finalTotal = total - discount;

  if (cartCount === 0) {
    return (
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <Link
          to="/pharmacy"
          className="inline-flex items-center gap-2 text-text-secondary dark:text-text-dark-secondary hover:text-primary dark:hover:text-primary-light font-medium mb-8 transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
          Continue Shopping
        </Link>

        <Card className="p-16 text-center">
          <div className="w-24 h-24 rounded-full bg-primary-light/10 flex items-center justify-center mx-auto mb-6">
            <ShoppingCart className="w-12 h-12 text-primary-light" />
          </div>
          <h2 className="text-2xl font-bold text-text-primary dark:text-text-dark-primary mb-3">
            Your cart is empty
          </h2>
          <p className="text-text-secondary dark:text-text-dark-secondary max-w-md mx-auto mb-8">
            Looks like you haven't added any products to your cart yet.
            Start shopping to fill it up!
          </p>
          <Link to="/pharmacy">
            <Button size="lg">
              <Package className="w-5 h-5 mr-2" />
              Browse Products
            </Button>
          </Link>
        </Card>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 lg:py-8">
      <Link
        to="/pharmacy"
        className="inline-flex items-center gap-2 text-text-secondary dark:text-text-dark-secondary hover:text-primary dark:hover:text-primary-light font-medium mb-6 transition-colors"
      >
        <ArrowLeft className="w-5 h-5" />
        Continue Shopping
      </Link>

      <div className="flex flex-col lg:flex-row gap-6 lg:gap-8">
        {/* Cart Items */}
        <div className="flex-1 space-y-5">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl md:text-3xl font-bold text-text-primary dark:text-text-dark-primary">
              Shopping Cart
            </h1>
            <Badge variant="primary" className="text-base px-4 py-1.5">
              {cartCount} {cartCount === 1 ? 'Item' : 'Items'}
            </Badge>
          </div>

          {/* Benefits Bar */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <div className="flex items-center gap-3 p-4 rounded-xl bg-green-50 dark:bg-green-900/10 border border-green-200 dark:border-green-800/30">
              <div className="w-10 h-10 rounded-xl bg-green-100 dark:bg-green-900/30 flex items-center justify-center flex-shrink-0">
                <Truck className="w-5 h-5 text-green-600 dark:text-green-400" />
              </div>
              <div>
                <p className="text-xs font-semibold text-green-700 dark:text-green-400">
                  {cartSubtotal >= 999 ? 'FREE Delivery' : 'Free on orders above ₹999'}
                </p>
                <p className="text-xs text-green-600/80 dark:text-green-400/70">
                  {cartSubtotal >= 999 ? 'Your order qualifies' : `Add ₹${999 - cartSubtotal} more`}
                </p>
              </div>
            </div>
            <div className="flex items-center gap-3 p-4 rounded-xl bg-blue-50 dark:bg-blue-900/10 border border-blue-200 dark:border-blue-800/30">
              <div className="w-10 h-10 rounded-xl bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center flex-shrink-0">
                <Shield className="w-5 h-5 text-blue-600 dark:text-blue-400" />
              </div>
              <div>
                <p className="text-xs font-semibold text-blue-700 dark:text-blue-400">100% Authentic</p>
                <p className="text-xs text-blue-600/80 dark:text-blue-400/70">Genuine medicines only</p>
              </div>
            </div>
            <div className="flex items-center gap-3 p-4 rounded-xl bg-purple-50 dark:bg-purple-900/10 border border-purple-200 dark:border-purple-800/30">
              <div className="w-10 h-10 rounded-xl bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center flex-shrink-0">
                <Tag className="w-5 h-5 text-purple-600 dark:text-purple-400" />
              </div>
              <div>
                <p className="text-xs font-semibold text-purple-700 dark:text-purple-400">Best Prices</p>
                <p className="text-xs text-purple-600/80 dark:text-purple-400/70">You're saving ₹{savings}</p>
              </div>
            </div>
          </div>

          {/* Cart List */}
          <div className="space-y-4">
            {cartEntries.map((entry) => (
              <Card key={entry.product.id} className="p-4 md:p-5">
                <div className="flex flex-col sm:flex-row gap-4">
                  <div className="w-full sm:w-28 h-28 rounded-xl overflow-hidden bg-gray-50 dark:bg-surface-dark/50 flex-shrink-0">
                    <img
                      src={entry.product.image || 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200&h=200&fit=crop'}
                      alt={entry.product.name}
                      className="w-full h-full object-cover"
                    />
                  </div>

                  <div className="flex-1 flex flex-col sm:flex-row sm:items-center gap-4">
                    <div className="flex-1 min-w-0">
                      <h3 className="font-bold text-text-primary dark:text-text-dark-primary mb-1 line-clamp-1">
                        {entry.product.name}
                      </h3>
                      <p className="text-sm text-text-secondary dark:text-text-dark-secondary mb-2 line-clamp-1">
                        {entry.product.description}
                      </p>
                      {entry.product.packSize && (
                        <p className="text-xs text-text-secondary/70 dark:text-text-dark-secondary/70 mb-2">
                          Pack: {entry.product.packSize}
                        </p>
                      )}
                      <div className="flex items-baseline gap-2">
                        <span className="text-xl font-bold text-text-primary dark:text-text-dark-primary">
                          ₹{entry.product.price}
                        </span>
                        {entry.product.originalPrice && entry.product.originalPrice > entry.product.price && (
                          <>
                            <span className="text-sm text-text-secondary dark:text-text-dark-secondary line-through">
                              ₹{entry.product.originalPrice}
                            </span>
                            <Badge variant="danger" className="text-xs">
                              Save ₹{(entry.product.originalPrice - entry.product.price) * entry.quantity}
                            </Badge>
                          </>
                        )}
                      </div>
                    </div>

                    <div className="flex sm:flex-col items-center sm:items-end justify-between sm:justify-center gap-4">
                      <div className="flex items-center gap-2 bg-gray-100 dark:bg-surface-dark rounded-xl p-1.5">
                        <button
                          onClick={() => updateQuantity(entry.product.id, entry.quantity - 1)}
                          className="w-9 h-9 rounded-lg bg-white dark:bg-background-dark flex items-center justify-center hover:bg-gray-200 dark:hover:bg-gray-800 transition-colors"
                        >
                          <Minus className="w-4 h-4" />
                        </button>
                        <span className="w-8 text-center font-bold text-text-primary dark:text-text-dark-primary">
                          {entry.quantity}
                        </span>
                        <button
                          onClick={() => updateQuantity(entry.product.id, entry.quantity + 1)}
                          className="w-9 h-9 rounded-lg bg-primary-light text-white flex items-center justify-center hover:bg-primary transition-colors"
                        >
                          <Plus className="w-4 h-4" />
                        </button>
                      </div>

                      <div className="flex items-center gap-4">
                        <div className="text-right sm:hidden">
                          <p className="text-xs text-text-secondary dark:text-text-dark-secondary mb-0.5">Subtotal</p>
                          <p className="text-lg font-bold text-primary dark:text-primary-light">
                            ₹{entry.product.price * entry.quantity}
                          </p>
                        </div>
                        <button
                          onClick={() => removeFromCart(entry.product.id)}
                          className="p-2.5 rounded-xl text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
                          title="Remove item"
                        >
                          <Trash2 className="w-5 h-5" />
                        </button>
                      </div>

                      <div className="text-right hidden sm:block">
                        <p className="text-xs text-text-secondary dark:text-text-dark-secondary mb-0.5">Subtotal</p>
                        <p className="text-lg font-bold text-primary dark:text-primary-light">
                          ₹{entry.product.price * entry.quantity}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </Card>
            ))}
          </div>

          <div className="flex justify-end">
            <Button variant="ghost" onClick={clearCart}>
              <Trash2 className="w-4 h-4 mr-2" />
              Clear Cart
            </Button>
          </div>
        </div>

        {/* Order Summary */}
        <div className="lg:w-96 flex-shrink-0">
          <div className="sticky top-24 space-y-5">
            {/* Promo Code */}
            <Card className="p-5">
              <h3 className="font-bold text-text-primary dark:text-text-dark-primary mb-4 flex items-center gap-2">
                <Tag className="w-5 h-5 text-primary-light" />
                Apply Promo Code
              </h3>
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="Enter code"
                  defaultValue={promoCode}
                  readOnly
                  className="flex-1 px-4 py-2.5 bg-gray-50 dark:bg-surface-dark border border-border dark:border-border-dark rounded-xl font-mono font-semibold text-primary-light uppercase"
                />
                <Button variant="secondary" disabled>
                  Applied
                </Button>
              </div>
              <p className="text-xs text-green-600 dark:text-green-400 mt-2 flex items-center gap-1">
                <Shield className="w-3.5 h-3.5" />
                MEDI30 applied - 5% off up to ₹500
              </p>
            </Card>

            {/* Price Summary */}
            <Card className="p-5">
              <h3 className="font-bold text-lg text-text-primary dark:text-text-dark-primary mb-5 flex items-center gap-2">
                <CreditCard className="w-5 h-5 text-primary-light" />
                Order Summary
              </h3>

              <div className="space-y-4 mb-5">
                <div className="flex justify-between">
                  <span className="text-text-secondary dark:text-text-dark-secondary">
                    Subtotal ({cartCount} items)
                  </span>
                  <span className="font-medium text-text-primary dark:text-text-dark-primary">
                    ₹{cartSubtotal}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-text-secondary dark:text-text-dark-secondary">
                    Packing & Delivery Fee
                  </span>
                  <span className={`font-medium ${deliveryFee === 0 ? 'text-green-600 dark:text-green-400' : 'text-text-primary dark:text-text-dark-primary'}`}>
                    {deliveryFee === 0 ? 'FREE' : `₹${deliveryFee}`}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-text-secondary dark:text-text-dark-secondary">
                    GST (5%)
                  </span>
                  <span className="font-medium text-text-primary dark:text-text-dark-primary">
                    ₹{tax}
                  </span>
                </div>
              </div>

              <div className="pt-4 border-t border-border dark:border-border-dark space-y-3">
                <div className="flex justify-between">
                  <span className="text-text-secondary dark:text-text-dark-secondary">
                    Total Savings
                  </span>
                  <span className="font-semibold text-green-600 dark:text-green-400">
                    - ₹{savings + discount}
                  </span>
                </div>
                <div className="flex justify-between pt-3 border-t border-border dark:border-border-dark">
                  <span className="font-bold text-lg text-text-primary dark:text-text-dark-primary">
                    Total Amount
                  </span>
                  <span className="font-extrabold text-2xl text-primary dark:text-primary-light">
                    ₹{finalTotal}
                  </span>
                </div>
              </div>

              <div className="mt-6 space-y-3">
                <Button
                  className="w-full"
                  size="lg"
                  onClick={() => navigate('/payment', { state: { amount: finalTotal, orderType: 'pharmacy' } })}
                >
                  <CreditCard className="w-5 h-5 mr-2" />
                  Proceed to Checkout
                </Button>

                {!currentUser && (
                  <p className="text-xs text-center text-text-secondary dark:text-text-dark-secondary">
                    You'll need to sign in before checkout
                  </p>
                )}
              </div>

              {/* Trust Badges */}
              <div className="mt-6 pt-6 border-t border-border dark:border-border-dark grid grid-cols-3 gap-3">
                <div className="text-center">
                  <Shield className="w-6 h-6 mx-auto mb-1.5 text-primary-light" />
                  <p className="text-[10px] text-text-secondary dark:text-text-dark-secondary font-medium">
                    Secure Checkout
                  </p>
                </div>
                <div className="text-center">
                  <Stethoscope className="w-6 h-6 mx-auto mb-1.5 text-primary-light" />
                  <p className="text-[10px] text-text-secondary dark:text-text-dark-secondary font-medium">
                    100% Genuine
                  </p>
                </div>
                <div className="text-center">
                  <Truck className="w-6 h-6 mx-auto mb-1.5 text-primary-light" />
                  <p className="text-[10px] text-text-secondary dark:text-text-dark-secondary font-medium">
                    Fast Delivery
                  </p>
                </div>
              </div>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CartScreen;
