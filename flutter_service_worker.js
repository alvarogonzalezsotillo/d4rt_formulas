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
"flutter_bootstrap.js": "400f33582703d6228bd277575184fe9e",
"version.json": "35c6f6bd1887837d27a09cf63cb58b6c",
"manifest.json": "b0d827cdee586cbabaa7f13c2bb48431",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/FontManifest.json": "f9097450010bd82cf16bb016ba2219d8",
"assets/AssetManifest.bin": "cfeb8071cf1654baf7599bacf2cf0659",
"assets/AssetManifest.bin.json": "c746d79eb1460e58c4361e1f86c5bb45",
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
"assets/assets/units/scalar.d4rt.units": "9770497926459111d054ea10df5e55cb",
"assets/assets/units/time.d4rt.units": "ff5f3257193568123676c1ae067e222f",
"assets/assets/units/volume.d4rt.units": "255a76f8c8ed4e23ccfe38d3041f89f4",
"assets/assets/units/angle.d4rt.units": "3fe519cc35fbe2b09a82968bbb4c30e1",
"assets/assets/units/power.d4rt.units": "c2952e270306d89bdceeb6b9f69cf23e",
"assets/assets/units/distance.d4rt.units": "cb49c46447104dcda29bcacaa03b931b",
"assets/assets/units/amount.d4rt.units": "e896c88a353d9251b668d9c190e1a635",
"assets/assets/units/derived.d4rt.units": "35f99faf82750326d89adb6e18b2e4bb",
"assets/assets/units/velocity.d4rt.units": "ffb22acb5af39228f907894d358f9308",
"assets/assets/units/area.d4rt.units": "6badd0dae8d1eed2f5bbcab34d13ab0f",
"assets/assets/units/elasticity.d4rt.units": "601ea2c40429b089f75c52a066e9720a",
"assets/assets/units/currency.d4rt.units": "0fffdff35e79baa3126a470aa501c2b7",
"assets/assets/units/energy.d4rt.units": "c4604add3d50f8e32fb9462079eefd61",
"assets/assets/units/pressure.d4rt.units": "0ded71713946b3a708ae8469c3c9869b",
"assets/assets/units/temperature.d4rt.units": "8905251f2d007342208b563acb4cf896",
"assets/assets/units/mass.d4rt.units": "c73e4db74f9528740c968649cfe856cf",
"assets/assets/units/force.d4rt.units": "525969c7f6c0d88dd32cdbefa5d29a92",
"assets/assets/units/frequency.d4rt.units": "1ea13391776eb91c0aec736e8848c829",
"assets/assets/units/electricity.d4rt.units": "6fb9abab72da23b0861f5b88f468f050",
"assets/assets/units/charge.d4rt.units": "1ff93078e88a9be3406e038495b943d9",
"assets/assets/formulas/conversions_and_constants.d4rt": "546a82b7b8cea6591cd7cf81e14d87b3",
"assets/assets/formulas/energy_and_power.d4rt": "8e4a2d1d30f52f505fc884f87b1e6edd",
"assets/assets/formulas/kinematics_and_dynamics.d4rt": "2efccddfb1d69128d78404d5bfb7584d",
"assets/assets/formulas/geometry.d4rt": "76a0bedd58b4bc2c9f3911cb9efe2cc9",
"assets/assets/formulas/fluids_and_pressure.d4rt": "7ea2cd6a31b28b62f0de542ee67d5a0a",
"assets/assets/formulas/formulas.d4rt": "78faefbd4917226424e06a274baea2aa",
"assets/assets/formulas/medical_and_bio.d4rt": "e0531e95a3612fbb0e0fdf6104fc7a42",
"assets/assets/formulas/misc_math.d4rt": "21e734710dd1b6f88affe56386d722a4",
"assets/assets/formulas/trigonometry.d4rt": "2efccddfb1d69128d78404d5bfb7584d",
"assets/assets/formulas/electromagnetism.d4rt": "f134d83566fe80cd25e72a53a93e471f",
"assets/assets/formulas/gravity.d4rt": "a6735dcd84b4f720ea6182cf1b391342",
"assets/assets/formulas/materials_elasticity.d4rt": "18da4476cbd4b4ab27cb5db60d59d9c8",
"assets/assets/formulas/it-networking.d4rt": "dfa46179b6af7b2cf2228a517c7cfee3",
"assets/assets/formulas/optics.d4rt": "9e766e52b45791ee1079b5cbdfcac3d9",
"assets/assets/formulas/thermodynamics.d4rt": "e1ea12c091eb66bec3f9a3d22aa3d3df",
"assets/NOTICES": "7612c87fc03c90dd29ab2de0fa07c3a6",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"drift_worker.js": "646f2dc69c5ed2e039ebddf5525f5b3b",
"index.html": "49f7e3162cf47526118de3c238a57d06",
"/": "49f7e3162cf47526118de3c238a57d06",
"main.dart.js": "7db3f5a2e2152f3db830ed56f92d35c8"};
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
