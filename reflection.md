# Reflection — Inventory Management App with Firestore

**Name:** Adrit Ganeriwala  
**GitHub Repo:** https://github.com/adrit-ganeriwala-05/inclass-12

---

## 1) Objective + Expectation

### Integrate Flutter + Firestore
I expected that connecting Flutter to Firestore using FlutterFire CLI would
allow the app to read and write cloud data reliably. I expected
Firebase.initializeApp() to handle the connection before the app rendered
any UI, and that Firestore's collection reference would immediately accept
add, update, and delete calls without additional configuration.

### Implement CRUD
I expected that wrapping Firestore calls in a dedicated FirestoreService
class would make add, update, and delete operations straightforward to call
from the UI layer without any business logic leaking into the screens.

### Use Real-Time Streams
I expected StreamBuilder combined with Firestore's snapshots() stream to
automatically rebuild the item list every time the database changed, without
any manual refresh logic or polling.

### Apply Validation and UX States
I expected Flutter's built-in Form and FormState system with TextFormField
validators to block invalid submissions and show inline error messages for
empty, non-numeric, and negative field values.

### Engineer with Code Quality
I expected separating the app into models, services, and screens to produce
a clean architecture where each file had a single responsibility and changes
in one layer would not require changes in others.

---

## 2) What You Obtained

### Integrate Flutter + Firestore
The app connected to Firestore successfully. Items were written to and read
from the cloud database in real time. The FlutterFire CLI generated
firebase_options.dart automatically and Firebase.initializeApp() ran cleanly
before any Firestore calls were made.

### Implement CRUD
All four CRUD operations worked correctly. Adding an item wrote a new
document to the items collection. Editing an item called update() on the
correct document ID. Deleting an item removed it from both Firestore and the
UI instantly. Reading was handled entirely through the stream.

### Use Real-Time Streams
The StreamBuilder rebuilt the list automatically on every Firestore change.
However, the initial implementation showed a loading spinner on every update,
not just the first load. This was a partial failure that required a targeted
fix.

### Apply Validation and UX States
Validation successfully blocked empty fields, non-numeric quantity inputs,
decimal quantities, and negative values. Inline error messages appeared
below each field when validation failed. The form would not submit until
all validators passed.

### Engineer with Code Quality
The final architecture cleanly separated concerns across item.dart for the
data model, firestore_service.dart for all database logic, home_screen.dart
for the list UI, and item_form_screen.dart for the form UI. No Firestore
calls existed outside the service layer.

---

## 3) Evidence

### Firebase Integration
Commit: "add flutterfire configuration and firebase_options"  
The generated lib/firebase_options.dart file and the
Firebase.initializeApp() call in main.dart confirm successful connection.

### CRUD Operations
Commit: "add FirestoreService with add, stream, update, delete"  
The FirestoreService class contains four methods each mapped to a single
Firestore operation. Items added through the form appeared in the Firestore
console under the items collection immediately.

### StreamBuilder Loading Bug Fix
Commit: "fix auto-navigation back to home after adding or editing item"  
The fix changed the StreamBuilder condition from:
if (snapshot.connectionState == ConnectionState.waiting)
to:
if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData)
This stopped the spinner from re-appearing on every Firestore update.

### Navigation Fix
Commit: "fix navigation by popping before firestore write"  
Moving Navigator.pop(context) to before the await service call eliminated
the stuck loading screen after form submission.

### Validation
Form validators on all four fields block submission when fields are empty,
when quantity contains a decimal or letter, or when price contains a
non-numeric value. The form only submits when all four validators return null.

---

## 4) Analysis

### Why the StreamBuilder Spinner Persisted
The original condition checked only ConnectionState.waiting, which Firestore
briefly re-enters each time a new snapshot is emitted. Adding the
!snapshot.hasData guard meant the spinner only showed when there was truly
no data yet, not during live updates.

### Why Navigation Was Stuck
The form called await service.addItem() and then Navigator.pop(). Because
Firestore writes go through a network round trip, the await held the screen
open until the server confirmed the write. The fix was to pop immediately
and let Firestore's offline persistence queue the write in the background.
Since Firestore caches writes locally before syncing to the server, popping
before the await completes is safe and the data still reaches the cloud.

### Why Service Layer Separation Mattered
When the navigation bug occurred, the problem was isolated entirely to the
form screen's _submit() method. Because no Firestore logic existed in the
UI layer, fixing the bug required changing only one method without touching
the service, model, or home screen. This confirmed that the architecture
choice reduced debugging scope significantly.

### Validation Design Choice
Using Flutter's native FormState system instead of manual if/else checks
kept validation logic attached directly to each field. This meant each
field owned its own error state and the submit button only needed to call
_formKey.currentState!.validate() once to trigger all validators together.

---

## 5) Improvement Plan

### Add Category Filtering with Dropdown Tabs
Currently the search bar filters by typing, but a tab bar or dropdown above
the list that filters by category would improve usability for large
inventories. This would be implemented by extracting unique category values
from the streamed item list and rendering them as filter chips. This
improvement would increase usability because users managing many categories
could switch between them with one tap instead of typing each time.

---

## Critical Thinking Prompts

**Which objective was easiest to achieve, and why?**  
Form validation was the easiest objective. Flutter's built-in Form widget
and TextFormField validators handled all the edge cases with minimal code.
Each validator was a simple function returning either null for valid or a
string for invalid, and the FormState managed triggering all of them
together on submit.

**Which objective was hardest, and what misconception did you correct?**  
Real-time streams were the hardest. The misconception was that
ConnectionState.waiting only fires once at startup. In reality Firestore
re-enters the waiting state briefly on every snapshot emission, which caused
the spinner to flash on every update. The correction was to guard the
spinner with both the connection state and the absence of existing data.

**Where did expected behavior not match obtained behavior, and how did you debug it?**  
The form was expected to navigate back automatically after submission but
instead stayed on the screen with a loading spinner until the back button
was pressed manually. Debugging involved tracing the _submit() method step
by step and identifying that the await was blocking Navigator.pop() from
running until the network round trip completed. The fix was to reverse the
order — pop first, then write.

**How did your commit history show growth from basic functionality to polished architecture?**  
The commit history moves from scaffold setup, to adding the data model, to
wiring the service layer, to building the UI, to fixing bugs, and finally to
polishing the design. Each commit built on the previous one and represented
a single working addition rather than a large dump of unrelated changes.

**If this app scaled to many users and items, what design change would you make first?**  
The first change would be adding Firestore query pagination using
startAfterDocument() and limit() so the stream does not load every item in
the collection at once. Without pagination, a collection with thousands of
items would stream all of them to every user on every update, which would
cause slow load times and high Firestore read costs.