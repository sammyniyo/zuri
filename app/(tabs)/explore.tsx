import React, { useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, FlatList, Pressable, StyleSheet, Text, View } from 'react-native';

import { Colors } from '@/constants/theme';
import { useColorScheme } from '@/hooks/use-color-scheme';
import type { Place } from '@/src/features/places/types';
import { getFeaturedPlaces } from '@/src/features/places/firestore';

const mockPlaces: Place[] = [
  {
    id: 'mock_1',
    name: 'Heaven Restaurant',
    category: 'Restaurant',
    rating: 4.7,
    priceRange: '$$',
    latitude: -1.9441,
    longitude: 30.0619,
    images: [],
    description: '',
    address: 'Kigali, Rwanda',
    currentCrowdLevel: 'unknown',
    crowdReportsCount: 0,
  },
  {
    id: 'mock_2',
    name: 'Kigali Café',
    category: 'Cafe',
    rating: 4.5,
    priceRange: '$',
    latitude: -1.9506,
    longitude: 30.0588,
    images: [],
    description: '',
    address: 'Kigali, Rwanda',
    currentCrowdLevel: 'unknown',
    crowdReportsCount: 0,
  },
];

function PlaceCard({ place, onPress }: { place: Place; onPress: () => void }) {
  return (
    <Pressable onPress={onPress} style={styles.card}>
      <Text style={styles.cardTitle} numberOfLines={1}>
        {place.name}
      </Text>
      <Text style={styles.cardMeta} numberOfLines={1}>
        {place.category} • {place.rating.toFixed(1)}
      </Text>
    </Pressable>
  );
}

export default function ExploreScreen() {
  const colorScheme = useColorScheme() ?? 'light';
  const c = Colors[colorScheme];
  const [loading, setLoading] = useState(true);
  const [places, setPlaces] = useState<Place[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        setLoading(true);
        const p = await getFeaturedPlaces();
        if (!cancelled) setPlaces(p);
      } catch (e) {
        if (!cancelled) {
          setError(String(e));
          // Allow the app to run even before Firebase is configured.
          setPlaces(mockPlaces);
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const header = useMemo(() => {
    return (
      <View style={[styles.header, { backgroundColor: c.background }]}>
        <Text style={[styles.headerTitle, { color: c.text }]}>Discover Kigali</Text>
        <Text style={[styles.headerSubtitle, { color: c.icon }]}>Unique picks for you</Text>
      </View>
    );
  }, [c.background, c.icon, c.text]);

  if (loading) {
    return (
      <View style={[styles.center, { backgroundColor: c.background }]}>
        <ActivityIndicator />
      </View>
    );
  }

  return (
    <View style={[styles.container, { backgroundColor: c.background }]}>
      {header}
      {error ? (
        <Text style={{ color: 'tomato', paddingHorizontal: 16 }}>{error}</Text>
      ) : null}
      <FlatList
        data={places}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ padding: 16, gap: 12 }}
        renderItem={({ item }) => <PlaceCard place={item} onPress={() => {}} />}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 12, paddingHorizontal: 16, paddingBottom: 8 },
  headerTitle: { fontSize: 28, fontWeight: '800' },
  headerSubtitle: { marginTop: 6, fontSize: 13, fontWeight: '600' },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  card: {
    borderRadius: 18,
    padding: 14,
    backgroundColor: '#FFFFFF',
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: '#E5E7EB',
  },
  cardTitle: { fontSize: 16, fontWeight: '700' },
  cardMeta: { marginTop: 6, fontSize: 12, fontWeight: '600', color: '#6B7280' },
});
