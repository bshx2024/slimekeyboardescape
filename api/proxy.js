export const config = {
  runtime: 'edge',
};

export default async function handler(req) {
  const url = new URL(req.url);
  const targetParam = url.searchParams.get('url');
  
  // Default target: TopGames embed page for +1 Speed Keyboard Escape Obby
  const targetUrl = targetParam || 'https://topgames.gg/embed/1-speed-keyboard-escape-obby';
  
  try {
    const response = await fetch(targetUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Referer': 'https://topgames.gg/',
      },
    });

    let bodyText = await response.text();

    // Neutralize frame-busting JS to ensure smooth in-page iframe rendering
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
