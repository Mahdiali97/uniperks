# Deploy Stripe Payment Backend

This function creates PaymentIntents securely using your Stripe Secret Key.

## Prerequisites

1. Install Supabase CLI: https://supabase.com/docs/guides/cli
2. Login to Supabase CLI:
   ```powershell
   supabase login
   ```

## Deployment Steps

### 1. Link your project (if not already linked)

```powershell
cd "c:\Users\User\Documents\Github Doc\uniperks"
supabase link --project-ref oaxljityjzjylvvmfrta
```

### 2. Set your Stripe Secret Key as an environment variable

```powershell
supabase secrets set STRIPE_SECRET_KEY=sk_test_51SSIAy0BquWskqyagRwITn7LMAD7CTEPNAbYHbj0Ca1pwaw1JReocgfbDsSgJ72uaAxrGev1S8FiMRvaD7S0nJk300VppS3nYd
```

### 3. Deploy the function

```powershell
supabase functions deploy create-payment-intent
```

### 4. Verify deployment

After deployment, your function will be available at:
```
https://oaxljityjzjylvvmfrta.supabase.co/functions/v1/create-payment-intent
```

## Testing the function

You can test it with curl:

```powershell
curl -X POST https://oaxljityjzjylvvmfrta.supabase.co/functions/v1/create-payment-intent `
  -H "Content-Type: application/json" `
  -d '{"amount": 5000, "currency": "myr", "metadata": {"username": "test"}}'
```

Expected response:
```json
{
  "client_secret": "pi_xxx_secret_xxx",
  "id": "pi_xxx"
}
```

## App Configuration

Your app is already configured with:
- **Publishable Key**: `pk_test_51SSIAy0BquWskqyaMRovb95LcmqT50KSS5eqA0f6QuPyMnf01D2NTz5ZCnMXo5EX1mr7dmL5YaXeBil9hhv2Gt2A004aAgjaT5`
- **Backend URL**: `https://oaxljityjzjylvvmfrta.supabase.co/functions/v1`

## Next Steps

After deploying the function, you can:

1. Run the app:
   ```powershell
   flutter run
   ```

2. Test payment with Stripe test cards:
   - Visa: `4242 4242 4242 4242`
   - Any future expiry date
   - Any 3-digit CVC
   - Any ZIP code

3. Monitor payments in your Stripe Dashboard: https://dashboard.stripe.com/test/payments
