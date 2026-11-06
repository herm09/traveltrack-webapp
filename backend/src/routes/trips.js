const { Router } = require('express');
const supabase = require('../lib/supabase');

const router = Router();

//READING - only trips connected users
router.get('/', async (req, res) => {
  const {data, error} = await supabase.from('trips').select('*').eq('user_id', req.user.id);
  if(error) return res.status(500).json({error: error.message});
  res.json(data);
});
//READING of a specific trip - verify if trip is part of the user
router.get('/:id', async (req, res) =>{
  const {data, error} = await supabase.from('trips').select('*').eq('id', req.params.id).eq('user_id', req.user.id).single();
  if(error) return res.status(404).json({error: error.message});
  res.json(data);
});
//CREATION - we ignore user_id sent by the client, and force hes
router.post('/', async(req, res) => {
  const {user_id, ...rest} = req.body; // we throw user_id if sent

  const {data, error} = await supabase.from('trips').insert([{...rest, user_id: req.user.id}]).select().single();
  if(error) return res.status(500).json({error: error.message});
  res.status(201).json(data);
});
//MODIFICATION - filter by user_id
router.patch('/:id', async(req, res) => {
  const {user_id, ...rest} = req.body;

  const {data, error} = await supabase.from('trips').update(rest).eq('id', req.params.id).eq('user_id', req.user.id).select().single(); //update only if its the right trip
  if(error) return res.status(404).json({error: 'Trip not found'});
  res.json(data);
});
//DELETE - filter by user_id
router.delete('/:id', async(req, res) => {
  const {error, count} = await supabase.from('trips').delete({count: 'exact'}).eq('id', req.params.id).eq('user_id', req.user.id);
  if(error) return res.status(500).json({error: error.message});
  if(count === 0) return res.status(404).json({error: 'Trip not found'});
  res.status(204).send();
});

module.exports = router;
