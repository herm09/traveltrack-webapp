const { Router } = require('express');
const supabase = require('../lib/supabase');
const requireAdmin = require('../middleware/requireAdmin');

const router = Router();

// GET /api/quests
// Supports optional viewport/category filtering for the interactive map:
//   ?minLat=&maxLat=&minLng=&maxLng=  -> only quests inside the map bounding box
//   ?category=histoire                -> only quests of that category
router.get('/', async (req, res) => {
  const { minLat, maxLat, minLng, maxLng, category } = req.query;

  let query = supabase.from('quests').select('*');

  if (minLat) query = query.gte('lat', Number(minLat));
  if (maxLat) query = query.lte('lat', Number(maxLat));
  if (minLng) query = query.gte('lng', Number(minLng));
  if (maxLng) query = query.lte('lng', Number(maxLng));
  if (category) query = query.eq('category', category);

  const { data, error } = await query;
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

router.post('/', requireAdmin, async (req, res) => {
  const { data, error } = await supabase.from('quests').insert(req.body).select().single();
  if (error) return res.status(400).json({ error: error.message });
  res.status(201).json(data);
});

router.get('/:id', async (req, res) => {
  const { data, error } = await supabase.from('quests').select('*').eq('id', req.params.id).single();
  if (error) return res.status(404).json({ error: error.message });
  res.json(data);
});

router.patch('/:id', requireAdmin, async (req, res) => {
  const { data, error } = await supabase.from('quests').update(req.body).eq('id', req.params.id).select().single();
  if (error) return res.status(400).json({ error: error.message });
  res.json(data);
});

router.delete('/:id', requireAdmin, async (req, res) => {
  const { error } = await supabase.from('quests').delete().eq('id', req.params.id);
  if (error) return res.status(400).json({ error: error.message });
  res.status(204).send();
});

module.exports = router;
