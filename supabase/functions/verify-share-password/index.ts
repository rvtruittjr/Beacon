import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import * as bcrypt from 'https://deno.land/x/bcrypt@v0.4.1/mod.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { share_token, password } = await req.json()

    if (!share_token) {
      return new Response(
        JSON.stringify({ error: 'Missing share_token' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // 1. Fetch brand by share_token
    const { data: brand, error: brandError } = await supabase
      .from('brands')
      .select('id, is_public, share_password_hash, share_expires_at')
      .eq('share_token', share_token)
      .maybeSingle()

    if (brandError || !brand) {
      return new Response(
        JSON.stringify({ error: 'Brand not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. Check if is_public is true
    if (!brand.is_public) {
      return new Response(
        JSON.stringify({ error: 'This brand kit is private' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 3. Check if share_expires_at is in the past
    if (brand.share_expires_at && new Date(brand.share_expires_at) < new Date()) {
      return new Response(
        JSON.stringify({ error: 'This link has expired' }),
        { status: 410, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 4. If no share_password_hash: return 200 (no password needed)
    if (!brand.share_password_hash) {
      return new Response(
        JSON.stringify({ granted: true, brand_id: brand.id }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get client IP for logging and rate limiting
    const ip = req.headers.get('x-forwarded-for')?.split(',')[0]?.trim()
      || req.headers.get('x-real-ip')
      || 'unknown'

    // 9. Rate limit: check for >5 failed attempts in last 15 minutes from same IP
    const fifteenMinutesAgo = new Date(Date.now() - 15 * 60 * 1000).toISOString()
    const { count: failedAttempts } = await supabase
      .from('brand_share_access')
      .select('*', { count: 'exact', head: true })
      .eq('brand_id', brand.id)
      .eq('ip_address', ip)
      .eq('status', 'denied')
      .gte('accessed_at', fifteenMinutesAgo)

    if (failedAttempts !== null && failedAttempts >= 5) {
      return new Response(
        JSON.stringify({ error: 'Too many attempts. Please try again later.' }),
        { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 5. Compare password against share_password_hash using bcrypt
    if (!password) {
      return new Response(
        JSON.stringify({ granted: false, message: 'Password required' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const isValid = await bcrypt.compare(password, brand.share_password_hash)

    // 6. Log attempt in brand_share_access
    await supabase.from('brand_share_access').insert({
      brand_id: brand.id,
      ip_address: ip,
      status: isValid ? 'granted' : 'denied',
      accessed_at: new Date().toISOString(),
    })

    // 7. On success: return { granted: true, brand_id: brand.id }
    if (isValid) {
      return new Response(
        JSON.stringify({ granted: true, brand_id: brand.id }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 8. On failure: return 401
    return new Response(
      JSON.stringify({ granted: false, message: 'Incorrect password' }),
      { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
