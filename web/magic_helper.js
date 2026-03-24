// Magic Web SDK Helper
let magicInstance = null;
let magicSDKLoadAttempted = false;
let magicSDKFailed = false;
let magicLoadPromise = null;

// CDN fallback chain - tries multiple CDNs in order
const magicCDNs = [
    'https://cdn.jsdelivr.net/npm/magic-sdk/dist/magic.js',          // Primary
    'https://cdn.jsdelivr.net/npm/magic-sdk@latest/dist/magic.js',   // Fallback 1
    'https://unpkg.com/magic-sdk@latest/dist/magic.js'               // Fallback 2
];

// Load Magic SDK dynamically with CDN fallback (async)
function loadMagicSDKAsync() {
    // Return the same promise if already loading
    if (magicLoadPromise) {
        return magicLoadPromise;
    }

    magicLoadPromise = new Promise((resolve, reject) => {
        // If already loaded, resolve immediately
        if (typeof window.Magic !== 'undefined') {
            // console.log('✅ Magic SDK already loaded');
            magicSDKFailed = false;
            resolve();
            return;
        }

        if (magicSDKLoadAttempted && magicSDKFailed) {
            // console.warn('⚠️ Magic SDK previously failed to load');
            reject(new Error('Magic SDK unavailable'));
            return;
        }

        magicSDKLoadAttempted = true;
        // console.log('📡 Loading Magic SDK from CDN chain...');

        let cdnIndex = 0;

        function tryLoadCDN() {
            if (cdnIndex >= magicCDNs.length) {
                // console.error('❌ All Magic SDK CDNs failed');
                magicSDKFailed = true;
                reject(new Error('Magic SDK unavailable from all CDN sources'));
                return;
            }

            const currentCDN = magicCDNs[cdnIndex];
            // console.log(`🔄 Attempting CDN ${cdnIndex + 1}/${magicCDNs.length}: ${currentCDN}`);

            const script = document.createElement('script');
            script.src = currentCDN;
            script.async = true;
            script.crossOrigin = 'anonymous';

            // 10-second timeout per CDN attempt
            const cdnTimeout = setTimeout(() => {
                // console.warn(`⏱️ CDN ${cdnIndex + 1} timeout - trying next...`);
                if (document.head.contains(script)) {
                    document.head.removeChild(script);
                }
                cdnIndex++;
                tryLoadCDN();
            }, 10000);

            script.onerror = (error) => {
                clearTimeout(cdnTimeout);
                // console.warn(`❌ CDN ${cdnIndex + 1} failed - trying next...`);
                if (document.head.contains(script)) {
                    document.head.removeChild(script);
                }
                cdnIndex++;
                tryLoadCDN();
            };

            script.onload = () => {
                clearTimeout(cdnTimeout);
                if (typeof window.Magic !== 'undefined') {
                    // console.log(`✅ Magic SDK loaded successfully from CDN ${cdnIndex + 1}: ${currentCDN}`);
                    magicSDKFailed = false;
                    resolve();
                } else {
                    // console.warn(`❌ CDN ${cdnIndex + 1} loaded but window.Magic undefined - trying next...`);
                    if (document.head.contains(script)) {
                        document.head.removeChild(script);
                    }
                    cdnIndex++;
                    tryLoadCDN();
                }
            };

            document.head.appendChild(script);
        }

        tryLoadCDN();
    });

    return magicLoadPromise;
}

// Auto-load Magic SDK on page load
function autoLoadMagicSDK() {
    // Keep Magic SDK lazy-loaded to avoid page bootstrap errors.
}

// Ensure Magic SDK is loaded before use from Dart interop.
function ensureMagicSDKReady(successCallback, errorCallback) {
    loadMagicSDKAsync()
        .then(() => {
            successCallback(true);
        })
        .catch((error) => {
            const message = error?.message || 'Magic SDK unavailable';
            errorCallback(message);
        });
}

// Do not auto-load on page ready; web login triggers ensureMagicSDKReady() on demand.

