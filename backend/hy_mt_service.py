"""
Tencent HY-MT1.5 translation engine for Lango.

Used by Genkit via hy_mt_worker.py (stdin/stdout, no HTTP port).
Optional standalone server (legacy): python hy_mt_service.py
"""

import os
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

_model = None
_tokenizer = None
_model_loaded = False

# Full HY-MT1.5 language names (https://github.com/Tencent-Hunyuan/HY-MT)
HY_MT_ENGLISH_NAMES = {
    "zh": "Chinese",
    "en": "English",
    "fr": "French",
    "pt": "Portuguese",
    "es": "Spanish",
    "ja": "Japanese",
    "tr": "Turkish",
    "ru": "Russian",
    "ar": "Arabic",
    "ko": "Korean",
    "th": "Thai",
    "it": "Italian",
    "de": "German",
    "vi": "Vietnamese",
    "ms": "Malay",
    "id": "Indonesian",
    "tl": "Filipino",
    "hi": "Hindi",
    "zh-Hant": "Traditional Chinese",
    "pl": "Polish",
    "cs": "Czech",
    "nl": "Dutch",
    "km": "Khmer",
    "my": "Burmese",
    "fa": "Persian",
    "gu": "Gujarati",
    "ur": "Urdu",
    "te": "Telugu",
    "mr": "Marathi",
    "he": "Hebrew",
    "bn": "Bengali",
    "ta": "Tamil",
    "uk": "Ukrainian",
    "bo": "Tibetan",
    "kk": "Kazakh",
    "mn": "Mongolian",
    "ug": "Uyghur",
    "yue": "Cantonese",
}

HY_MT_CHINESE_NAMES = {
    "zh": "中文",
    "en": "英语",
    "fr": "法语",
    "pt": "葡萄牙语",
    "es": "西班牙语",
    "ja": "日语",
    "tr": "土耳其语",
    "ru": "俄语",
    "ar": "阿拉伯语",
    "ko": "韩语",
    "th": "泰语",
    "it": "意大利语",
    "de": "德语",
    "vi": "越南语",
    "ms": "马来语",
    "id": "印尼语",
    "tl": "菲律宾语",
    "hi": "印地语",
    "zh-Hant": "繁体中文",
    "pl": "波兰语",
    "cs": "捷克语",
    "nl": "荷兰语",
    "km": "高棉语",
    "my": "缅甸语",
    "fa": "波斯语",
    "gu": "古吉拉特语",
    "ur": "乌尔都语",
    "te": "泰卢固语",
    "mr": "马拉地语",
    "he": "希伯来语",
    "bn": "孟加拉语",
    "ta": "泰米尔语",
    "uk": "乌克兰语",
    "bo": "藏语",
    "kk": "哈萨克语",
    "mn": "蒙古语",
    "ug": "维吾尔语",
    "yue": "粤语",
}

CHINESE_VARIANTS = {"zh", "zh-Hant", "yue"}


def load_model():
    global _model, _tokenizer, _model_loaded
    if _model_loaded:
        return

    model_name = os.environ.get("HY_MT_MODEL", "tencent/HY-MT1.5-1.8B")
    try:
        from transformers import AutoModelForCausalLM, AutoTokenizer
        import torch

        print(f"Loading HY-MT1.5 model: {model_name}")
        _tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
        _model = AutoModelForCausalLM.from_pretrained(
            model_name,
            torch_dtype=torch.bfloat16,
            device_map="auto",
            trust_remote_code=True,
        )
        _model_loaded = True
        print("HY-MT1.5 model loaded successfully")
    except Exception as e:
        print(f"Model load failed: {e}")
        print("Service will run in stub mode")


def build_prompt(text: str, source_lang: str, target_lang: str) -> str:
    """Build HY-MT prompt using official templates."""
    uses_chinese = (
        source_lang in CHINESE_VARIANTS or target_lang in CHINESE_VARIANTS
    )

    if uses_chinese:
        target_name = HY_MT_CHINESE_NAMES.get(target_lang, target_lang)
        return (
            f"将以下文本翻译为{target_name}，注意只需要输出翻译后的结果，不要额外解释：\n\n"
            f"{text}"
        )

    target_name = HY_MT_ENGLISH_NAMES.get(target_lang, target_lang)
    return (
        f"Translate the following segment into {target_name}, "
        f"without additional explanation.\n\n{text}"
    )


def translate_text(text: str, source_lang: str, target_lang: str) -> str:
    if not _model_loaded:
        load_model()

    if _model is None or _tokenizer is None:
        return f"[HY-MT1.5 stub] {text} ({source_lang} -> {target_lang})"

    prompt = build_prompt(text, source_lang, target_lang)
    messages = [{"role": "user", "content": prompt}]

    import torch
    tokenized = _tokenizer.apply_chat_template(
        messages, tokenize=True, add_generation_prompt=True, return_tensors="pt"
    ).to(_model.device)

    with torch.no_grad():
        outputs = _model.generate(
            tokenized,
            max_new_tokens=512,
            do_sample=True,
            top_k=20,
            top_p=0.6,
            repetition_penalty=1.05,
            temperature=0.7,
        )

    result = _tokenizer.decode(outputs[0][tokenized.shape[1]:], skip_special_tokens=True)
    return result.strip()


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "model_loaded": _model_loaded})


@app.route("/languages", methods=["GET"])
def languages():
    return jsonify({
        "languages": [
            {"code": code, "name": name}
            for code, name in HY_MT_ENGLISH_NAMES.items()
        ]
    })


@app.route("/translate", methods=["POST"])
def translate():
    data = request.get_json()
    text = data.get("text", "")
    source_lang = data.get("source_lang", "en")
    target_lang = data.get("target_lang", "es")

    if not text.strip():
        return jsonify({"error": "Empty text"}), 400

    try:
        translation = translate_text(text, source_lang, target_lang)
        return jsonify({"translation": translation, "model": "Tencent HY-MT1.5-1.8B"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    port = int(os.environ.get("HY_MT_PORT", 3401))
    print(f"Starting HY-MT1.5 service on port {port}")
    app.run(host="0.0.0.0", port=port, debug=False)
