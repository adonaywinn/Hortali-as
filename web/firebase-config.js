// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";
import { getAnalytics } from "firebase/analytics";

// ✅ CONFIGURAÇÃO DO FIREBASE - HORTAPP HORTALICAS ✅
const firebaseConfig = {
  apiKey: "AIzaSyAnjc49Epok2bEAwSFncP4VQOGLXzZtaWs",
  authDomain: "hortapp-hortalicas.firebaseapp.com",
  projectId: "hortapp-hortalicas",
  storageBucket: "hortapp-hortalicas.firebasestorage.app",
  messagingSenderId: "41798305065",
  appId: "1:41798305065:web:04a03c80c0ab3c79502338",
  measurementId: "G-QP05Q6C4MK"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase Authentication and get a reference to the service
export const auth = getAuth(app);

// Initialize Cloud Firestore and get a reference to the service
export const db = getFirestore(app);

// Initialize Firebase Storage and get a reference to the service
export const storage = getStorage(app);

// Initialize Firebase Analytics and get a reference to the service
export const analytics = getAnalytics(app);

export default app;
