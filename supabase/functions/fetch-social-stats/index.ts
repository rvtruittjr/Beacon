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

const EMPTY: SocialStats = { follower_count: null, display_name: null }

// ── Platform fetchers ──────────────────────────────────────────

async function fetchInstagram(username: string): Promise<SocialStats> {
  // Strategy 1: Use Instagram's internal web profile info API
  try {
    const apiUrl = `https://i.instagram.com/api/v1/users/web_profile_info/?username=${username}`
    const apiRes = await fetch(apiUrl, {
      headers: {
        'User-Agent':
          'Instagram 275.0.0.27.98 Android (33/13; 420dpi; 1080x2400; samsung; SM-G991B; o1s; exynos2100)',
        'X-IG-App-ID': '936619743392459',
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9',
      },
    })
    if (apiRes.ok) {
      const json = await apiRes.json()
      const user = json?.data?.user
      if (user) {
        return {
          follower_count: user.edge_followed_by?.count ?? null,
          display_name: user.full_name || null,
        }
      }
    }
  } catch {
    // Fall through to strategy 2
  }

  // Strategy 2: Scrape the profile page og:description meta tag
  try {
    const url = `https://www.instagram.com/${username}/`
    const res = await fetch(url, {
      headers: {
        'User-Agent': BROWSER_UA,
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      },
      redirect: 'follow',
    })
    if (!res.ok) return EMPTY
    const html = await res.text()

    const ogDesc = extractMeta(html, 'og:description') || ''
    // "4,401 Followers, 2,651 Following, 571 Posts - See Instagram photos..."
    const followerMatch = ogDesc.match(/([\d,.]+[KkMmBb]?)\s+Followers/i)
    const followerCount = followerMatch
      ? parseFollowerString(followerMatch[1])
      : null

    // og:title: "Display Name (@username) • Instagram photos and videos"
    const ogTitle = extractMeta(html, 'og:title') || ''
    const nameMatch = ogTitle.match(/^(.+?)\s*\(@/)
    // Also check og:description for name: "... from Display Name (@username)"
    const descNameMatch = ogDesc.match(/from\s+(.+?)\s*\(/)
    const displayName =
      nameMatch?.[1]?.trim() || descNameMatch?.[1]?.trim() || null

    return { follower_count: followerCount, display_name: displayName }
  } catch {
    return EMPTY
  }
}

async function fetchTikTok(username: string): Promise<SocialStats> {
  try {
    const url = `https://www.tiktok.com/@${username}`
    const res = await fetch(url, {
      headers: {
        'User-Agent': BROWSER_UA,
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      },
      redirect: 'follow',
    })
    if (!res.ok) return EMPTY
    const html = await res.text()

    // Try to find follower data in embedded JSON (SIGI_STATE or UNIVERSAL_DATA)
    const jsonMatch = html.match(
      /"followerCount"\s*:\s*(\d+)/,
    )
    const followerCount = jsonMatch ? parseInt(jsonMatch[1], 10) : null

    // Try nickname from embedded JSON
    const nickMatch = html.match(/"nickname"\s*:\s*"([^"]+)"/)
    let displayName = nickMatch ? nickMatch[1] : null

    // Fallback to og:description
    if (!followerCount) {
      const ogDesc = extractMeta(html, 'og:description') || ''
      const ogMatch = ogDesc.match(/([\d,.]+[KkMmBb]?)\s+Followers/i)
      if (ogMatch) {
        return {
          follower_count: parseFollowerString(ogMatch[1]),
          display_name: displayName,
        }
      }
    }

    if (!displayName) {
      const ogTitle = extractMeta(html, 'og:title') || ''
      const nameMatch = ogTitle.match(/^(.+?)\s*\(@/)
      displayName = nameMatch ? nameMatch[1].trim() : null
    }

    return { follower_count: followerCount, display_name: displayName }
  } catch {
    return EMPTY
  }
}

async function fetchYouTube(username: string): Promise<SocialStats> {
  try {
    const url = `https://www.youtube.com/@${username}`
    const res = await fetch(url, {
      headers: {
        'User-Agent': BROWSER_UA,
        'Accept-Language': 'en-US,en;q=0.9',
      },
      redirect: 'follow',
    })
    if (!res.ok) return EMPTY
    const html = await res.text()

    // YouTube embeds subscriber count in the page HTML
    const subMatch = html.match(/([\d,.]+[KkMmBb]?)\s+subscribers/i)
    const followerCount = subMatch ? parseFollowerString(subMatch[1]) : null

    const ogTitle = extractMeta(html, 'og:title')
    const displayName = ogTitle
      ? ogTitle.replace(/\s*[-–—]?\s*YouTube\s*$/, '').trim()
      : null

    return { follower_count: followerCount, display_name: displayName }
  } catch {
    return EMPTY
  }
}

async function fetchTwitter(username: string): Promise<SocialStats> {
  try {
    const url = `https://x.com/${username}`
    const res = await fetch(url, {
      headers: {
        'User-Agent': BROWSER_UA,
        'Accept-Language': 'en-US,en;q=0.9',
      },
      redirect: 'follow',
    })
    if (!res.ok) return EMPTY
    const html = await res.text()

    const ogDesc = extractMeta(html, 'og:description') || ''
    const followerMatch = ogDesc.match(/([\d,.]+[KkMmBb]?)\s+Followers/i)
    const followerCount = followerMatch
      ? parseFollowerString(followerMatch[1])
      : null

    const ogTitle = extractMeta(html, 'og:title') || ''
    const nameMatch = ogTitle.match(/^(.+?)\s*\(@/)
    const displayName = nameMatch ? nameMatch[1].trim() : null

    return { follower_count: followerCount, display_name: displayName }
  } catch {
    return EMPTY
  }
}

async function fetchLinkedIn(username: string): Promise<SocialStats> {
  try {
    const url = `https://www.linkedin.com/in/${username}/`
    const res = await fetch(url, {
      headers: {
        'User-Agent': BROWSER_UA,
        'Accept-Language': 'en-US,en;q=0.9',
      },
      redirect: 'follow',
    })
    if (!res.ok) return EMPTY
    const html = await res.text()

    const ogDesc = extractMeta(html, 'og:description') || ''
    const followerMatch = ogDesc.match(/([\d,.]+[KkMmBb]?)\s+followers/i)
    const followerCount = followerMatch
      ? parseFollowerString(followerMatch[1])
      : null

    const ogTitle = extractMeta(html, 'og:title') || ''
    const displayName = ogTitle
      ? ogTitle.split(/\s*[-–—|]\s*/)[0].trim()
      : null

    return { follower_count: followerCount, display_name: displayName }
  } catch {
    return EMPTY
  }
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
    if (!res.ok) return EMPTY
    const html = await res.text()

    const ogDesc = extractMeta(html, 'og:description') || ''
    const followerMatch = ogDesc.match(/([\d,.]+[KkMmBb]?)\s+[Ff]ollowers/i)
    const followerCount = followerMatch
      ? parseFollowerString(followerMatch[1])
      : null

    const ogTitle = extractMeta(html, 'og:title')
    return { follower_count: followerCount, display_name: ogTitle }
  } catch {
    return EMPTY
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

    let stats: SocialStats = EMPTY

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