// Initialize Magic SDK (synchronous interface for Dart)
function initMagic(apiKey) {
    // console.log('🔧 Initializing Magic SDK with API key:', apiKey?.substring(0, 10) + '...');

    // If Magic is already loaded (pre-loaded on page load), create instance immediately
    if (typeof window.Magic === 'function') {
        try {
            magicInstance = new window.Magic(apiKey);
            // console.log('✅ Magic instance created successfully (pre-loaded)');
            return true;
        } catch (error) {
            // console.error('❌ Error creating Magic instance:', error.message);
            return false;
        }
    }

    // If Magic SDK failed to load previously, return false
    if (magicSDKFailed) {
        // console.error('❌ Magic SDK unavailable - use Google Sign-In instead');
        return false;
    }

    // If Magic is still loading, wait a bit and check again
    if (magicSDKLoadAttempted && magicLoadPromise) {
        // console.log('⏳ Magic SDK still loading, will retry...');

        // Wait for pre-load to complete
        magicLoadPromise
            .then(() => {
                if (typeof window.Magic === 'function') {
                    try {
                        magicInstance = new window.Magic(apiKey);
                        // console.log('✅ Magic instance created after pre-load completed');
                    } catch (error) {
                        // console.error('❌ Error creating Magic instance:', error.message);
                    }
                }
            })
            .catch(error => {
                // console.error('❌ Failed to load Magic SDK during pre-load:', error.message);
            });

        return false; // Not ready yet, but will load
    }

    // If not attempted yet, this shouldn't happen (auto-load should have started)
    // console.warn('⚠️ Magic SDK pre-load was not automatically triggered');
    return false;
}

// Send Magic email OTP (with callbacks)
function sendMagicEmailOTP(email, successCallback, errorCallback) {
    // console.log('📧 Attempting to send email OTP to: ' + email);

    // Check if initialization was attempted and failed
    if (magicSDKFailed) {
        const errorMsg = '❌ Email login is temporarily unavailable. Please use Google Sign-In instead.';
        // console.error(errorMsg);
        errorCallback(errorMsg);
        return;
    }

    // If not initialized yet, try to initialize
    if (!magicInstance) {
        // console.log('⏳ Magic SDK not yet initialized - skipping email OTP');
        errorCallback('Magic SDK not initialized. Please use Google Sign-In instead.');
        return;
    }

    // console.log('📧 Sending OTP via Magic to: ' + email);

    // Use Magic's built-in UI for OTP entry
    magicInstance.auth.loginWithEmailOTP({
        email: email,
        showUI: true // Show Magic's default OTP UI
    })
        .then(didToken => {
            // console.log('✅ Magic authentication successful! DID Token:', didToken);
            successCallback(didToken);
        })
        .catch(error => {
            const errorMessage = error?.message || 'Email login unavailable. Please use Google Sign-In instead.';
            // console.error('❌ Email OTP send failed:', errorMessage);
            errorCallback(errorMessage);
        });
}

// Verify OTP code entered by user
function verifyMagicOTP(email, otpCode, successCallback, errorCallback) {
    if (!magicInstance) {
        errorCallback('Magic SDK not initialized');
        return;
    }

    // console.log('🔐 Verifying Magic OTP code:', otpCode, 'for email:', email);

    // Verify the OTP code
    magicInstance.auth.loginWithEmailOTP({
        email: email,
        otp: otpCode,
        showUI: false
    })
        .then(didToken => {
            // console.log('✅ OTP verified successfully! DID Token:', didToken);
            successCallback(didToken);
        })
        .catch(error => {
            // console.error('❌ OTP verification failed:', error.message);
            errorCallback(error.message || error.toString());
        });
}

// Get user metadata with callback
function getMagicUserMetadata(successCallback, errorCallback) {
    if (!magicInstance) {
        errorCallback('Magic SDK not initialized');
        return;
    }

    magicInstance.user.getMetadata()
        .then(metadata => {
            // console.log('✅ Got Magic user metadata:', metadata);
            successCallback(JSON.stringify(metadata));
        })
        .catch(error => {
            // console.error('❌ Error getting Magic user metadata:', error);
            errorCallback(error.message || error.toString());
        });
}

// Check if user is logged in
async function isMagicLoggedIn() {
    try {
        if (!magicInstance) {
            return false;
        }

        return await magicInstance.user.isLoggedIn();
    } catch (error) {
        // console.error('❌ Error checking Magic login status:', error);
        return false;
    }
}

// Logout with callback
function magicLogout(successCallback, errorCallback) {
    if (!magicInstance) {
        errorCallback('Magic SDK not initialized');
        return;
    }

    magicInstance.user.logout()
        .then(() => {
            // console.log('✅ Magic logout successful');
            successCallback(true);
        })
        .catch(error => {
            // console.error('❌ Magic logout error:', error);
            errorCallback(error.message || error.toString());
        });
}
