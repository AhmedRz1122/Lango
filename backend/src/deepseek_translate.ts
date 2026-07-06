import {
  DEEPSEEK_LANG_CODES,
  DEEPSEEK_LANG_NAMES,
} from './deepseek_languages.js';

const MAX_INPUT_CHARS = 5000;

function buildTranslationPrompt(
  text: string,
  sourceLang: string,
  targetLang: string,
): string {
  const targetName = DEEPSEEK_LANG_NAMES[targetLang] ?? targetLang;
  return `Translate to ${targetName}. Output only the translation, nothing else:\n\n${text}`;
}

function estimateMaxTokens(text: string): number {
  const wordCount = text.trim().split(/\s+/).filter(Boolean).length;
  return Math.min(Math.max(wordCount * 3, 64), 1024);
}

export async function deepseekTranslate(
  text: string,
  sourceLang: string,
  targetLang: string,
): Promise<string> {
  const apiKey = process.env.DEEPSEEK_API_KEY;
  if (!apiKey) {
    throw new Error('DEEPSEEK_API_KEY is not configured in backend/.env');
  }

  const trimmed = text.trim();
  if (!trimmed) return '';

  if (trimmed.length > MAX_INPUT_CHARS) {
    throw new Error(`Text exceeds maximum length of ${MAX_INPUT_CHARS} characters`);
  }

  if (!DEEPSEEK_LANG_CODES.has(sourceLang) || !DEEPSEEK_LANG_CODES.has(targetLang)) {
    throw new Error(`Unsupported language pair: ${sourceLang} -> ${targetLang}`);
  }

  const model = process.env.DEEPSEEK_MODEL ?? 'deepseek-chat';
  if (model.includes('reasoner')) {
    console.warn(
      'DEEPSEEK_MODEL is a reasoning model and will be slow for translation. ' +
        'Use deepseek-chat for faster responses.',
    );
  }

  const res = await fetch('https://api.deepseek.com/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model,
      temperature: 0.1,
      max_tokens: estimateMaxTokens(trimmed),
      messages: [
        {
          role: 'system',
          content:
            'You are a translation engine. Translate the user text exactly. ' +
            'Reply with only the translated text — no quotes, labels, or explanations.',
        },
        {
          role: 'user',
          content: buildTranslationPrompt(trimmed, sourceLang, targetLang),
        },
      ],
    }),
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`DeepSeek API error (${res.status}): ${body}`);
  }

  const data = (await res.json()) as {
    choices?: Array<{ message?: { content?: string } }>;
  };

  const content = data.choices?.[0]?.message?.content?.trim();
  if (!content) {
    throw new Error('DeepSeek returned an empty response');
  }

  return content
    .replace(/^["']|["']$/g, '')
    .replace(/^```[\w]*\n?|\n?```$/g, '')
    .trim();
}
