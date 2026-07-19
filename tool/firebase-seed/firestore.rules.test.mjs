import { readFile } from 'node:fs/promises';
import { after, before, beforeEach, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  doc,
  getDoc,
  setDoc,
  writeBatch,
} from 'firebase/firestore';

const projectId = 'demo-fluentish';
let testEnvironment;

before(async () => {
  testEnvironment = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: await readFile(new URL('../../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

beforeEach(async () => {
  await testEnvironment.clearFirestore();
});

after(async () => {
  await testEnvironment.cleanup();
});

test('private users are owner-only and public profiles require auth', async () => {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const privateData = { uid: 'alice', email: 'alice@example.com' };
    const publicData = {
      uid: 'alice',
      displayName: 'Alice',
      username: 'alice',
      usernameLower: 'alice',
    };
    await setDoc(doc(context.firestore(), 'users/alice'), privateData);
    await setDoc(doc(context.firestore(), 'publicProfiles/alice'), publicData);
  });

  const alice = testEnvironment.authenticatedContext('alice').firestore();
  const bob = testEnvironment.authenticatedContext('bob').firestore();
  const guest = testEnvironment.unauthenticatedContext().firestore();

  await assertSucceeds(getDoc(doc(alice, 'users/alice')));
  await assertFails(getDoc(doc(bob, 'users/alice')));
  await assertSucceeds(getDoc(doc(bob, 'publicProfiles/alice')));
  await assertFails(getDoc(doc(guest, 'publicProfiles/alice')));
});

test('accepted friends can read active shared locations only', async () => {
  const future = Timestamp.fromMillis(Date.now() + 10 * 60 * 1000);
  const past = Timestamp.fromMillis(Date.now() - 60 * 1000);
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const firestore = context.firestore();
    await setDoc(doc(firestore, 'friendships/alice_bob'), {
      userIds: ['alice', 'bob'],
      requestId: 'alice_bob',
    });
    await setDoc(doc(firestore, 'locationSharing/bob'), {
      enabled: true,
      audience: 'friends',
    });
    await setDoc(doc(firestore, 'locations/bob'), {
      ownerId: 'bob',
      geo: { geopoint: null, geohash: 'w3gv' },
      expiresAt: future,
    });
    await setDoc(doc(firestore, 'locations/expired-bob'), {
      ownerId: 'expired-bob',
      geo: { geopoint: null, geohash: 'w3gv' },
      expiresAt: past,
    });
  });

  const alice = testEnvironment.authenticatedContext('alice').firestore();
  const stranger = testEnvironment.authenticatedContext('charlie').firestore();

  await assertSucceeds(getDoc(doc(alice, 'locations/bob')));
  await assertSucceeds(getDoc(doc(alice, 'locationSharing/bob')));
  await assertFails(getDoc(doc(stranger, 'locations/bob')));
  await assertFails(getDoc(doc(stranger, 'locationSharing/bob')));
  await assertFails(getDoc(doc(alice, 'locations/expired-bob')));
});

test('users can publish only their own future location', async () => {
  const future = Timestamp.fromMillis(Date.now() + 10 * 60 * 1000);
  const alice = testEnvironment.authenticatedContext('alice').firestore();
  const bob = testEnvironment.authenticatedContext('bob').firestore();
  const location = {
    ownerId: 'alice',
    geo: { geopoint: null, geohash: 'w3gv' },
    accuracyM: 5,
    updatedAt: Timestamp.now(),
    expiresAt: future,
  };

  await assertSucceeds(setDoc(doc(alice, 'locations/alice'), location));
  await assertFails(setDoc(doc(bob, 'locations/alice'), location));
  await assertFails(setDoc(doc(alice, 'locations/alice'), {
    ...location,
    expiresAt: Timestamp.fromMillis(Date.now() + 11 * 60 * 1000),
  }));
});

test('receiver acceptance can atomically create a friendship', async () => {
  const sender = testEnvironment.authenticatedContext('alice').firestore();
  const receiver = testEnvironment.authenticatedContext('bob').firestore();
  const requestReference = doc(sender, 'friendRequests/alice_bob');
  await assertSucceeds(setDoc(requestReference, {
    senderId: 'alice',
    receiverId: 'bob',
    status: 'pending',
    createdAt: Timestamp.now(),
    respondedAt: null,
  }));

  const batch = writeBatch(receiver);
  batch.update(doc(receiver, 'friendRequests/alice_bob'), {
    status: 'accepted',
    respondedAt: Timestamp.now(),
  });
  batch.set(doc(receiver, 'friendships/alice_bob'), {
    userIds: ['alice', 'bob'],
    requestId: 'alice_bob',
    createdAt: Timestamp.now(),
  });
  await assertSucceeds(batch.commit());

  const maliciousBatch = writeBatch(receiver);
  maliciousBatch.set(doc(receiver, 'friendships/bob_charlie'), {
    userIds: ['bob', 'charlie'],
    requestId: 'alice_bob',
    createdAt: Timestamp.now(),
  });
  await assertFails(maliciousBatch.commit());
});

test('published guides are authenticated read-only content', async () => {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'guides/guide-1'), {
      title: 'Guide',
      isPublished: true,
    });
  });
  const alice = testEnvironment.authenticatedContext('alice').firestore();
  const guest = testEnvironment.unauthenticatedContext().firestore();

  await assertSucceeds(getDoc(doc(alice, 'guides/guide-1')));
  await assertFails(getDoc(doc(guest, 'guides/guide-1')));
  await assertFails(setDoc(doc(alice, 'guides/guide-2'), {
    title: 'Unauthorized',
    isPublished: true,
  }));
});
