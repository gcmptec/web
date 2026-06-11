# Security Notes — GCMP Website

## Firestore rules for `pilot_applications` (deploy from the app repo)

Rules are no longer deployed from this repo (see commit 7b677ea). The live rules for
project `gcmpvoice` must be at least this strict — the website writes leads client-side,
so an unconstrained `allow write: if true` lets anyone on the internet spam the
collection and inflate the Firestore bill.

Recommended rules block:

```
match /pilot_applications/{doc} {
  allow read: if false;
  allow update, delete: if false;
  allow create: if
    request.resource.data.keys().hasOnly(
      ['name', 'company', 'role', 'phone', 'email', 'timestamp']) &&
    request.resource.data.name is string &&
    request.resource.data.name.size() > 0 &&
    request.resource.data.name.size() <= 80 &&
    request.resource.data.company is string &&
    request.resource.data.company.size() > 0 &&
    request.resource.data.company.size() <= 120 &&
    request.resource.data.role is string &&
    request.resource.data.role.size() <= 40 &&
    request.resource.data.phone is string &&
    request.resource.data.phone.size() >= 7 &&
    request.resource.data.phone.size() <= 20 &&
    request.resource.data.email is string &&
    request.resource.data.email.size() <= 120 &&
    request.resource.data.timestamp == request.time;
}
```

`allow read: if false` is what keeps applicant PII (names, phones, emails) private —
never relax it for the web client. Field caps mirror the client-side `maxLength`
limits in `site/src/form-validate.js`.

## Other standing notes

- The Firebase web config in `site/src/firebase.js` is public by design
  (API key is an identifier, not a secret). Rules are the security boundary.
- `GcmpVoice` (ML training notebook) was untracked from the deploy branch so it is
  no longer served from the public site. The canonical copy lives on `main`
  (the Colab badge links to `blob/main/GcmpVoice`).
- Form abuse resistance: client-side validation + length caps exist, but the real
  enforcement is the Firestore rules above. If spam appears in
  `pilot_applications`, add App Check (reCAPTCHA v3) to the `gcmpvoice` project.
