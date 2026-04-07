export type CrowdLevel = 'quiet' | 'moderate' | 'busy' | 'packed' | 'unknown';

export type CrowdReport = {
  id: string;
  userId: string;
  placeId: string;
  crowdLevel: CrowdLevel;
  waitMinutes?: number | null;
  timestamp: Date;
  comment?: string | null;
};

export type Place = {
  id: string;
  name: string;
  category: string;
  rating: number;
  priceRange: string;
  latitude: number;
  longitude: number;
  images: string[];
  description: string;
  address: string;

  // Crowd Intelligence
  currentCrowdLevel: CrowdLevel;
  crowdReportsCount: number;
};

