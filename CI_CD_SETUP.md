# Flutter CI/CD Setup Guide for pickle_pick

The basic CI/CD pipeline is now configured in `.github/workflows/ci.yml`. It handles:
- **Linting & Formatting**: Checks on every pull request.
- **Testing**: Runs unit and widget tests.
- **Building**: Automatically builds Android (APK/AAB), iOS (no-signing), and Web for push to `main` or `master`.

To make this pipeline fully production-ready, follow these steps:

## 1. Setup GitHub Secrets
Go to your GitHub Repository -> **Settings** -> **Secrets and variables** -> **Actions** and add the following:

### Android Signing (Required for Play Store deployment)
- `ANDROID_KEYSTORE_BASE64`: Your `.jks` file encoded in base64.
- `ANDROID_KEY_PASSWORD`: The password for your key.
- `ANDROID_KEY_ALIAS`: The alias of your key.
- `ANDROID_KEYSTORE_PASSWORD`: The password for your keystore.

### Supabase / API Keys (If needed by build-time)
If your app requires API keys during build (e.g., as dart-defines), add them:
- `SUPABASE_URL`: Your Supabase Project URL.
- `SUPABASE_ANON_KEY`: Your Supabase Anonymous Key.

## 2. Refining the Build Command
In the `ci.yml`, you might want to pass your secrets as `--dart-define` like this:
```yaml
run: flutter build apk --release --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
```

## 3. Automatic Deployment
If you want to automatically deploy to the app stores, you can add new jobs to `ci.yml` using tools like:
- **Fastlane**: For both iOS and Android.
- **Firebase App Distribution**: Great for beta testing.
- **GitHub Pages**: For hosting the Web build.

To deploy the **Web** version to GitHub Pages, add this step to `build-web`:
```yaml
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```
