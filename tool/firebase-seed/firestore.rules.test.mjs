import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { after, before, beforeEach, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  runTransaction,
  setDoc,
  where,
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
  await assertSucceeds(setDoc(doc(alice, 'publicProfiles/alice'), {
    uid: 'alice',
    displayName: 'Alice Updated',
    username: 'alice',
    usernameLower: 'alice',
  }));
  await assertFails(setDoc(doc(alice, 'publicProfiles/alice'), {
    uid: 'bob',
    displayName: 'Invalid Profile',
    username: 'alice',
    usernameLower: 'alice',
  }));
});

test('favourites and history are private to their owner', async () => {
  const alice = testEnvironment.authenticatedContext('alice').firestore();
  const bob = testEnvironment.authenticatedContext('bob').firestore();
  const collections = [
    'favouritePhrases',
    'favouriteSoundboardBites',
    'history',
    'savedGuides',
  ];

  for (const collectionName of collections) {
    const reference = doc(alice, `users/alice/${collectionName}/entry-1`);
    await assertSucceeds(setDoc(reference, { value: 'private' }));
    await assertSucceeds(getDoc(reference));
    await assertFails(getDoc(
      doc(bob, `users/alice/${collectionName}/entry-1`),
    ));
  }
});

test('username registry prevents duplicate usernames and supports atomic rename', async () => {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const firestore = context.firestore();
    await setDoc(doc(firestore, 'publicProfiles/alice'), {
      uid: 'alice',
      displayName: 'Alice',
      username: 'Alice',
      usernameLower: 'alice',
    });
    await setDoc(doc(firestore, 'usernames/alice'), {
      uid: 'alice',
      username: 'Alice',
    });
  });

  const alice = testEnvironment.authenticatedContext('alice').firestore();
  const bob = testEnvironment.authenticatedContext('bob').firestore();

  const duplicateBatch = writeBatch(bob);
  duplicateBatch.set(doc(bob, 'publicProfiles/bob'), {
    uid: 'bob',
    displayName: 'Alice',
    username: 'Alice',
    usernameLower: 'alice',
  });
  duplicateBatch.set(doc(bob, 'usernames/alice'), {
    uid: 'bob',
    username: 'Alice',
  });
  await assertFails(duplicateBatch.commit());

  const renameBatch = writeBatch(alice);
  renameBatch.update(doc(alice, 'publicProfiles/alice'), {
    displayName: 'Alice New',
    username: 'Alice_New',
    usernameLower: 'alice_new',
  });
  renameBatch.set(doc(alice, 'usernames/alice_new'), {
    uid: 'alice',
    username: 'Alice_New',
  });
  renameBatch.delete(doc(alice, 'usernames/alice'));
  await assertSucceeds(renameBatch.commit());
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
  await assertFails(setDoc(doc(alice, 'locations/alice'), {
    ...location,
    isActive: true,
  }));
});

test('authenticated users can query imported map places without exposing friend locations', async () => {
  const future = Timestamp.fromMillis(Date.now() + 10 * 60 * 1000);
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const firestore = context.firestore();
    await setDoc(doc(firestore, 'locations/imported-place'), {
      placeId: 'imported-place',
      name: 'Imported place',
      location: { latitude: 10.77, longitude: 106.70 },
      isActive: true,
    });
    await setDoc(doc(firestore, 'locations/bob'), {
      ownerId: 'bob',
      geo: { geopoint: null, geohash: 'w3gv' },
      accuracyM: 5,
      updatedAt: Timestamp.now(),
      expiresAt: future,
    });
  });

  const alice = testEnvironment.authenticatedContext('alice').firestore();
  const activePlaces = query(
    collection(alice, 'locations'),
    where('isActive', '==', true),
  );

  const snapshot = await assertSucceeds(getDocs(activePlaces));
  assert.equal(snapshot.docs.length, 1);
  assert.equal(snapshot.docs[0].id, 'imported-place');
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

test('request participants can preflight deterministic request ids', async () => {
  const alice = testEnvironment.authenticatedContext('alice').firestore();
  const charlie = testEnvironment.authenticatedContext('charlie').firestore();

  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'friendRequests/alice_bob'), {
      senderId: 'alice',
      receiverId: 'bob',
      status: 'pending',
      createdAt: Timestamp.now(),
      respondedAt: null,
    });
  });

  await assertSucceeds(getDoc(doc(alice, 'friendRequests/alice_bob')));
  await assertSucceeds(getDoc(doc(alice, 'friendRequests/bob_alice')));
  await assertFails(getDoc(doc(charlie, 'friendRequests/alice_bob')));
});

test('sender can transactionally preflight and create a friend request', async () => {
  const alice = testEnvironment.authenticatedContext('alice').firestore();

  await assertSucceeds(runTransaction(alice, async (transaction) => {
    const directPath = 'friendRequests/alice_bob';
    const reversePath = 'friendRequests/bob_alice';
    const directReference = doc(alice, directPath);
    const reverseReference = doc(alice, reversePath);
    await transaction.get(directReference);
    await transaction.get(reverseReference);
    transaction.set(directReference, {
      senderId: 'alice',
      receiverId: 'bob',
      status: 'pending',
      createdAt: Timestamp.now(),
      respondedAt: null,
    });
  }));
});

test('sender can retry a request after it was declined', async () => {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'friendRequests/alice_bob'), {
      senderId: 'alice',
      receiverId: 'bob',
      status: 'declined',
      createdAt: Timestamp.now(),
      respondedAt: Timestamp.now(),
    });
  });

  const alice = testEnvironment.authenticatedContext('alice').firestore();
  await assertSucceeds(setDoc(doc(alice, 'friendRequests/alice_bob'), {
    senderId: 'alice',
    receiverId: 'bob',
    status: 'pending',
    createdAt: Timestamp.now(),
    respondedAt: null,
  }));
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
