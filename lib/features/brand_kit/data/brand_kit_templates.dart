import '../models/brand_kit_template.dart';

const kBrandKitTemplates = <BrandKitTemplate>[
  // ─── Tech Startup ───────────────────────────────────────────
  BrandKitTemplate(
    name: 'Tech Startup',
    description: 'Clean, modern, and confident. Built for SaaS, dev tools, and tech brands.',
    icon: '\u{1F680}',
    colors: [
      TemplateColor('#0A84FF', 'Primary'),
      TemplateColor('#1C1C1E', 'Dark'),
      TemplateColor('#F5F5F7', 'Light'),
      TemplateColor('#34C759', 'Success'),
    ],
    fonts: [
      TemplateFont('Space Grotesk', 'Heading', weight: '700'),
      TemplateFont('Inter', 'Body', weight: '400'),
    ],
    voice: TemplateVoice(
      archetype: 'The Innovator',
      personalityTags: ['Forward-thinking', 'Precise', 'Confident', 'Approachable'],
      toneFormal: 6,
      toneSerious: 4,
      toneBold: 7,
      voiceSummary: 'We speak with clarity and confidence. Technical enough to earn trust, human enough to be understood.',
      tagline: 'Build the future, today.',
      wordsWeUse: ['ship', 'launch', 'scale', 'empower', 'seamless'],
      wordsWeAvoid: ['synergy', 'disrupt', 'pivot', 'guru', 'hack'],
    ),
    audience: TemplateAudience(
      personaName: 'The Builder',
      personaSummary: 'Tech-savvy professionals and founders who value efficiency, clean design, and tools that just work.',
      ageRangeMin: 25,
      ageRangeMax: 40,
      interests: ['SaaS products', 'Productivity tools', 'Developer culture', 'Design systems'],
      painPoints: ['Bloated software', 'Poor documentation', 'Slow onboarding'],
      goals: ['Ship faster', 'Scale their product', 'Build a loyal user base'],
    ),
    pillars: [
      TemplatePillar('Product Updates', description: 'New features, changelogs, and roadmap', color: '#0A84FF'),
      TemplatePillar('Thought Leadership', description: 'Industry insights and opinions', color: '#34C759'),
      TemplatePillar('Behind the Build', description: 'Engineering stories and team culture', color: '#FF9500'),
    ],
  ),

  // ─── Personal Brand / Podcast ──────────────────────────────
  BrandKitTemplate(
    name: 'Personal Brand',
    description: 'Warm, authentic, and story-driven. Perfect for podcasters and creators.',
    icon: '\u{1F399}',
    colors: [
      TemplateColor('#FF6B35', 'Primary'),
      TemplateColor('#2D2D2D', 'Dark'),
      TemplateColor('#FFF8F0', 'Cream'),
      TemplateColor('#1A1A2E', 'Deep Navy'),
    ],
    fonts: [
      TemplateFont('Outfit', 'Heading', weight: '700'),
      TemplateFont('Lora', 'Body', weight: '400'),
    ],
    voice: TemplateVoice(
      archetype: 'The Storyteller',
      personalityTags: ['Authentic', 'Warm', 'Curious', 'Relatable'],
      toneFormal: 3,
      toneSerious: 3,
      toneBold: 6,
      voiceSummary: 'We share real stories and honest perspectives. Conversational but intentional, like talking to a smart friend.',
      tagline: 'Real stories. Real growth.',
      wordsWeUse: ['journey', 'honest', 'explore', 'connect', 'share'],
      wordsWeAvoid: ['grind', 'hustle', 'monetize', 'followers', 'viral'],
    ),
    audience: TemplateAudience(
      personaName: 'The Curious Creator',
      personaSummary: 'Aspiring and established creators who value authenticity over vanity metrics and want to build a genuine community.',
      ageRangeMin: 22,
      ageRangeMax: 38,
      interests: ['Podcasts', 'Personal development', 'Storytelling', 'Community building'],
      painPoints: ['Imposter syndrome', 'Content burnout', 'Growing without selling out'],
      goals: ['Build an engaged audience', 'Monetize authentically', 'Tell better stories'],
    ),
    pillars: [
      TemplatePillar('Stories & Lessons', description: 'Personal experiences and takeaways', color: '#FF6B35'),
      TemplatePillar('Interviews', description: 'Conversations with interesting people', color: '#1A1A2E'),
      TemplatePillar('Community', description: 'Audience Q&A and engagement', color: '#2D6A4F'),
    ],
  ),

  // ─── Creative Agency ───────────────────────────────────────
  BrandKitTemplate(
    name: 'Creative Agency',
    description: 'Bold, expressive, and unapologetic. For design studios and creative teams.',
    icon: '\u{1F3A8}',
    colors: [
      TemplateColor('#FF006E', 'Magenta'),
      TemplateColor('#000000', 'Black'),
      TemplateColor('#FFFFFF', 'White'),
      TemplateColor('#3A86FF', 'Electric Blue'),
    ],
    fonts: [
      TemplateFont('Syne', 'Heading', weight: '700'),
      TemplateFont('DM Sans', 'Body', weight: '400'),
    ],
    voice: TemplateVoice(
      archetype: 'The Creator',
      personalityTags: ['Bold', 'Witty', 'Experimental', 'Provocative'],
      toneFormal: 4,
      toneSerious: 3,
      toneBold: 9,
      voiceSummary: 'We challenge the status quo with sharp ideas and bolder execution. Our work speaks loudly and so do we.',
      tagline: 'Make it impossible to ignore.',
      wordsWeUse: ['craft', 'bold', 'vision', 'spark', 'redefine'],
      wordsWeAvoid: ['basic', 'template', 'standard', 'conventional', 'safe'],
    ),
    audience: TemplateAudience(
      personaName: 'The Visionary Client',
      personaSummary: 'Brands and founders who want to stand out, not blend in. They appreciate creative risk and invest in design as a competitive advantage.',
      ageRangeMin: 28,
      ageRangeMax: 45,
      interests: ['Design', 'Art direction', 'Brand strategy', 'Cultural trends'],
      painPoints: ['Generic branding', 'Agencies that play it safe', 'Forgettable identities'],
      goals: ['A brand that turns heads', 'Award-worthy creative', 'Cultural relevance'],
    ),
    pillars: [
      TemplatePillar('Case Studies', description: 'Deep dives into our best work', color: '#FF006E'),
      TemplatePillar('Design Thinking', description: 'Process, inspiration, and POVs', color: '#3A86FF'),
      TemplatePillar('Culture', description: 'Trends, events, and studio life', color: '#000000'),
    ],
  ),

  // ─── E-commerce / DTC ──────────────────────────────────────
  BrandKitTemplate(
    name: 'E-commerce',
    description: 'Trustworthy, approachable, and conversion-focused. For DTC and retail brands.',
    icon: '\u{1F6CD}',
    colors: [
      TemplateColor('#2D6A4F', 'Forest'),
      TemplateColor('#40916C', 'Sage'),
      TemplateColor('#D8F3DC', 'Mint'),
      TemplateColor('#1B4332', 'Deep Green'),
    ],
    fonts: [
      TemplateFont('Poppins', 'Heading', weight: '600'),
      TemplateFont('Nunito', 'Body', weight: '400'),
    ],
    voice: TemplateVoice(
      archetype: 'The Guide',
      personalityTags: ['Trustworthy', 'Warm', 'Helpful', 'Clear'],
      toneFormal: 5,
      toneSerious: 4,
      toneBold: 5,
      voiceSummary: 'We guide customers with warmth and clarity. Every word builds trust and moves people closer to a decision they feel good about.',
      tagline: 'Quality you can feel.',
      wordsWeUse: ['curated', 'crafted', 'sustainable', 'everyday', 'thoughtful'],
      wordsWeAvoid: ['cheap', 'deal', 'limited time', 'act now', 'FOMO'],
    ),
    audience: TemplateAudience(
      personaName: 'The Conscious Shopper',
      personaSummary: 'Values-driven consumers who research before buying. They care about quality, sustainability, and the story behind the brand.',
      ageRangeMin: 25,
      ageRangeMax: 42,
      interests: ['Sustainable living', 'Home goods', 'Wellness', 'Small business'],
      painPoints: ['Greenwashing', 'Poor product quality', 'Impersonal shopping experiences'],
      goals: ['Buy less, buy better', 'Support ethical brands', 'Find products they love'],
    ),
    pillars: [
      TemplatePillar('Product Spotlight', description: 'Features, launches, and how-tos', color: '#2D6A4F'),
      TemplatePillar('Behind the Brand', description: 'Sourcing, making, and values', color: '#40916C'),
      TemplatePillar('Customer Stories', description: 'Reviews, UGC, and community', color: '#D8F3DC'),
    ],
  ),

  // ─── Wellness / Lifestyle ──────────────────────────────────
  BrandKitTemplate(
    name: 'Wellness',
    description: 'Calm, nurturing, and intentional. For health, wellness, and lifestyle brands.',
    icon: '\u{1F33F}',
    colors: [
      TemplateColor('#A7C4A0', 'Sage'),
      TemplateColor('#E8D5C4', 'Sand'),
      TemplateColor('#D4A5A5', 'Blush'),
      TemplateColor('#F5EFE7', 'Linen'),
    ],
    fonts: [
      TemplateFont('Cormorant Garamond', 'Heading', weight: '600'),
      TemplateFont('Jost', 'Body', weight: '400'),
    ],
    voice: TemplateVoice(
      archetype: 'The Caregiver',
      personalityTags: ['Gentle', 'Grounded', 'Nurturing', 'Mindful'],
      toneFormal: 3,
      toneSerious: 2,
      toneBold: 4,
      voiceSummary: 'We create a space of calm and intention. Our words are gentle but purposeful, guiding people toward balance and self-care.',
      tagline: 'Find your balance.',
      wordsWeUse: ['nourish', 'restore', 'mindful', 'intentional', 'ritual'],
      wordsWeAvoid: ['grind', 'hustle', 'no pain no gain', 'extreme', 'crush it'],
    ),
    audience: TemplateAudience(
      personaName: 'The Mindful Seeker',
      personaSummary: 'Health-conscious individuals seeking balance in a busy world. They value self-care routines and holistic approaches to wellbeing.',
      ageRangeMin: 24,
      ageRangeMax: 40,
      interests: ['Yoga', 'Meditation', 'Clean eating', 'Skincare', 'Journaling'],
      painPoints: ['Burnout', 'Information overload', 'Toxic wellness culture'],
      goals: ['Build sustainable habits', 'Feel more balanced', 'Connect with like-minded people'],
    ),
    pillars: [
      TemplatePillar('Rituals & Routines', description: 'Daily practices for wellbeing', color: '#A7C4A0'),
      TemplatePillar('Nourish', description: 'Recipes, ingredients, and nutrition', color: '#E8D5C4'),
      TemplatePillar('Mindset', description: 'Mental health, journaling, and reflection', color: '#D4A5A5'),
    ],
  ),
];
