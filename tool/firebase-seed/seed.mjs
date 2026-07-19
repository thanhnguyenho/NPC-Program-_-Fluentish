import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { FieldValue, GeoPoint, getFirestore } from 'firebase-admin/firestore';
import geohash from 'ngeohash';

const args = new Set(process.argv.slice(2));
const projectIndex = process.argv.indexOf('--project');
const projectId = projectIndex >= 0 ? process.argv[projectIndex + 1] : null;
const apply = args.has('--apply');

if (!projectId) {
  throw new Error('Pass --project <firebase-project-id>.');
}

const point = (latitude, longitude) => ({
  geopoint: new GeoPoint(latitude, longitude),
  geohash: geohash.encode(latitude, longitude, 9),
});

const places = {
  'ben-thanh-market': {
    name: 'Chợ Bến Thành',
    address: 'Công trường Quách Thị Trang, Quận 1, Hồ Chí Minh City',
    category: 'food',
    geo: point(10.7725301, 106.6980365),
    osmType: 'way',
    osmId: '39514795',
    guideCount: 1,
    primaryGuideId: 'street-food-basics',
    imageUrl: null,
    isPublished: true,
  },
  'nguyen-hue-walking-street': {
    name: 'Đường đi bộ Nguyễn Huệ',
    address: 'Nguyễn Huệ, Quận 1, Hồ Chí Minh City',
    category: 'cafe',
    geo: point(10.7737196, 106.7040457),
    osmType: 'relation',
    osmId: '4851995',
    guideCount: 1,
    primaryGuideId: 'cafe-conversation',
    imageUrl: null,
    isPublished: true,
  },
  'independence-palace': {
    name: 'Dinh Độc Lập',
    address: '135 Nam Kỳ Khởi Nghĩa, Quận 1, Hồ Chí Minh City',
    category: 'route',
    geo: point(10.7770348, 106.695488),
    osmType: 'way',
    osmId: '39598493',
    guideCount: 1,
    primaryGuideId: 'district-1-walk',
    imageUrl: null,
    isPublished: true,
  },
};

const guides = {
  'street-food-basics': {
    type: 'place',
    placeId: 'ben-thanh-market',
    title: 'Street Food Basics',
    category: 'food',
    summary: 'Order, ask prices, and thank local food vendors with confidence.',
    content:
      'Use polite greetings before ordering, point clearly when needed, confirm the price, and finish with a friendly cảm ơn. This guide focuses on short phrases that are useful around the market.',
    authorId: 'fluentish-team',
    ratingAverage: 4.0,
    reviewCount: 0,
    stopCount: 0,
    isPublished: true,
    isMapVisible: true,
  },
  'cafe-conversation': {
    type: 'place',
    placeId: 'nguyen-hue-walking-street',
    title: 'Cafe Conversation',
    category: 'cafe',
    summary: 'Easy phrases for ordering coffee and starting a conversation.',
    content:
      'Practise greeting staff, ordering a drink, asking whether a seat is free, and using simple conversation prompts while exploring cafés around Nguyễn Huệ.',
    authorId: 'fluentish-team',
    ratingAverage: 4.7,
    reviewCount: 0,
    stopCount: 0,
    isPublished: true,
    isMapVisible: true,
  },
  'district-1-walk': {
    type: 'route',
    placeId: 'independence-palace',
    title: 'District 1 Walk',
    category: 'route',
    summary: 'A five-stop walk with local landmarks and useful phrases.',
    content:
      'Follow the authored stops through central District 1. Each stop includes a short direction or meeting phrase to practise along the way.',
    authorId: 'fluentish-team',
    ratingAverage: null,
    reviewCount: 0,
    stopCount: 5,
    isPublished: true,
    isMapVisible: true,
  },
  'offline-guide-pack': {
    type: 'collection',
    placeId: '',
    title: 'Offline Guide Pack',
    category: 'saved',
    summary: 'Phrase sets and routes prepared for offline study.',
    content:
      'Save individual guides before leaving Wi-Fi. This collection does not represent a physical map location.',
    authorId: 'fluentish-team',
    ratingAverage: null,
    reviewCount: 0,
    stopCount: 0,
    isPublished: true,
    isMapVisible: false,
  },
};

const stops = [
  {
    id: '01-independence-palace',
    order: 1,
    name: 'Dinh Độc Lập',
    address: '135 Nam Kỳ Khởi Nghĩa, Quận 1',
    geo: point(10.7770348, 106.695488),
    osmType: 'way',
    osmId: '39598493',
    instruction: 'Start here and practise asking where the next landmark is.',
  },
  {
    id: '02-central-post-office',
    order: 2,
    name: 'Bưu điện Trung tâm Sài Gòn',
    address: '2 Công trường Công xã Paris, Quận 1',
    geo: point(10.7799557, 106.6999921),
    osmType: 'way',
    osmId: '39514793',
    instruction: 'Ask for directions using bên trái and bên phải.',
  },
  {
    id: '03-book-street',
    order: 3,
    name: 'Đường sách Nguyễn Văn Bình',
    address: 'Nguyễn Văn Bình, Quận 1',
    geo: point(10.7805735, 106.6996948),
    osmType: 'node',
    osmId: '11708010270',
    instruction: 'Practise asking whether a book is available in English.',
  },
  {
    id: '04-opera-house',
    order: 4,
    name: 'Nhà hát Thành phố',
    address: '7 Công trường Lam Sơn, Quận 1',
    geo: point(10.7767437, 106.7032488),
    osmType: 'way',
    osmId: '801710792',
    instruction: 'Use a meeting phrase to confirm where to wait.',
  },
  {
    id: '05-nguyen-hue',
    order: 5,
    name: 'Đường đi bộ Nguyễn Huệ',
    address: 'Nguyễn Huệ, Quận 1',
    geo: point(10.7737196, 106.7040457),
    osmType: 'relation',
    osmId: '4851995',
    instruction: 'Finish the route and practise inviting someone for coffee.',
  },
];

const plannedWrites = [
  ...Object.keys(places).map((id) => `places/${id}`),
  ...Object.keys(guides).map((id) => `guides/${id}`),
  ...stops.map((stop) => `guides/district-1-walk/stops/${stop.id}`),
];

console.log(`${apply ? 'Applying' : 'Dry run:'} ${plannedWrites.length} writes`);
for (const path of plannedWrites) console.log(`- ${path}`);

if (!apply) {
  console.log('No data written. Re-run with --apply and authorized credentials.');
  process.exit(0);
}

initializeApp({ credential: applicationDefault(), projectId });
const db = getFirestore();
const batch = db.batch();

for (const [id, data] of Object.entries(places)) {
  batch.set(db.collection('places').doc(id), {
    ...data,
    updatedAt: FieldValue.serverTimestamp(),
  }, { merge: true });
}
for (const [id, data] of Object.entries(guides)) {
  batch.set(db.collection('guides').doc(id), {
    ...data,
    updatedAt: FieldValue.serverTimestamp(),
  }, { merge: true });
}
for (const stop of stops) {
  const { id, ...data } = stop;
  batch.set(
    db.collection('guides').doc('district-1-walk').collection('stops').doc(id),
    data,
    { merge: true },
  );
}

await batch.commit();
console.log(`Seed completed for ${projectId}.`);
