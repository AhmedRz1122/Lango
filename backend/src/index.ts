import 'dotenv/config';
import { genkit, z } from 'genkit';
import { startFlowServer } from '@genkit-ai/express';
import { deepseekTranslate } from './deepseek_translate.js';

const ai = genkit({});

/** Translation-only DeepSeek flow for online mode (~100 languages). */
export const deepseekTranslateFlow = ai.defineFlow(
  {
    name: 'deepseekTranslateFlow',
    inputSchema: z.object({
      text: z.string().max(5000),
      sourceLang: z.string(),
      targetLang: z.string(),
    }),
    outputSchema: z.object({
      translatedText: z.string(),
      model: z.literal('deepseek'),
    }),
  },
  async ({ text, sourceLang, targetLang }) => {
    const translatedText = await deepseekTranslate(text, sourceLang, targetLang);
    return {
      translatedText,
      model: 'deepseek' as const,
    };
  },
);

startFlowServer({
  flows: [deepseekTranslateFlow],
  port: parseInt(process.env.PORT || '3400'),
  cors: { origin: '*' },
});

console.log('Lango backend (DeepSeek translation only) on port', process.env.PORT || 3400);
