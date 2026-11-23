const assert = require("assert");
const {
  ORDER_STATUS_CONFIG,
  normalizeStatus,
  isTokenExpiredOrInvalid,
} = require("../orderNotifications");

console.log("Running orderNotifications tests...");

// Test 1: Normalization of "order placed"
const placedVariations = [
  "placed",
  "order_placed",
  "order placed",
  "created",
  "confirmed",
  "paid",
  "CONFIRMED",
  "Order Placed",
];
for (const v of placedVariations) {
  assert.strictEqual(
    normalizeStatus(v),
    "placed",
    `Expected "${v}" to normalize to "placed"`,
  );
}
console.log("✓ Placed status normalization passed");

// Test 2: Normalization of "packed"
const packedVariations = ["packed", "order_packed", "order packed", "PACKED"];
for (const v of packedVariations) {
  assert.strictEqual(
    normalizeStatus(v),
    "packed",
    `Expected "${v}" to normalize to "packed"`,
  );
}
console.log("✓ Packed status normalization passed");

// Test 3: Normalization of "picked"
const pickedVariations = [
  "picked",
  "picked_up",
  "picked up",
  "order_picked",
  "order picked",
  "dispatched",
  "PICKED",
];
for (const v of pickedVariations) {
  assert.strictEqual(
    normalizeStatus(v),
    "picked",
    `Expected "${v}" to normalize to "picked"`,
  );
}
console.log("✓ Picked status normalization passed");

// Test 4: Normalization of "out for delivery"
const outDeliveryVariations = [
  "out_for_delivery",
  "out for delivery",
  "out delivery",
  "out_delivery",
  "out-for-delivery",
  "OUT DELIVERY",
];
for (const v of outDeliveryVariations) {
  assert.strictEqual(
    normalizeStatus(v),
    "out_for_delivery",
    `Expected "${v}" to normalize to "out_for_delivery"`,
  );
}
console.log("✓ Out for delivery status normalization passed");

// Test 5: Normalization of "delivered"
const deliveredVariations = [
  "delivered",
  "order_delivered",
  "order delivered",
  "completed",
  "DELIVERED",
];
for (const v of deliveredVariations) {
  assert.strictEqual(
    normalizeStatus(v),
    "delivered",
    `Expected "${v}" to normalize to "delivered"`,
  );
}
console.log("✓ Delivered status normalization passed");

// Test 6: Invalid statuses
assert.strictEqual(normalizeStatus("invalid_random_state"), null);
assert.strictEqual(normalizeStatus(""), null);
assert.strictEqual(normalizeStatus(null), null);
assert.strictEqual(normalizeStatus(undefined), null);
console.log("✓ Invalid statuses correctly return null");

// Test 7: Verify Notification Titles and Bodies for all 5 lifecycle states
const orderNum = "ORD-9988";
for (const [key, cfg] of Object.entries(ORDER_STATUS_CONFIG)) {
  assert(cfg.title.length > 0, `Title missing for ${key}`);
  const body = cfg.getBody(orderNum);
  assert(
    body.includes(orderNum),
    `Body should contain order number for ${key}: ${body}`,
  );
  console.log(`✓ [${key.toUpperCase()}] Title: "${cfg.title}" | Body: "${body}"`);
}

// Test 8: Verify isTokenExpiredOrInvalid handles token expiry errors
assert.strictEqual(
  isTokenExpiredOrInvalid({ code: "messaging/invalid-registration-token" }),
  true,
);
assert.strictEqual(
  isTokenExpiredOrInvalid({ code: "messaging/registration-token-not-registered" }),
  true,
);
assert.strictEqual(
  isTokenExpiredOrInvalid({ code: "messaging/mismatched-credential" }),
  true,
);
assert.strictEqual(
  isTokenExpiredOrInvalid({ message: "Requested entity was not registered." }),
  true,
);
assert.strictEqual(
  isTokenExpiredOrInvalid({ message: "The registration token is not valid" }),
  true,
);
assert.strictEqual(
  isTokenExpiredOrInvalid({ code: "messaging/server-unavailable" }),
  false,
);
assert.strictEqual(
  isTokenExpiredOrInvalid({ code: "messaging/internal-error" }),
  false,
);
assert.strictEqual(isTokenExpiredOrInvalid(null), false);
assert.strictEqual(isTokenExpiredOrInvalid(undefined), false);
console.log("✓ isTokenExpiredOrInvalid correctly identifies expired/invalid tokens");

console.log("\nAll unit tests passed successfully!");
