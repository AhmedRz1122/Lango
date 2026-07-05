import 'dotenv/config';
import { genkit, z } from 'genkit';
import { startFlowServer } from '@genkit-ai/express';
import { translateWithHyMt } from './hy_mt_client.js';

const ai = genkit({});

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
    const translatedText = await translateWithHyMt(text, sourceLang, targetLang);
    return {
      translatedText,
      model: 'HY-MT1.5',
    };
  },
);

startFlowServer({
  flows: [hyMtTranslateFlow],
  port: parseInt(process.env.PORT || '3400'),
  cors: { origin: '*' },
});

console.log('Lango Genkit backend running on port', process.env.PORT || 3400);
