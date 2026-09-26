'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"manifest.json": "9f59f184d5162299ca2c6c2251b41a37",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"flutter_bootstrap.js": "844f58b9ace75c7f8ab29c2b33e46dd4",
"assets/AssetManifest.bin.json": "6e0dd59c7d86eb33bcb61a7e691af79c",
"assets/AssetManifest.json": "377761ea1881415cc2e1b515b8539be5",
"assets/assets/data/states_index.json": "46c9fea0e810db5b53ca1901b6cf04a7",
"assets/assets/data/pu_sample.json": "8f5cef2b62b3b8334599cf7129d9f3a0",
"assets/assets/data/states/10-delta.json": "32ed2c7f7971ca7b567542c8ebddb996",
"assets/assets/data/states/03-akwa-ibom.json": "92034ec3a8705ae64ba8ddc999936707",
"assets/assets/data/states/11-ebonyi.json": "f1e19986d811e1c6f2499fe36d7b18e2",
"assets/assets/data/states/29-osun.json": "60ce2e5995ba525348faa3073784c779",
"assets/assets/data/states/08-borno.json": "2c051c2729efba24a6d75415cd4e0436",
"assets/assets/data/states/33-sokoto.json": "e5a6270e074a4c1eea3dc3ee04704591",
"assets/assets/data/states/37-federal-capital-territory.json": "49b61b5744c51cbf3fabdc8f79eea1e3",
"assets/assets/data/states/18-kaduna.json": "acfcb305924716221a7b2f5bffcb3d14",
"assets/assets/data/states/35-yobe.json": "17dfb49571a67a3d0c2263d5c125e43e",
"assets/assets/data/states/28-ondo.json": "3e6318957d40f22c516fcc22dcc84dd1",
"assets/assets/data/states/01-abia.json": "e185c676f692a1b4eef6c40c1a3fcab1",
"assets/assets/data/states/31-plateau.json": "94f70aa8fbddb6ed5b4d0d016a8ed8a1",
"assets/assets/data/states/19-kano.json": "12a65dec993167cd235f2f58536f8cd8",
"assets/assets/data/states/36-zamfara.json": "0a575e43b118d39e30caf12cb73ea605",
"assets/assets/data/states/20-katsina.json": "a243829db8f53f5ef1a22c84297b9c76",
"assets/assets/data/states/13-ekiti.json": "fc31c504595f34551322b81925788f06",
"assets/assets/data/states/07-benue.json": "dcc7cf3c105f416e33e7521a130c4fd9",
"assets/assets/data/states/15-gombe.json": "206363839f8d021b4e3c7e5fc26d4a74",
"assets/assets/data/states/17-jigawa.json": "5e273c7c234caceb72d8884484900427",
"assets/assets/data/states/27-ogun.json": "50275fa8de48f2a1aac969a500a312a8",
"assets/assets/data/states/16-imo.json": "947ad5892fcbf7220dbbc81770b39142",
"assets/assets/data/states/30-oyo.json": "e4c750bcdcbf0fe2d9d1c86095a5c6f9",
"assets/assets/data/states/32-rivers.json": "7212ded4208d69b00c4e949ea69d4166",
"assets/assets/data/states/04-anambra.json": "9832b597f612f870a3b93732a37af309",
"assets/assets/data/states/22-kogi.json": "a2a5f8e48d7126040638f1333144ec38",
"assets/assets/data/states/09-cross-river.json": "a2b6658a9128b83945f24c7a587d25b1",
"assets/assets/data/states/23-kwara.json": "7659ee023c32c5f58e63b947a81b23a8",
"assets/assets/data/states/21-kebbi.json": "b09a6df66b62ca4eb9fe430f7fcd3703",
"assets/assets/data/states/06-bayelsa.json": "73efab570c94d8ce518048dd8e979f6e",
"assets/assets/data/states/25-nasarawa.json": "475a92dc5c2dc75ec67c53067ac407f3",
"assets/assets/data/states/02-adamawa.json": "bde6662eb66f3084f8b34a0d8c929436",
"assets/assets/data/states/34-taraba.json": "5b6f9fdde3d8062ac170c1d185d75a8f",
"assets/assets/data/states/12-edo.json": "316563cf616a44569d81f1e3003d2452",
"assets/assets/data/states/26-niger.json": "732fa88c1a224fe25d57254a312f48e4",
"assets/assets/data/states/24-lagos.json": "6fae369ddf9fa1b4b1826e49230d7759",
"assets/assets/data/states/05-bauchi.json": "adc9705efabc0ea87d1c3e1075007fb5",
"assets/assets/data/states/14-enugu.json": "436a3710715b6e62e6fc666b85a7ee25",
"assets/NOTICES": "9ec0ed5cbeb72019bbaac628409ca7dc",
"assets/AssetManifest.bin": "f1f28b8ba1982121ed252b4e088244b6",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/fonts/MaterialIcons-Regular.otf": "b73eeeae3c1a38c7200e9ea6b31b410a",
"index.html": "402b81395a96f08708eafe907b2c280c",
"/": "402b81395a96f08708eafe907b2c280c",
"version.json": "72055b9db7cb57a2183c9076cca29b4d",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"main.dart.js": "35b1c5cff6ef979c2a05c8ed1bac0022",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d"};
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
