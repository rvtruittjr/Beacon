import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@14.0.0'

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
    const { user_id, plan, interval } = await req.json()
    // interval: 'month' | 'year'

    if (!user_id || !plan || !interval) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: user_id, plan, interval' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
      apiVersion: '2023-10-16',
    })

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const appUrl = Deno.env.get('APP_URL') || 'https://beakon.app'

    // 1. Look up existing subscription record
    const { data: existingSub } = await supabase
      .from('subscriptions')
      .select('stripe_customer_id')
      .eq('user_id', user_id)
      .maybeSingle()

    let customerId = existingSub?.stripe_customer_id

    // 2. Look up or create Stripe customer
    if (!customerId) {
      // Get user email from auth
      const { data: userData } = await supabase.auth.admin.getUserById(user_id)
      const email = userData?.user?.email

      const customer = await stripe.customers.create({
        email: email || undefined,
        metadata: { user_id },
      })
      customerId = customer.id

      // Upsert subscription record with customer ID
      await supabase.from('subscriptions').upsert({
        user_id,
        stripe_customer_id: customerId,
        plan: 'free',
        status: 'active',
      }, { onConflict: 'user_id' })
    }

    // 3. Get the correct price ID based on interval
    const priceId = interval === 'year'
      ? Deno.env.get('STRIPE_PRO_ANNUAL_PRICE_ID')!
      : Deno.env.get('STRIPE_PRO_MONTHLY_PRICE_ID')!

    // 4. Create Stripe Checkout Session
    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      mode: 'subscription',
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      success_url: `${appUrl}/app/settings/subscription?success=true`,
      cancel_url: `${appUrl}/app/settings/subscription`,
      metadata: { user_id },
      subscription_data: {
        metadata: { user_id },
      },
    })

    // 5. Return session URL
    return new Response(
      JSON.stringify({ session_url: session.url }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
