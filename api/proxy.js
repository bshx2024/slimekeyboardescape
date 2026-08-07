export const config = {
  runtime: 'edge',
};

export default async function handler(req) {
  const url = new URL(req.url);
  // Default embed target
  const targetUrl = 'https://topgames.gg/embed/1-speed-keyboard-escape-obby';
  
  try {
    const response = await fetch(targetUrl, {
      headers: {
        'User-Agent': req.headers.get('user-agent') || 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
      },
    });

    const modifiedHeaders = new Headers(response.headers);
    
    // Strip X-Frame-Options and Content-Security-Policy headers that block iframe embedding
    modifiedHeaders.delete('x-frame-options');
    modifiedHeaders.delete('content-security-policy');
    modifiedHeaders.delete('frame-ancestors');
    
    // Allow cross-origin embedding on our domain
    modifiedHeaders.set('Access-Control-Allow-Origin', '*');

    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: modifiedHeaders,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Proxy request failed', message: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}
