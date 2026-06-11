import { initializeApp } from 'firebase/app';
import { getFirestore, collection, addDoc, serverTimestamp } from 'firebase/firestore';

const app = initializeApp({
  apiKey: 'AIzaSyAIa0maBQvJiJiFhroOEdBmlpXcSmjPZgs',
  authDomain: 'gcmpvoice.firebaseapp.com',
  projectId: 'gcmpvoice',
  storageBucket: 'gcmpvoice.firebasestorage.app',
  messagingSenderId: '1006466693807',
  appId: '1:1006466693807:web:d3d682e2e5479fa87bf25a',
});

export async function submitPilotApplication(fields) {
  const db = getFirestore(app);
  const ref = await addDoc(collection(db, 'pilot_applications'), {
    ...fields,
    timestamp: serverTimestamp(),
  });
  return ref.id;
}
