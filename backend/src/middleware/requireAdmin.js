// Must run after requireAuth (needs req.user to already be set).
//
// There's no admin table/UI yet, so "admin" is just a flag on the Supabase
// auth user itself: set `role: "admin"` in that user's App Metadata from the
// Supabase dashboard (Authentication > Users > select user > App Metadata),
// or via the Admin API:
//   supabase.auth.admin.updateUserById(userId, { app_metadata: { role: 'admin' } })
// App Metadata (not User Metadata) is used on purpose — it can only be set
// with the service-role key, so a regular user can never grant themselves
// admin access from the client.
function requireAdmin(req, res, next) {
  const role = req.user?.app_metadata?.role;

  if (role !== 'admin') {
    return res.status(403).json({ error: 'Accès réservé aux administrateurs' });
  }

  next();
}

module.exports = requireAdmin;
