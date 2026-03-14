const express = require("express");
const router = express.Router();
const { authenticateToken } = require("../middleware/authMiddleware");
const notificationController = require("../controllers/notificationController");

// All routes require authentication
router.use(authenticateToken);

// GET /api/notifications - Get all notifications (paginated)
router.get("/", notificationController.getNotifications);

// GET /api/notifications/unread-count - Get unread count
router.get("/unread-count", notificationController.getUnreadCount);

// PUT /api/notifications/read-all - Mark all as read
router.put("/read-all", notificationController.markAllAsRead);

// PUT /api/notifications/:id/read - Mark one as read
router.put("/:id/read", notificationController.markAsRead);

// DELETE /api/notifications/clear-all - Delete all notifications
router.delete("/clear-all", notificationController.clearAllNotifications);

// DELETE /api/notifications/:id - Delete a notification
router.delete("/:id", notificationController.deleteNotification);

module.exports = router;
