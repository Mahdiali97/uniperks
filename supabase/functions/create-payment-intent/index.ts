// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { amount, currency, metadata } = await req.json()
    
    // Get Stripe secret key from environment
    const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY')
    if (!stripeSecretKey) {
      console.error('Missing STRIPE_SECRET_KEY environment variable')
      throw new Error('Missing STRIPE_SECRET_KEY environment variable')
    }

    console.log('Creating payment intent for amount:', amount, 'currency:', currency)

    // Create PaymentIntent via Stripe API
    const response = await fetch('https://api.stripe.com/v1/payment_intents', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${stripeSecretKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        amount: String(amount),
        currency: currency || 'myr',
        'automatic_payment_methods[enabled]': 'true',
        // Add metadata if provided
        ...(metadata ? Object.fromEntries(
          Object.entries(metadata).map(([k, v]) => [`metadata[${k}]`, String(v)])
        ) : {}),
      }),
    })

    if (!response.ok) {
      const errorText = await response.text()
      console.error('Stripe API error:', errorText)
      return new Response(
        JSON.stringify({ error: 'Failed to create payment intent', details: errorText }), 
        { 
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const paymentIntent = await response.json()
    console.log('Payment intent created:', paymentIntent.id)

    return new Response(
      JSON.stringify({ 
        client_secret: paymentIntent.client_secret,
        id: paymentIntent.id 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )
  } catch (error) {
    console.error('Error in create-payment-intent:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      },
    )
  }
})
