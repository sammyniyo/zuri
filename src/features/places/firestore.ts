import { collection, doc, getDoc, getDocs, limit, orderBy, query, where } from 'firebase/firestore';
import { getFirestoreDb } from '@/src/lib/firebase';
import type { Place } from './types';

function asNumber(v: unknown, fallback = 0) {
  return typeof v === 'number' ? v : fallback;
}

function asString(v: unknown, fallback = '') {
  return typeof v === 'string' ? v : fallback;
}

function asStringArray(v: unknown) {
  return Array.isArray(v) ? v.filter((x): x is string => typeof x === 'string') : [];
}

export async function getPlace(placeId: string): Promise<Place | null> {
  const firestore = getFirestoreDb();
  if (!firestore) throw new Error('Firebase is not configured (missing EXPO_PUBLIC_FIREBASE_* env vars).');
  const snap = await getDoc(doc(firestore, 'places', placeId));
  if (!snap.exists()) return null;
  const d = snap.data();
  return {
    id: snap.id,
    name: asString(d.name),
    category: asString(d.category),
    rating: asNumber(d.rating),
    priceRange: asString(d.priceRange),
    latitude: asNumber(d.latitude),
    longitude: asNumber(d.longitude),
    images: asStringArray(d.images),
    description: asString(d.description),
    address: asString(d.address),
    currentCrowdLevel: 'unknown',
    crowdReportsCount: asNumber(d.crowdReportsCount, 0),
  };
}

export async function getFeaturedPlaces(): Promise<Place[]> {
  const firestore = getFirestoreDb();
  if (!firestore) throw new Error('Firebase is not configured (missing EXPO_PUBLIC_FIREBASE_* env vars).');
  const q = query(
    collection(firestore, 'places'),
    where('isFeatured', '==', true),
    orderBy('rating', 'desc'),
    limit(10)
  );
  const snaps = await getDocs(q);
  return snaps.docs.map((snap) => {
    const d = snap.data();
    return {
      id: snap.id,
      name: asString(d.name),
      category: asString(d.category),
      rating: asNumber(d.rating),
      priceRange: asString(d.priceRange),
      latitude: asNumber(d.latitude),
      longitude: asNumber(d.longitude),
      images: asStringArray(d.images),
      description: asString(d.description),
      address: asString(d.address),
      currentCrowdLevel: 'unknown',
      crowdReportsCount: asNumber(d.crowdReportsCount, 0),
    };
  });
}

