# Vehicle Key Verifier

A separate UK-focused auto-locksmith research app for quickly checking a customer's vehicle before quoting or attending a job.

## MVP features

- Searchable make and model inputs.
- Linked UK registration-age and vehicle-year fields.
- Add-key and all-keys-lost job selection.
- Standard, proximity, slot and smart-key variants.
- Gemini Google Search grounding for current online research.
- Separate confidence status for each result field.
- Source links and research notes.
- Saved Data page with local offline reuse.
- Manual GitHub Actions APK build.

## Gemini API key

Create a key in Google AI Studio. In the app, open the key icon and paste the key. The key is stored only in Android local preferences for this personal MVP. A later production version should move Gemini calls to a secure backend.

## Build the APK

1. Open **Actions** in GitHub.
2. Select **Build Android APK**.
3. Press **Run workflow**.
4. Enter the version name and version code.
5. Download the APK from the completed workflow's **Artifacts** section.

The workflow is manual only and does not run after normal commits.
