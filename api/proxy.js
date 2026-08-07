export const config = {
  runtime: 'edge',
};

export default async function handler(req) {
  const url = new URL(req.url);
  const targetParam = url.searchParams.get('url');
  
  // Directly proxy Yandex game application with distribution tokens
  const targetUrl = targetParam || 'https://yandex.com/games/app/541802?utm_source=distrib&is-united-page=1&skip-guard=1&header=no&utm_medium=topgames.gg&clid=10575041&flags=%7B%22adv_sticky_banner_disabled%22%3Atrue%7D';
  
  try {
    const response = await fetch(targetUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Referer': 'https://topgames.gg/',
      },
    });

    let bodyText = await response.text();
    
    // 1. Inject Yandex SDK Auto-Responder script right in <head>
    const sdkMockScript = `
    <script>
      (function() {
        // Auto-respond to Yandex SDK postMessage handshake
        window.addEventListener('message', function(e) {
          try {
            if (e.data && (typeof e.data === 'object' || typeof e.data === 'string')) {
              var str = typeof e.data === 'string' ? e.data : JSON.stringify(e.data);
              if (str.includes('ysdk') || str.includes('init') || str.includes('sdk')) {
                window.postMessage({ type: 'ysdk:init:success', status: 'ok', data: {} }, '*');
              }
            }
          } catch(err) {}
        });

        // Neutralize frame checks
        try {
          Object.defineProperty(window, 'top', { get: function() { return window.self; } });
          Object.defineProperty(window, 'parent', { get: function() { return window.self; } });
        } catch(e) {}
      })();
    </script>
    `;

    bodyText = bodyText.replace('<head>', '<head>' + sdkMockScript);
    
    // 2. Patch appData flags to bypass framing checks
    bodyText = bodyText.replace('"isFraming":true', '"isFraming":false');
    bodyText = bodyText.replace('"isInternalEmbedder":false', '"isInternalEmbedder":true');
    
    // 3. Neutralize window.top references
    bodyText = bodyText.replace(/window\.top/g, 'window.self');
    bodyText = bodyText.replace(/top\.location/g, 'self.location');
    bodyText = bodyText.replace(/parent\.location/g, 'self.location');

    const modifiedHeaders = new Headers();
    modifiedHeaders.set('Access-Control-Allow-Origin', '*');
    modifiedHeaders.set('Content-Type', 'text/html; charset=utf-8');
    modifiedHeaders.set('Cache-Control', 'no-cache, no-store, must-revalidate');

    return new Response(bodyText, {
      status: 200,
      headers: modifiedHeaders,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Proxy failed', message: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}
