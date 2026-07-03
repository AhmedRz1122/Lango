"""
Tencent HY-MT1.5 Offline Translation Service for Lango.

Setup:
  pip install -r requirements.txt
  python hy_mt_service.py

Requires ~4GB RAM for the 1.8B model. For edge devices, use quantized GGUF weights.
"""

import os
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

_model = None
_tokenizer = None
_model_loaded = False


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


def translate_text(text: str, source_lang: str, target_lang: str) -> str:
    if not _model_loaded:
        load_model()

    if _model is None or _tokenizer is None:
        return f"[HY-MT1.5 stub] {text} ({source_lang} -> {target_lang})"

    lang_map = {
        "en": "English", "es": "Spanish", "fr": "French", "de": "German",
        "zh": "Chinese", "ja": "Japanese", "ko": "Korean", "ar": "Arabic",
    }
    src = lang_map.get(source_lang, source_lang)
    tgt = lang_map.get(target_lang, target_lang)

    messages = [
        {"role": "user", "content": f"Translate the following {src} text to {tgt}:\n{text}"}
    ]

    import torch
    tokenized = _tokenizer.apply_chat_template(
        messages, tokenize=True, add_generation_prompt=True, return_tensors="pt"
    ).to(_model.device)

    with torch.no_grad():
        outputs = _model.generate(tokenized, max_new_tokens=512, do_sample=False)

    result = _tokenizer.decode(outputs[0][tokenized.shape[1]:], skip_special_tokens=True)
    return result.strip()


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "model_loaded": _model_loaded})


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
