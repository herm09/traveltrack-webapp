const { Router } = require('express');
const supabase = require('../lib/supabase');

const router = Router();

const EARTH_RADIUS_METERS = 6371000;

// Great-circle distance between two lat/lng points, in meters.
function haversineDistance(lat1, lng1, lat2, lng2) {
  const toRad = (deg) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return EARTH_RADIUS_METERS * c;
}

// GET /api/quests
// Supports optional viewport/category filtering for the interactive map:
//   ?minLat=&maxLat=&minLng=&maxLng=  -> only quests inside the map bounding box
//   ?category=histoire                -> only quests of that category
// Supports proximity search around the user's position:
//   ?lat=&lng=              -> annotate each quest with `distance` (meters) from
//                               that point and sort nearest-first
//   ?lat=&lng=&radius=      -> same, but only quests within `radius` meters
router.get('/', async (req, res) => {
  const { minLat, maxLat, minLng, maxLng, category, lat, lng, radius } = req.query;

  let query = supabase.from('quests').select('*');

  if (minLat) query = query.gte('lat', Number(minLat));
  if (maxLat) query = query.lte('lat', Number(maxLat));
  if (minLng) query = query.gte('lng', Number(minLng));
  if (maxLng) query = query.lte('lng', Number(maxLng));
  if (category) query = query.eq('category', category);

  const { data, error } = await query;
  if (error) return res.status(500).json({ error: error.message });

  if (!lat || !lng) return res.json(data);

  const originLat = Number(lat);
  const originLng = Number(lng);
  const radiusMeters = radius ? Number(radius) : null;

  const quests = data
    .map((quest) => ({
      ...quest,
      distance: Math.round(haversineDistance(originLat, originLng, quest.lat, quest.lng)),
    }))
    .filter((quest) => radiusMeters === null || quest.distance <= radiusMeters)
    .sort((a, b) => a.distance - b.distance);

  res.json(quests);
});

router.post('/', async (req, res) => {
  const { data, error } = await supabase.from('quests').insert(req.body).select().single();
  if (error) return res.status(400).json({ error: error.message });
  res.status(201).json(data);
});

router.get('/:id', async (req, res) => {
  const { data, error } = await supabase.from('quests').select('*').eq('id', req.params.id).single();
  if (error) return res.status(404).json({ error: error.message });
  res.json(data);
});

router.patch('/:id', async (req, res) => {
  const { data, error } = await supabase.from('quests').update(req.body).eq('id', req.params.id).select().single();
  if (error) return res.status(400).json({ error: error.message });
  res.json(data);
});

router.delete('/:id', async (req, res) => {
  const { error } = await supabase.from('quests').delete().eq('id', req.params.id);
  if (error) return res.status(400).json({ error: error.message });
  res.status(204).send();
});

module.exports = router;
