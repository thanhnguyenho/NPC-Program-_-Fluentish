import { readFile } from 'node:fs/promises';
import { after, before, beforeEach, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';

const projectId = 'demo-fluentish';
const bucketUrl = `gs://${projectId}.appspot.com`;
let testEnvironment;

before(async () => {
  testEnvironment = await initializeTestEnvironment({
    projectId,
    storage: {
      rules: await readFile(new URL('../../storage.rules', import.meta.url), 'utf8'),
    },
  });
});

beforeEach(async () => {
  await testEnvironment.clearStorage();
});

after(async () => {
  await testEnvironment.cleanup();
});

test('avatar uploads are owner-only and limited to supported images', async () => {
  const alice = testEnvironment
    .authenticatedContext('alice')
    .storage(bucketUrl);
  const bob = testEnvironment.authenticatedContext('bob').storage(bucketUrl);
  const avatarPath = 'avatars/alice/profile';
  const image = new Uint8Array([255, 216, 255]);

  await assertSucceeds(
    alice.ref(avatarPath).put(image, { contentType: 'image/jpeg' }),
  );
  await assertFails(
    bob.ref(avatarPath).put(image, { contentType: 'image/jpeg' }),
  );
  await assertFails(
    alice.ref('avatars/alice/text').put(image, { contentType: 'text/plain' }),
  );
  await assertFails(
    alice
      .ref('avatars/alice/too-large')
      .put(new Uint8Array(1024 * 1024 + 1), { contentType: 'image/png' }),
  );
});

test('authenticated users can read avatars and only owners can delete them', async () => {
  const alice = testEnvironment
    .authenticatedContext('alice')
    .storage(bucketUrl);
  const bob = testEnvironment.authenticatedContext('bob').storage(bucketUrl);
  const guest = testEnvironment.unauthenticatedContext().storage(bucketUrl);
  const avatar = alice.ref('avatars/alice/profile');

  await assertSucceeds(
    avatar.put(new Uint8Array([137, 80, 78, 71]), {
      contentType: 'image/png',
    }),
  );
  await assertSucceeds(bob.ref(avatar.fullPath).getMetadata());
  await assertFails(guest.ref(avatar.fullPath).getMetadata());
  await assertFails(bob.ref(avatar.fullPath).delete());
  await assertSucceeds(avatar.delete());
});
