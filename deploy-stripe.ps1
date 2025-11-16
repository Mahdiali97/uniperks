# Stripe Payment Setup - Quick Deploy Script

Write-Host "🚀 Deploying Stripe Payment Backend..." -ForegroundColor Cyan
Write-Host ""

# Check if Supabase CLI is installed
$supabaseCli = Get-Command supabase -ErrorAction SilentlyContinue
if (-not $supabaseCli) {
    Write-Host "❌ Supabase CLI not found!" -ForegroundColor Red
    Write-Host "Install it from: https://supabase.com/docs/guides/cli" -ForegroundColor Yellow
    exit 1
}

# Set the Stripe Secret Key
Write-Host "📝 Setting Stripe Secret Key..." -ForegroundColor Yellow
supabase secrets set STRIPE_SECRET_KEY=sk_test_51SSIAy0BquWskqyagRwITn7LMAD7CTEPNAbYHbj0Ca1pwaw1JReocgfbDsSgJ72uaAxrGev1S8FiMRvaD7S0nJk300VppS3nYd

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Secret key set successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Failed to set secret. Make sure you're logged in: supabase login" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Deploy the function
Write-Host "🚀 Deploying create-payment-intent function..." -ForegroundColor Yellow
supabase functions deploy create-payment-intent

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Deployment successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎉 Your payment backend is ready at:" -ForegroundColor Cyan
    Write-Host "   https://oaxljityjzjylvvmfrta.supabase.co/functions/v1/create-payment-intent" -ForegroundColor White
    Write-Host ""
    Write-Host "📱 Test your app now with:" -ForegroundColor Cyan
    Write-Host "   flutter run" -ForegroundColor White
    Write-Host ""
    Write-Host "💳 Use Stripe test card:" -ForegroundColor Cyan
    Write-Host "   Card: 4242 4242 4242 4242" -ForegroundColor White
    Write-Host "   Expiry: Any future date" -ForegroundColor White
    Write-Host "   CVC: Any 3 digits" -ForegroundColor White
} else {
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    exit 1
}
