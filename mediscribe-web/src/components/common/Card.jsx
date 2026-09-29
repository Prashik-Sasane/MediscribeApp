import React from 'react';
import clsx from 'clsx';

const Card = ({ children, className = '', hover = true, ...props }) => {
  return (
    <div
      className={clsx(
        'bg-white dark:bg-surface-dark rounded-2xl shadow-card',
        hover && 'hover:shadow-card-hover transition-all duration-300',
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
};

export default Card;
