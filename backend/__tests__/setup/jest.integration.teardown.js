/**
 * Jest Global Teardown - Integration Tests
 * Runs ONCE after ALL integration test files complete
 * Closes database connections to prevent hanging
 */

const { teardownTestDatabase } = require("../helpers/test-db");
const testLogger = require("../../config/test-logger");

module.exports = async () => {
  testLogger.log("🧹 Global teardown: Closing test database connections...");

  try {
    await teardownTestDatabase();
    testLogger.log("✅ Test database connections closed");
    testLogger.log("✅ TrossApp integration test suite completed");
  } catch (error) {
    testLogger.error("❌ Global teardown failed:", error.message);
    // Don't throw - allow Jest to exit gracefully
  }
};
