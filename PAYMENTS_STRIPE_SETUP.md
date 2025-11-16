# Stripe Payments Setup (Flutter + PaymentSheet)

This guide wires your existing Payment UI flow to Stripe using `flutter_stripe` and a lightweight backend endpoint that creates PaymentIntents securely.

Important: Your Stripe Secret Key must never ship in the app; use a server (e.g., Supabase Edge Function) to create PaymentIntents and return a client secret.

## 1) Dependencies

Added to `pubspec.yaml`:
- `flutter_stripe`
- `http`

Install:

```powershell
flutter pub get
```

## 2) App initialization

We initialize Stripe with a Publishable Key from `lib/config/payment_config.dart` (prefer passing via `--dart-define`).

Update your run command to provide real values:

```powershell
flutter run `
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_XXXXXXXXXXXXXXXXXXXXXXXX `
  --dart-define=PAYMENTS_BACKEND_URL=https://<YOUR-SUPABASE-PROJECT>.functions.supabase.co
```

## 3) Backend: Create PaymentIntent

Create a Supabase Edge Function `create-payment-intent` (Node) that uses your Stripe Secret Key.

Example (TypeScript):

```ts
// supabase/functions/create-payment-intent/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method Not Allowed', { status: 405 });
  try {
    const { amount, currency, metadata } = await req.json();
    const apiKey = Deno.env.get('STRIPE_SECRET_KEY');
    if (!apiKey) throw new Error('Missing STRIPE_SECRET_KEY');

    const resp = await fetch('https://api.stripe.com/v1/payment_intents', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        amount: String(amount),
        currency,
        'automatic_payment_methods[enabled]': 'true',
        // optional metadata
        ...(metadata ? Object.fromEntries(Object.entries(metadata).map(([k,v]) => [`metadata[${k}]`, String(v)])) : {}),
      }),
    });

    if (!resp.ok) {
      const txt = await resp.text();
      return new Response(txt, { status: 500 });
    }

    const data = await resp.json();
    return new Response(JSON.stringify({ client_secret: data.client_secret }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(String(e), { status: 500 });
  }
});
```

Deploy and set environment variable:

```powershell
supabase functions deploy create-payment-intent
supabase secrets set STRIPE_SECRET_KEY=sk_test_XXXXXXXXXXXXXXXXXXXXXXXX
```

Your function will be available at:
- `https://<YOUR-SUPABASE-PROJECT>.functions.supabase.co/create-payment-intent`

Set `PAYMENTS_BACKEND_URL` accordingly.

## 4) App integration

- `lib/services/payment_service.dart` handles PaymentSheet flow:
  1. Calls your backend to create a PaymentIntent (amount in smallest unit).
  2. Initializes PaymentSheet with client secret.
  3. Presents PaymentSheet and resolves success/failure.
- `lib/pages/payment_page.dart` now calls `PaymentService.payWithPaymentSheet(...)` on the final step.

Your existing stepper UI remains; card input is handled by PaymentSheet for compliance and security.

## 5) Testing

Use Stripe test keys and test cards:
- Visa: 4242 4242 4242 4242
- Any future date, any CVC, any ZIP

## 6) Production

- Switch to live mode keys.
- Update `--dart-define` values in CI/build steps.
- Ensure Android minSdkVersion >= 21 and iOS deployment target >= 12.0.
- For Apple Pay/Google Pay support, configure merchant IDs and set `SetupPaymentSheetParameters` accordingly.

## 7) Troubleshooting

- "Missing client_secret": Confirm backend returns `client_secret`.
- Network errors: Verify `PAYMENTS_BACKEND_URL` points to your function origin (no trailing slash) and CORS is permitted.
- Currency amounts: Multiply by 100 for minor units (`MYR`: sen).
