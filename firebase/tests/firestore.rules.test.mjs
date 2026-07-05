/**
 * Security-rules tests for Firestore (Step 1.2, §5.5). Verifies the two
 * acceptance criteria: cross-user access is denied, and drafts are invisible to
 * non-staff. Run against the emulator:
 *
 *   cd firebase/tests && npm install
 *   npm run test:emulator      # starts a firestore emulator just for the tests
 *
 * or, with an emulator already running:  npm test
 */
import {readFileSync} from "node:fs";
import {fileURLToPath} from "node:url";
import {dirname, join} from "node:path";
import {before, after, beforeEach, test} from "node:test";
import assert from "node:assert/strict";

import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from "@firebase/rules-unit-testing";
import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
} from "firebase/firestore";

const here = dirname(fileURLToPath(import.meta.url));
const rules = readFileSync(join(here, "..", "firestore.rules"), "utf8");

let testEnv;

/** Seeds a doc bypassing rules (admin context). */
async function seed(path, data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), path), data);
  });
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "dbfarmacia-rules-test",
    firestore: {rules},
  });
});

after(async () => {
  if (testEnv) await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  // A staff (pharmacist) profile and a customer profile used across tests.
  await seed("users/staff1", {role: "pharmacist", email: "s@b.it"});
  await seed("users/cust1", {role: "customer", email: "c@b.it"});
  await seed("users/cust2", {role: "customer", email: "c2@b.it"});
});

const anon = () => testEnv.unauthenticatedContext().firestore();
const as = (uid) => testEnv.authenticatedContext(uid).firestore();

test("published products are publicly readable", async () => {
  await seed("products/pub", {status: "published", name: {it: "X", en: "X"}});
  await assertSucceeds(getDoc(doc(anon(), "products/pub")));
});

test("draft products are hidden from anonymous and customers", async () => {
  await seed("products/draft", {status: "draft", name: {it: "D", en: "D"}});
  await assertFails(getDoc(doc(anon(), "products/draft")));
  await assertFails(getDoc(doc(as("cust1"), "products/draft")));
});

test("staff can read a draft and write products; customers cannot write", async () => {
  await seed("products/draft", {status: "draft", name: {it: "D", en: "D"}});
  await assertSucceeds(getDoc(doc(as("staff1"), "products/draft")));
  await assertSucceeds(
    setDoc(doc(as("staff1"), "products/new"), {status: "draft"}),
  );
  await assertFails(
    setDoc(doc(as("cust1"), "products/hack"), {status: "published"}),
  );
});

test("a user can read only their own profile", async () => {
  await assertSucceeds(getDoc(doc(as("cust1"), "users/cust1")));
  await assertFails(getDoc(doc(as("cust1"), "users/cust2")));
});

test("role cannot be escalated by the client", async () => {
  await assertFails(
    updateDoc(doc(as("cust1"), "users/cust1"), {role: "admin"}),
  );
  // A non-role update on the own doc is allowed.
  await assertSucceeds(
    updateDoc(doc(as("cust1"), "users/cust1"), {displayName: "Mario"}),
  );
});

test("self-registration can only create a customer profile", async () => {
  const fresh = testEnv.authenticatedContext("newuser").firestore();
  await assertSucceeds(
    setDoc(doc(fresh, "users/newuser"), {role: "customer", email: "n@b.it"}),
  );
  const other = testEnv.authenticatedContext("evil").firestore();
  await assertFails(
    setDoc(doc(other, "users/evil"), {role: "admin", email: "e@b.it"}),
  );
});

test("carts are private to their owner", async () => {
  await assertSucceeds(
    setDoc(doc(as("cust1"), "carts/cust1"), {userRef: "users/cust1", items: []}),
  );
  await assertFails(getDoc(doc(as("cust2"), "carts/cust1")));
});

test("orders: own readable, cross-user denied, client cannot create", async () => {
  await seed("orders/o1", {userRef: "users/cust1", total: 100});
  await assertSucceeds(getDoc(doc(as("cust1"), "orders/o1")));
  await assertFails(getDoc(doc(as("cust2"), "orders/o1")));
  await assertFails(
    setDoc(doc(as("cust1"), "orders/o2"), {userRef: "users/cust1"}),
  );
});

test("appointments: owner creates a request; not for other users", async () => {
  await assertSucceeds(
    setDoc(doc(as("cust1"), "appointments/a1"), {
      userRef: "users/cust1",
      serviceRef: "services/ecg",
      status: "requested",
    }),
  );
  await assertFails(
    setDoc(doc(as("cust1"), "appointments/a2"), {
      userRef: "users/cust2",
      status: "requested",
    }),
  );
});

test("catalog metadata is public read but not customer-writable", async () => {
  await seed("categories/c1", {name: {it: "Cat", en: "Cat"}});
  await seed("services/s1", {name: {it: "Svc", en: "Svc"}});
  await seed("locations/l1", {name: "Baganza"});
  await seed("config/global", {shippingCost: 490});

  await assertSucceeds(getDoc(doc(anon(), "categories/c1")));
  await assertSucceeds(getDoc(doc(anon(), "services/s1")));
  await assertSucceeds(getDoc(doc(anon(), "locations/l1")));
  await assertSucceeds(getDoc(doc(anon(), "config/global")));

  await assertFails(setDoc(doc(as("cust1"), "categories/hack"), {x: 1}));
  await assertSucceeds(setDoc(doc(as("staff1"), "categories/ok"), {x: 1}));
});

test("unmodeled collections are denied by default", async () => {
  await assertFails(getDoc(doc(as("cust1"), "secrets/x")));
  await assertFails(setDoc(doc(as("staff1"), "secrets/x"), {a: 1}));
  await assertFails(deleteDoc(doc(as("staff1"), "users/cust1")));
});
