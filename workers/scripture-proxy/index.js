export default {
  async fetch(request) {
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, OPTIONS',
          'Access-Control-Max-Age': '86400',
        },
      });
    }

    const url = new URL(request.url);
    const apiUrl = 'https://openscriptureapi.org' + url.pathname + url.search;
    const apiResponse = await fetch(apiUrl, { method: 'GET' });

    const proxied = new Response(apiResponse.body, apiResponse);
    proxied.headers.set('Access-Control-Allow-Origin', '*');
    return proxied;
  },
};
