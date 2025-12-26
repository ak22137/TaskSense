/**
 * Not Found Middleware
 * Handles 404 errors for undefined routes
 */

const notFound = (req, res, next) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`,
  });
};

module.exports = notFound;
