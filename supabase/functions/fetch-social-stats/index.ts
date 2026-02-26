import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
}

const BROWSER_UA =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'

// ── Helpers ────────────────────────────────────────────────────

function parseFollowerString(raw: string): number | null {
  if (!raw) return null
  const cleaned = raw.trim().replace(/,/g, '')
  // Handle "1.2M", "12.5K", etc.
  const match = cleaned.match(/^([\d.]+)\s*([KkMmBb])?/)
  if (!match) return null
  let num = parseFloat(match[1])
  if (isNaN(num)) return null
  const suffix = (match[2] || '').toUpperCase()
  if (suffix === 'K') num *= 1_000
  else if (suffix === 'M') num *= 1_000_000
  else if (suffix === 'B') num *= 1_000_000_000
  return Math.round(num)
}

function extractMeta(html: string, property: string): string | null {
  // Match <meta property="..." content="..."> or <meta name="..." content="...">
  const regex = new RegExp(
    `<meta[^>]*(?:property|name)=["']${property}["'][^>]*content=["']([^"']*)["']`,
    'i',
  )
  const match = html.match(regex)
  if (match) return match[1]
  // Also try reversed attribute order: content before property
  const regex2 = new RegExp(
    `<meta[^>]*content=["']([^"']*)["'][^>]*(?:property|name)=["']${property}["']`,
    'i',
  )
  const match2 = html.match(regex2)
  return match2 ? match2[1] : null
}

interface SocialStats {
  follower_count: number | null
  display_name: string | null
}

// ── Platform fetchers ──────────────────────────────────────────

