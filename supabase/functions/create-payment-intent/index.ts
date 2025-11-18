import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

console.log('🟢 Edge Function: create-payment-intent started');

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    console.log('📥 Request received');
    
    const { amount, currency, metadata } = await req.json();
    console.log('📊 Payload:', { amount, currency, metadata });
    
    // Get Stripe secret key from environment
    const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY');
    console.log('🔑 Secret Key Check:', stripeSecretKey ? '✅ Present' : '❌ Missing');
    
    if (!stripeSecretKey) {
      console.error('❌ STRIPE_SECRET_KEY not found in environment!');
      return new Response(
        JSON.stringify({ 
          error: 'Missing STRIPE_SECRET_KEY',
          message: 'Please set STRIPE_SECRET_KEY in Supabase Edge Functions settings'
        }), 
        { 
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    console.log('🚀 Calling Stripe API...');

    // Create PaymentIntent via Stripe API
    const stripeUrl = 'https://api.stripe.com/v1/payment_intents';
    const stripeBody = new URLSearchParams({
      amount: String(amount),
      currency: currency || 'myr',
      'automatic_payment_methods[enabled]': 'true',
      ...(metadata ? Object.fromEntries(
        Object.entries(metadata).map(([k, v]) => [`metadata[${k}]`, String(v)])
      ) : {}),
    });

    console.log('📤 Stripe Request:', {
      url: stripeUrl,
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Authorization': 'Bearer [REDACTED]' },
    });

    const response = await fetch(stripeUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${stripeSecretKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: stripeBody,
    });

    console.log('📨 Stripe Response Status:', response.status);

    if (!response.ok) {
      const errorText = await response.text();
      console.error('❌ Stripe Error Response:', errorText);
      return new Response(
        JSON.stringify({
          error: 'Failed to create payment intent',
          stripe_status: response.status,
          details: errorText,
        }), 
        { 
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    const paymentIntent = await response.json();
    console.log('✅ Success! Payment Intent ID:', paymentIntent.id);

    return new Response(
      JSON.stringify({
        client_secret: paymentIntent.client_secret,
        id: paymentIntent.id
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    );
  } catch (error) {
    console.error('❌ Exception:', error);
    const errorMessage = error instanceof Error ? error.message : String(error);
    return new Response(
      JSON.stringify({
        error: 'Exception in function',
        details: errorMessage,
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      },
    );
  }
});


