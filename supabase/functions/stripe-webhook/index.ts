import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@14.0.0'

serve(async (req) => {
  try {
    const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
      apiVersion: '2023-10-16',
    })

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Verify webhook signature
    const signature = req.headers.get('stripe-signature')!
    const body = await req.text()

    let event: Stripe.Event
    try {
      event = stripe.webhooks.constructEvent(
        body,
        signature,
        Deno.env.get('STRIPE_WEBHOOK_SECRET')!
      )
    } catch (err) {
      console.error('Webhook signature verification failed:', err.message)
      return new Response(
        JSON.stringify({ error: 'Invalid signature' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Helper: find user_id from Stripe subscription metadata or customer lookup
    async function resolveUserId(subscription: Stripe.Subscription): Promise<string | null> {
      // Check subscription metadata first
      if (subscription.metadata?.user_id) {
        return subscription.metadata.user_id
      }

      // Fall back to customer ID lookup in subscriptions table
      const customerId = typeof subscription.customer === 'string'
        ? subscription.customer
        : subscription.customer.id

      const { data } = await supabase
        .from('subscriptions')
        .select('user_id')
        .eq('stripe_customer_id', customerId)
        .maybeSingle()

      return data?.user_id || null
    }

    switch (event.type) {
      // ── Subscription Created ──────────────────────────────────
      case 'customer.subscription.created': {
        const subscription = event.data.object as Stripe.Subscription
        const userId = await resolveUserId(subscription)
        if (!userId) break

        await supabase.from('subscriptions').upsert({
          user_id: userId,
          plan: 'pro',
          status: 'active',
          stripe_customer_id: typeof subscription.customer === 'string'
            ? subscription.customer
            : subscription.customer.id,
          stripe_subscription_id: subscription.id,
          current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
        }, { onConflict: 'user_id' })

        break
      }

      // ── Subscription Updated ──────────────────────────────────
      case 'customer.subscription.updated': {
        const subscription = event.data.object as Stripe.Subscription
        const userId = await resolveUserId(subscription)
        if (!userId) break

        const status = subscription.cancel_at_period_end ? 'canceling' : subscription.status

        await supabase.from('subscriptions').update({
          status,
          current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
        }).eq('user_id', userId)

        break
      }

      // ── Subscription Deleted ──────────────────────────────────
      case 'customer.subscription.deleted': {
        const subscription = event.data.object as Stripe.Subscription
        const userId = await resolveUserId(subscription)
        if (!userId) break

        await supabase.from('subscriptions').update({
          plan: 'free',
          status: 'canceled',
          stripe_subscription_id: null,
          current_period_end: null,
        }).eq('user_id', userId)

        break
      }

      // ── Payment Failed ────────────────────────────────────────
      case 'invoice.payment_failed': {
        const invoice = event.data.object as Stripe.Invoice
        const customerId = typeof invoice.customer === 'string'
          ? invoice.customer
          : invoice.customer?.id

        if (!customerId) break

        await supabase.from('subscriptions').update({
          status: 'past_due',
        }).eq('stripe_customer_id', customerId)

        break
      }

      default:
        console.log(`Unhandled event type: ${event.type}`)
    }

    return new Response(
      JSON.stringify({ received: true }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    console.error('Webhook error:', err.message)
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
