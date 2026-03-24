importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    appId: "1:53658349575:web:fdf844b2c7ea2932fabaa2",
    apiKey: "AIzaSyCqz4Hs2-o72Odb5d_x7qbQ17BEwrL0eM0",
    authDomain: "fanbae-99a9e.firebaseapp.com",
    databaseURL: "https://fanbae-99a9e-default-rtdb.firebaseio.com",
    projectId: "fanbae-99a9e",
    storageBucket: "fanbae-99a9e.firebasestorage.app",
    messagingSenderId: "53658349575",
});
// Necessary to receive background messages:
var messaging = firebase.messaging();

// // Optional:
// messaging.onBackgroundMessage((m) => {
//     console.log("onBackgroundMessage", m);
// });
messaging.onBackgroundMessage(messaging, (payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    // Customize notification here
    var notificationTitle = 'Background Message Title';
    var notificationOptions = {
        body: 'Background Message body.',
        icon: '/firebase-logo.png'
    };

    self.registration.showNotification(notificationTitle,
        notificationOptions);
});
