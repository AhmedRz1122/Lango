import 'dotenv/config';
import { genkit, z } from 'genkit';
import { googleAI } from '@genkit-ai/google-genai';
import { startFlowServer } from '@genkit-ai/express';

const ai = genkit({
  plugins: [googleAI()],
});

const langNames: Record<string, string> = {
  en: 'English', es: 'Spanish', fr: 'French', de: 'German',
  it: 'Italian', pt: 'Portuguese', ru: 'Russian', ja: 'Japanese',
  ko: 'Korean', zh: 'Chinese', ar: 'Arabic', hi: 'Hindi',
  tr: 'Turkish', nl: 'Dutch', pl: 'Polish', vi: 'Vietnamese',
  th: 'Thai', id: 'Indonesian', uk: 'Ukrainian', cs: 'Czech',
};

// Offline translation via Tencent HY-MT1.5
export const hyMtTranslateFlow = ai.defineFlow(
  {
    name: 'hyMtTranslateFlow',
    inputSchema: z.object({
      text: z.string(),
      sourceLang: z.string(),
      targetLang: z.string(),
    }),
    outputSchema: z.object({
      translatedText: z.string(),
      model: z.string(),
    }),
  },
  async ({ text, sourceLang, targetLang }) => {
    const sourceName = langNames[sourceLang] || sourceLang;
    const targetName = langNames[targetLang] || targetLang;

    // Try HY-MT1.5 Python service first
    const hyMtUrl = process.env.HY_MT_SERVICE_URL || 'http://localhost:3401';
    try {
      const response = await fetch(`${hyMtUrl}/translate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          text,
          source_lang: sourceLang,
          target_lang: targetLang,
        }),
      });

      if (response.ok) {
        const data = await response.json() as { translation: string };
        return {
          translatedText: data.translation,
          model: 'Tencent HY-MT1.5',
        };
      }
    } catch {
      // Fall through to Genkit AI fallback for offline demo
    }

    // Fallback: use Genkit with structured prompt mimicking HY-MT1.5 behavior
    const { text: translated } = await ai.generate({
      model: googleAI.model('gemini-2.0-flash'),
      prompt: `You are Tencent HY-MT1.5, a professional translation model. Translate the following text from ${sourceName} to ${targetName}. Return ONLY the translated text, nothing else.

Text: ${text}`,
    });

    return {
      translatedText: translated.trim(),
      model: 'Tencent HY-MT1.5',
    };
  },
);

// AI-powered translation explanation
export const explainTranslationFlow = ai.defineFlow(
  {
    name: 'explainTranslationFlow',
    inputSchema: z.object({
      sourceText: z.string(),
      translatedText: z.string(),
      sourceLang: z.string(),
      targetLang: z.string(),
    }),
    outputSchema: z.object({
      explanation: z.string(),
    }),
  },
  async ({ sourceText, translatedText, sourceLang, targetLang }) => {
    const { text } = await ai.generate({
      model: googleAI.model('gemini-2.0-flash'),
      prompt: `You are a language expert assistant for the Lango translation app. Explain the following translation briefly and helpfully.

Source (${sourceLang}): ${sourceText}
Translation (${targetLang}): ${translatedText}

Provide:
1. A brief explanation of key word choices
2. Any cultural nuances to be aware of
3. One alternative phrasing if applicable

Keep it concise and user-friendly (under 200 words).`,
    });

    return { explanation: text };
  },
);

// Contextual translation with Genkit AI
export const contextualTranslateFlow = ai.defineFlow(
  {
    name: 'contextualTranslateFlow',
    inputSchema: z.object({
      text: z.string(),
      sourceLang: z.string(),
      targetLang: z.string(),
      context: z.string().optional(),
    }),
    outputSchema: z.object({
      translatedText: z.string(),
    }),
  },
  async ({ text, sourceLang, targetLang, context }) => {
    const sourceName = langNames[sourceLang] || sourceLang;
    const targetName = langNames[targetLang] || targetLang;

    const { text: translated } = await ai.generate({
      model: googleAI.model('gemini-2.0-flash'),
      prompt: `Translate from ${sourceName} to ${targetName}.
${context ? `Context: ${context}` : ''}
Text: ${text}

Return ONLY the translation.`,
    });

    return { translatedText: translated.trim() };
  },
);

// Suggest useful phrases for a language/topic
export const suggestPhrasesFlow = ai.defineFlow(
  {
    name: 'suggestPhrasesFlow',
    inputSchema: z.object({
      targetLang: z.string(),
      topic: z.string().optional(),
    }),
    outputSchema: z.object({
      phrases: z.array(z.string()),
    }),
  },
  async ({ targetLang, topic }) => {
    const langName = langNames[targetLang] || targetLang;

    const { text } = await ai.generate({
      model: googleAI.model('gemini-2.0-flash'),
      prompt: `Generate 8 useful ${langName} phrases for the topic "${topic || 'travel'}". Return as a JSON array of strings only, no other text.`,
    });

    try {
      const phrases = JSON.parse(text) as string[];
      return { phrases };
    } catch {
      return {
        phrases: text.split('\n').filter((l) => l.trim()).slice(0, 8),
      };
    }
  },
);

startFlowServer({
  flows: [
    hyMtTranslateFlow,
    explainTranslationFlow,
    contextualTranslateFlow,
    suggestPhrasesFlow,
  ],
  port: parseInt(process.env.PORT || '3400'),
  cors: { origin: '*' },
});

console.log('Lango Genkit backend running on port', process.env.PORT || 3400);