async function fetchInstagram(username: string): Promise<SocialStats> {
  // Try fetching profile page – Instagram includes follower info in og:description
  // e.g. "1.2M Followers, 500 Following, 300 Posts ..."
  const url = `https://www.instagram.com/${username}/`
  const res = await fetch(url, {
    headers: { 'User-Agent': BROWSER_UA, 'Accept-Language': 'en-US,en;q=0.9' },
    redirect: 'follow',
  })
  if (!res.ok) return { follower_count: null, display_name: null }
  const html = await res.text()

  const ogDesc = extractMeta(html, 'og:description') || ''
  // Pattern: "1,234 Followers" or "1.2M Followers"
  const followerMatch = ogDesc.match(/([\d,.]+[KkMmBb]?)\s+Followers/i)
  const followerCount = followerMatch
    ? parseFollowerString(followerMatch[1])
    : null

  const ogTitle = extractMeta(html, 'og:title') || ''
  // og:title is usually "Display Name (@username) • Instagram photos and videos"
  const nameMatch = ogTitle.match(/^(.+?)\s*\(@/)
  const displayName = nameMatch ? nameMatch[1].trim() : null

  return { follower_count: followerCount, display_name: displayName }
}

async function fetchTikTok(username: string): Promise<SocialStats> {
  const url = `https://www.tiktok.com/@${username}`
  const res = await fetch(url, {
    headers: { 'User-Agent': BROWSER_UA, 'Accept-Language': 'en-US,en;q=0.9' },
    redirect: 'follow',
  })
  if (!res.ok) return { follower_count: null, display_name: null }
  const html = await res.text()

  // TikTok often has follower count in a JSON-LD or script with __UNIVERSAL_DATA
  // Try og:description: "username (@handle) on TikTok | 1.2M Followers..."
  const ogDesc = extractMeta(html, 'og:description') || ''
  const followerMatch = ogDesc.match(/([\d,.]+[KkMmBb]?)\s+Followers/i)
  const followerCount = followerMatch
    ? parseFollowerString(followerMatch[1])
    : null

  const ogTitle = extractMeta(html, 'og:title') || ''
  const nameMatch = ogTitle.match(/^(.+?)\s*\(@/)
  const displayName = nameMatch ? nameMatch[1].trim() : null

  return { follower_count: followerCount, display_name: displayName }
}

async function fetchYouTube(username: string): Promise<SocialStats> {
  // Try @handle URL format
  const url = `https://www.youtube.com/@${username}`
  const res = await fetch(url, {
    headers: { 'User-Agent': BROWSER_UA, 'Accept-Language': 'en-US,en;q=0.9' },
    redirect: 'follow',
  })
  if (!res.ok) return { follower_count: null, display_name: null }
  const html = await res.text()

  // YouTube includes subscriber count in the page content
  // Look for "X subscribers" pattern in the HTML
  const subMatch = html.match(/([\d,.]+[KkMmBb]?)\s+subscribers/i)
  const followerCount = subMatch ? parseFollowerString(subMatch[1]) : null

  const ogTitle = extractMeta(html, 'og:title')
  const displayName = ogTitle
    ? ogTitle.replace(/\s*[-–—]?\s*YouTube\s*$/, '').trim()
    : null

  return { follower_count: followerCount, display_name: displayName }
}

async function fetchTwitter(username: string): Promise<SocialStats> {
  // X/Twitter – try to fetch the profile page (nitter as a fallback idea)
  // Twitter's main site requires JS, but may include some meta info
  const url = `https://x.com/${username}`
  const res = await fetch(url, {
    headers: { 'User-Agent': BROWSER_UA, 'Accept-Language': 'en-US,en;q=0.9' },
    redirect: 'follow',
  })
  if (!res.ok) return { follower_count: null, display_name: null }
  const html = await res.text()

  const ogDesc = extractMeta(html, 'og:description') || ''
  // Common pattern: "X Followers" or includes follower count
  const followerMatch = ogDesc.match(/([\d,.]+[KkMmBb]?)\s+Followers/i)
  const followerCount = followerMatch
    ? parseFollowerString(followerMatch[1])
    : null

  const ogTitle = extractMeta(html, 'og:title') || ''
  // e.g. "John Doe (@johndoe) / X"
  const nameMatch = ogTitle.match(/^(.+?)\s*\(@/)
  const displayName = nameMatch ? nameMatch[1].trim() : null

  return { follower_count: followerCount, display_name: displayName }
}

async function fetchLinkedIn(username: string): Promise<SocialStats> {
  const url = `https://www.linkedin.com/in/${username}/`
  const res = await fetch(url, {
    headers: { 'User-Agent': BROWSER_UA, 'Accept-Language': 'en-US,en;q=0.9' },
    redirect: 'follow',
  })
  if (!res.ok) return { follower_count: null, display_name: null }
  const html = await res.text()

  const ogDesc = extractMeta(html, 'og:description') || ''
  const followerMatch = ogDesc.match(/([\d,.]+[KkMmBb]?)\s+followers/i)
  const followerCount = followerMatch
    ? parseFollowerString(followerMatch[1])
    : null

  const ogTitle = extractMeta(html, 'og:title') || ''
  // e.g. "John Doe - Senior Dev | LinkedIn"
  const displayName = ogTitle
    ? ogTitle.split(/\s*[-–—|]\s*/)[0].trim()
    : null

  return { follower_count: followerCount, display_name: displayName }
}

async function fetchGenericProfile(
  profileUrl: string,
): Promise<SocialStats> {
  try {
    const res = await fetch(profileUrl, {
      headers: {
        'User-Agent': BROWSER_UA,
        'Accept-Language': 'en-US,en;q=0.9',
      },
      redirect: 'follow',
    })
    if (!res.ok) return { follower_count: null, display_name: null }
    const html = await res.text()

    const ogDesc = extractMeta(html, 'og:description') || ''
    const followerMatch = ogDesc.match(/([\d,.]+[KkMmBb]?)\s+[Ff]ollowers/i)
    const followerCount = followerMatch
      ? parseFollowerString(followerMatch[1])
      : null

    const ogTitle = extractMeta(html, 'og:title')
    return { follower_count: followerCount, display_name: ogTitle }
  } catch {
    return { follower_count: null, display_name: null }
  }
}

// ── Platform URL builders ──────────────────────────────────────

function buildProfileUrl(platform: string, username: string): string | null {
  switch (platform) {
    case 'Facebook':
      return `https://www.facebook.com/${username}`
    case 'Pinterest':
      return `https://www.pinterest.com/${username}/`
    case 'Threads':
      return `https://www.threads.net/@${username}`
    case 'Twitch':
      return `https://www.twitch.tv/${username}`
    case 'Substack':
      return `https://${username}.substack.com`
    default:
      return null
  }
}

// ── Main handler ───────────────────────────────────────────────

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { platform, username } = await req.json()

    if (!platform || !username) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: platform, username' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      )
    }

    let stats: SocialStats = { follower_count: null, display_name: null }

    switch (platform) {
      case 'Instagram':
        stats = await fetchInstagram(username)
        break
      case 'TikTok':
        stats = await fetchTikTok(username)
        break
      case 'YouTube':
        stats = await fetchYouTube(username)
        break
      case 'X (Twitter)':
        stats = await fetchTwitter(username)
        break
      case 'LinkedIn':
        stats = await fetchLinkedIn(username)
        break
      default: {
        const profileUrl = buildProfileUrl(platform, username)
        if (profileUrl) {
          stats = await fetchGenericProfile(profileUrl)
        }
        break
      }
    }

    return new Response(JSON.stringify(stats), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err) {
    return new Response(
      JSON.stringify({
        follower_count: null,
        display_name: null,
        error: err.message,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )
  }
})
