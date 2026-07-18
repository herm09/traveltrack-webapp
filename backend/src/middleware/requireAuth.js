const {createClient} = require('@supabase/supabase-js');

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function requireAuth(req, res, next) {
    const authHeader = req.headers['authorization'];

    if(!authHeader || !authHeader.startsWith('Bearer')){
        return res.status(401).json({error: 'Token manquant ou mal formé'});
    }

    const token = authHeader.split(' ')[1];
    try{
        const{data, error} = await supabase.auth.getUser(token);

        if(error || !data?.user){
            return res.status(401).json({error: 'Token invalide ou expiré'});
        }

        //attach the user to the request to use in routes
        req.user = data.user;
        next();
    }
    catch (err){
        console.error('Token verification error', err);
        return res.status(401).json({error: 'Authentication error'});
    }
}

module.exports = requireAuth;