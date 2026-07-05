// Full HY-MT1.5 language names (https://github.com/Tencent-Hunyuan/HY-MT)

export const langNames: Record<string, string> = {
  zh: 'Chinese', en: 'English', fr: 'French', pt: 'Portuguese',
  es: 'Spanish', ja: 'Japanese', tr: 'Turkish', ru: 'Russian',
  ar: 'Arabic', ko: 'Korean', th: 'Thai', it: 'Italian', de: 'German',
  vi: 'Vietnamese', ms: 'Malay', id: 'Indonesian', tl: 'Filipino',
  hi: 'Hindi', 'zh-Hant': 'Traditional Chinese', pl: 'Polish',
  cs: 'Czech', nl: 'Dutch', km: 'Khmer', my: 'Burmese', fa: 'Persian',
  gu: 'Gujarati', ur: 'Urdu', te: 'Telugu', mr: 'Marathi', he: 'Hebrew',
  bn: 'Bengali', ta: 'Tamil', uk: 'Ukrainian', bo: 'Tibetan',
  kk: 'Kazakh', mn: 'Mongolian', ug: 'Uyghur', yue: 'Cantonese',
};

export const langChineseNames: Record<string, string> = {
  zh: '中文', en: '英语', fr: '法语', pt: '葡萄牙语', es: '西班牙语',
  ja: '日语', tr: '土耳其语', ru: '俄语', ar: '阿拉伯语', ko: '韩语',
  th: '泰语', it: '意大利语', de: '德语', vi: '越南语', ms: '马来语',
  id: '印尼语', tl: '菲律宾语', hi: '印地语', 'zh-Hant': '繁体中文',
  pl: '波兰语', cs: '捷克语', nl: '荷兰语', km: '高棉语', my: '缅甸语',
  fa: '波斯语', gu: '古吉拉特语', ur: '乌尔都语', te: '泰卢固语',
  mr: '马拉地语', he: '希伯来语', bn: '孟加拉语', ta: '泰米尔语',
  uk: '乌克兰语', bo: '藏语', kk: '哈萨克语', mn: '蒙古语',
  ug: '维吾尔语', yue: '粤语',
};

const chineseVariants = new Set(['zh', 'zh-Hant', 'yue']);

export function buildHyMtPrompt(
  text: string,
  sourceLang: string,
  targetLang: string,
): string {
  const usesChinese =
    chineseVariants.has(sourceLang) || chineseVariants.has(targetLang);

  if (usesChinese) {
    const targetName = langChineseNames[targetLang] || targetLang;
    return `将以下文本翻译为${targetName}，注意只需要输出翻译后的结果，不要额外解释：\n\n${text}`;
  }

  const targetName = langNames[targetLang] || targetLang;
  return `Translate the following segment into ${targetName}, without additional explanation.\n\n${text}`;
}
