'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"worker.dart": "e9f6baf9efb39986bc1430c5e218e161",
"sqlite3.wasm": "fa7637a49a0e434f2a98f9981856d118",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"flutter_bootstrap.js": "a23c3dfa77889006187eacd40cece034",
"version.json": "35c6f6bd1887837d27a09cf63cb58b6c",
"manifest.json": "b0d827cdee586cbabaa7f13c2bb48431",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/FontManifest.json": "f9097450010bd82cf16bb016ba2219d8",
"assets/AssetManifest.bin": "6db6b8b6f1c7ba2a9c74b82751d8a990",
"assets/AssetManifest.bin.json": "40030d6b1df407a05b0824339c0a3643",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "b93248a553f9e8bc17f1065929d5934b",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Italic.ttf": "ac3b1882325add4f148f05db8cafd401",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Math-BoldItalic.ttf": "946a26954ab7fbd7ea78df07795a6cbc",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Bold.ttf": "9eef86c1f9efa78ab93d41a0551948f7",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Caligraphic-Regular.ttf": "7ec92adfa4fe03eb8e9bfb60813df1fa",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size3-Regular.ttf": "e87212c26bb86c21eb028aba2ac53ec3",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size2-Regular.ttf": "959972785387fe35f7d47dbfb0385bc4",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Italic.ttf": "d89b80e7bdd57d238eeaa80ed9a1013a",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Regular.ttf": "5a5766c715ee765aa1398997643f1589",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Regular.ttf": "b5f967ed9e4933f1c3165a12fe3436df",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Script-Regular.ttf": "55d2dcd4778875a53ff09320a85a5296",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Bold.ttf": "ad0a28f28f736cf4c121bcb0e719b88a",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Fraktur-Regular.ttf": "dede6f2c7dad4402fa205644391b3a94",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Fraktur-Bold.ttf": "46b41c4de7a936d099575185a94855c4",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Math-Italic.ttf": "a7732ecb5840a15be39e1eda377bc21d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_AMS-Regular.ttf": "657a5353a553777e270827bd1630e467",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Caligraphic-Bold.ttf": "a9c8e437146ef63fcd6fae7cf65ca859",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Typewriter-Regular.ttf": "87f56927f1ba726ce0591955c8b3b42d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-BoldItalic.ttf": "e3c361ea8d1c215805439ce0941a1c8d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size4-Regular.ttf": "85554307b465da7eb785fd3ce52ad282",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size1-Regular.ttf": "1e6a3368d660edc3a2fbbe72edfeaa85",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/assets/units/scalar.d4rt.units": "02d5950d399cb3ca8802a3cdf1abdbf3",
"assets/assets/units/time.d4rt.units": "bd6ffc50825398cfe7360c81b0b58b67",
"assets/assets/units/volume.d4rt.units": "1911275d09f0736572cb67e252031ed2",
"assets/assets/units/angle.d4rt.units": "1f8873f6731cadacf0e0f7c1a7c65304",
"assets/assets/units/power.d4rt.units": "271c575023cf153999ed2a512101ca89",
"assets/assets/units/distance.d4rt.units": "4818213666aba3c6d96a7ac9fe54555a",
"assets/assets/units/amount.d4rt.units": "a5454d5391d30601a1252a33580a571b",
"assets/assets/units/derived.d4rt.units": "a25bc633da20499c88a161374d0aea75",
"assets/assets/units/velocity.d4rt.units": "a0518f26cc24222df8cd200f0fcf437c",
"assets/assets/units/area.d4rt.units": "3fd322d1a1c73e719344896472a758ca",
"assets/assets/units/medical.d4rt.units": "fc6de54d6cbeeaa44b32a57f4be7bb52",
"assets/assets/units/elasticity.d4rt.units": "2e4c59633ceb556c96d93b30e5335b59",
"assets/assets/units/currency.d4rt.units": "cbdcd30b11e84b8902a2240a7da5503f",
"assets/assets/units/energy.d4rt.units": "b1fcdbf723d245f750b224ba99e21b1f",
"assets/assets/units/pressure.d4rt.units": "8df1f0864e17c8986231ae7cd5d5b7ee",
"assets/assets/units/temperature.d4rt.units": "68bb34526b2c795f6c41a8e4a87c016c",
"assets/assets/units/mass.d4rt.units": "fb51b59ecf7e64bad077a6f53fa7a7a6",
"assets/assets/units/force.d4rt.units": "849493b87ab347b411900dad9545abd2",
"assets/assets/units/frequency.d4rt.units": "bbd8c394dd6960ed0f7f7ab3eaa80dbe",
"assets/assets/units/electricity.d4rt.units": "8cc4519bc9c1e5f9d8e38deaf994788d",
"assets/assets/units/charge.d4rt.units": "5d4a0384645efdd488f265ea33c89c13",
"assets/assets/formulas/misc_math.d4rt.formulas": "05c65081e665c347c3c9fd3ac1e7934f",
"assets/assets/formulas/energy_and_power.d4rt.formulas": "8dc1b03eb2b54ba99032777d37cd3fc2",
"assets/assets/formulas/electromagnetism.d4rt.formulas": "736f741327c07fa4644a190edfafeab6",
"assets/assets/formulas/medical_and_bio.d4rt.formulas": "432f30c456575343bf0ad652f9ccd5fe",
"assets/assets/formulas/trigonometry.d4rt.formulas": "d1bd41ebb8592d405bc00a36a987613b",
"assets/assets/formulas/finance.d4rt.formulas": "30c4e411b0de902a80f3290660165215",
"assets/assets/formulas/kinematics_and_dynamics.d4rt.formulas": "d1bd41ebb8592d405bc00a36a987613b",
"assets/assets/formulas/thermodynamics.d4rt.formulas": "d6eaeef591203eea212a07d1735a6c20",
"assets/assets/formulas/mdcalc.d4rt.formulas": "01007ea0dd86841403be409f9cd192f3",
"assets/assets/formulas/paz.d4rt.formulas": "fe7625e2124cdb61fe94fa4d7834ae3b",
"assets/assets/formulas/fluids_and_pressure.d4rt.formulas": "9e45643d6ed62feb55209d5039046ec0",
"assets/assets/formulas/optics.d4rt.formulas": "18a60776f0c5a067ef0ee590e7defa67",
"assets/assets/formulas/geometry.d4rt.formulas": "9f3e62e1b01eb4878a7f3dffe31cec30",
"assets/assets/formulas/conversions_and_constants.d4rt.formulas": "124e14dfff461ebd8a44005aef390e08",
"assets/assets/formulas/gravity.d4rt.formulas": "4819e87d2f8e96aa2335aeb91b033811",
"assets/assets/formulas/formulas.d4rt.formulas": "3ebeeac08c9d2d971fc5996558c67c3e",
"assets/assets/formulas/date_time.d4rt.formulas": "d6607a21ddbcebbc2c82d5ee6dab9b7c",
"assets/assets/formulas/it-networking.d4rt.formulas": "2a544cc7befc38a55bc9c6879548f132",
"assets/assets/formulas/materials_elasticity.d4rt.formulas": "e7974e2bfe9f0f8d4788272348af8be1",
"assets/assets/compile_constants.d4rt": "c5b90a7100f29080dbf3f9ad632d1a2d",
"assets/NOTICES": "7612c87fc03c90dd29ab2de0fa07c3a6",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"drift_worker.js": "646f2dc69c5ed2e039ebddf5525f5b3b",
"index.html": "49f7e3162cf47526118de3c238a57d06",
"/": "49f7e3162cf47526118de3c238a57d06",
"main.dart.js": "e1748338a45e543a2c47da8e1219ab11"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
