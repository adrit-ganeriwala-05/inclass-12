# Reflection

## What went well
Setting up Firestore streams with StreamBuilder worked smoothly once
the service layer was separated from the UI. Real-time updates appeared
instantly without any manual refresh logic.

## What was challenging
Getting the form to navigate back automatically after submission took
several attempts. The fix was to call Navigator.pop before the Firestore
write instead of after, so the UI never waits on the network.

## What I learned
- How to use StreamBuilder to listen to live Firestore data
- How to structure a Flutter app with a dedicated service layer
- The importance of separating UI logic from data logic
- How Firebase initializes asynchronously before the app runs